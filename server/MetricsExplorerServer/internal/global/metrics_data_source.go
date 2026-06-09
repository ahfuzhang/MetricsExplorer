package global

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"sync"
	"sync/atomic"
	"time"
	"unsafe"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api"
)

type DataSourceClient struct {
	Addr        string
	ID          uint64
	Name        string
	Client      *http.Client
	Labels      map[string]map[string]struct{} // outer key: label name; inner map: label values (nil until populated)
	MetricNames map[string]struct{}

	labelArena             []byte
	rsp                    pb.ReadonlyQueryLabelResponse
	metricNameArena        []byte
	locker                 sync.RWMutex
	loadLabelValuesRunning atomic.Bool
}

// RangeQueryRequest holds parameters for the query_range API.
// curl "http://127.0.0.1:8481/select/0/prometheus/api/v1/query_range?query=vm_http_request_errors_total&step=1m&start=2026-06-04T07:59:00.000Z&end=2026-06-04T08:09:00.000Z"
type RangeQueryRequest struct {
	Query   string
	Start   string // RFC3339 or unix timestamp
	End     string // RFC3339 or unix timestamp
	Step    string // e.g. "1m", "60s"
	Timeout string // optional, e.g. "30s"
}

var rangeQueryResponsePool = sync.Pool{
	New: func() any { return &pb.ReadonlyRangeQueryResponse{} },
}

// PutRangeQueryResponse returns rsp to the response pool for reuse.
func PutRangeQueryResponse(rsp *pb.ReadonlyRangeQueryResponse) {
	rsp.Reset()
	rangeQueryResponsePool.Put(rsp)
}

func (c *DataSourceClient) QueryRange(req *RangeQueryRequest) (*pb.ReadonlyRangeQueryResponse, error) {
	form := url.Values{
		"query": {req.Query},
		"start": {req.Start},
		"end":   {req.End},
		"step":  {req.Step},
	}
	if req.Timeout != "" {
		form.Set("timeout", req.Timeout)
	}
	resp, err := c.Client.PostForm(c.Addr+"/api/v1/query_range", form)
	if err != nil {
		return nil, fmt.Errorf("query_range from datasource %s fail, err=%+v", c.Addr, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		io.Copy(io.Discard, resp.Body)
		return nil, fmt.Errorf("query_range from datasource %s fail, status code=%d", c.Addr, resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read query_range response from datasource %s fail, err=%+v", c.Addr, err)
	}
	rsp := rangeQueryResponsePool.Get().(*pb.ReadonlyRangeQueryResponse)
	rsp.Reset()
	if err = rsp.FromJSON(body); err != nil {
		PutRangeQueryResponse(rsp)
		return nil, fmt.Errorf("parse query_range response from datasource %s fail, err=%+v", c.Addr, err)
	}
	if rsp.Status != "success" {
		PutRangeQueryResponse(rsp)
		return nil, fmt.Errorf("query_range from datasource %s fail, response status=%s", c.Addr, rsp.Status)
	}
	return rsp, nil
}

func (c *DataSourceClient) LoadMetricNames() error {
	resp, err := c.Client.Get(c.Addr + "/api/v1/label/__name__/values?limit=10000")
	if err != nil {
		return fmt.Errorf("get metric names from datasource %s fail, err=%+v", c.Addr, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		io.Copy(io.Discard, resp.Body)
		return fmt.Errorf("get metric names from datasource %s fail, status code=%d", c.Addr, resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		io.Copy(io.Discard, resp.Body)
		return fmt.Errorf("read metric names response from datasource %s fail, err=%+v", c.Addr, err)
	}
	c.locker.Lock()
	defer c.locker.Unlock()
	c.rsp.Reset()
	if err = c.rsp.FromJSON(body); err != nil {
		return fmt.Errorf("parse metric names response from datasource %s fail, err=%+v", c.Addr, err)
	}
	if c.rsp.Status != "success" {
		return fmt.Errorf("get metric names from datasource %s fail, response status=%s", c.Addr, c.rsp.Status)
	}
	if len(c.rsp.Data) == 0 {
		//log.Printf("datasource [%s] has no metric", c.Name)
		//fmt.Printf("\t%s\n", string(body))
		return nil
	}
	//log.Printf("datasource [%s] got %d metric names", c.Name, len(c.rsp.Data))
	// 先检查是否有变化
	if len(c.MetricNames) != len(c.rsp.Data) {
		goto UPDATE
	}
	for _, name := range c.rsp.Data {
		if _, ok := c.MetricNames[name]; !ok {
			// 有新的指标，更新
			goto UPDATE
		}
	}
	// 指标没有变化，不更新了
	//log.Printf("datasource [%s] metric names no change, skip updating, count=%d", c.Name, len(c.MetricNames))
	return nil

UPDATE:

	m := make(map[string]struct{}, len(c.rsp.Data))
	bytesNeeded := 0
	for _, name := range c.rsp.Data {
		bytesNeeded += len(name)
	}
	arena := make([]byte, bytesNeeded)
	offset := 0
	for _, name := range c.rsp.Data {
		copy(arena[offset:], name)
		k := unsafe.String(unsafe.SliceData(arena[offset:offset+len(name)]), len(name))
		m[k] = struct{}{}
		offset += len(name)
	}
	c.rsp.Reset()
	c.metricNameArena = arena
	c.MetricNames = m
	//log.Printf("datasource [%s] metric names updated, count=%d", c.Name, len(c.MetricNames))
	return nil
}

func (c *DataSourceClient) LoadLabels(limit int) (changed bool, err error) {
	var resp *http.Response
	resp, err = c.Client.Get(fmt.Sprintf("%s/api/v1/labels?limit=%d", c.Addr, limit))
	if err != nil {
		err = fmt.Errorf("get labels from datasource %s fail, err=%+v", c.Addr, err)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		io.Copy(io.Discard, resp.Body)
		err = fmt.Errorf("get labels from datasource %s fail, status code=%d", c.Addr, resp.StatusCode)
		return
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		io.Copy(io.Discard, resp.Body)
		err = fmt.Errorf("read labels response from datasource %s fail, err=%+v", c.Addr, err)
		return
	}
	c.locker.Lock()
	defer c.locker.Unlock()
	c.rsp.Reset()
	if err = c.rsp.FromJSON(body); err != nil {
		err = fmt.Errorf("parse labels response from datasource %s fail, err=%+v", c.Addr, err)
		return
	}
	if c.rsp.Status != "success" {
		err = fmt.Errorf("get labels from datasource [%s] fail, response status=%s", c.Addr, c.rsp.Status)
	}
	if len(c.rsp.Data) == 0 {
		//log.Printf("datasource [%s] has no labels", c.Name)
		//fmt.Printf("\t%s\n", string(body))
		err = nil
		return
	}
	//log.Printf("datasource [%s] got %d labels", c.Name, len(c.rsp.Data))
	// 先检查是否有变化
	if len(c.Labels) != len(c.rsp.Data) {
		goto UPDATE
	}
	for _, label := range c.rsp.Data {
		if _, ok := c.Labels[label]; !ok {
			// 有新的标签，更新
			goto UPDATE
		}
	}
	// 标签没有变化，不更新了
	//log.Printf("datasource [%s] labels no change, skip updating, count=%d", c.Name, len(c.Labels))
	err = nil
	return

UPDATE:
	changed = true
	m := make(map[string]map[string]struct{}, len(c.rsp.Data))
	// 计算字节数
	bytesNeeded := 0
	for _, label := range c.rsp.Data {
		bytesNeeded += len(label)
	}
	// 分配一次内存
	arena := make([]byte, bytesNeeded)
	// 将标签复制到 arena 中，并更新 Labels map 中的指针
	offset := 0
	for _, label := range c.rsp.Data {
		copy(arena[offset:], label)
		k := unsafe.String(unsafe.SliceData(arena[offset:offset+len(label)]), len(label))
		m[k] = nil
		offset += len(label)
	}
	c.rsp.Reset()
	c.Labels = m
	c.labelArena = arena
	//log.Printf("datasource [%s] labels updated, count=%d", c.Name, len(c.Labels))
	err = nil
	return
}

func (c *DataSourceClient) LoadLabelValues() error {
	c.locker.RLock()
	labels := make([]string, 0, len(c.Labels))
	for label := range c.Labels {
		labels = append(labels, label)
	}
	c.locker.RUnlock()

	var rsp pb.ReadonlyQueryLabelResponse
	for _, label := range labels {
		apiURL := fmt.Sprintf("%s/api/v1/label/%s/values?limit=1000", c.Addr, url.PathEscape(label))
		resp, err := c.Client.Get(apiURL)
		if err != nil {
			log.Printf("get label values for [%s] from datasource [%s] fail: %v", label, c.Name, err)
			continue
		}
		if resp.StatusCode != http.StatusOK {
			io.Copy(io.Discard, resp.Body)
			resp.Body.Close()
			log.Printf("get label values for [%s] from datasource [%s] fail, status=%d", label, c.Name, resp.StatusCode)
			continue
		}
		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			log.Printf("read label values for [%s] from datasource [%s] fail: %v", label, c.Name, err)
			continue
		}
		rsp.Reset()
		if err = rsp.FromJSON(body); err != nil {
			log.Printf("parse label values for [%s] from datasource [%s] fail: %v", label, c.Name, err)
			continue
		}
		if rsp.Status != "success" {
			log.Printf("get label values for [%s] from datasource [%s] fail, response status=%s", label, c.Name, rsp.Status)
			continue
		}
		log.Printf("\t\t label=%s, value count=%d", label, len(rsp.Data))
		m := make(map[string]struct{}, len(rsp.Data))
		var l int
		for _, v := range rsp.Data {
			l += len(v)
		}
		arena := make([]byte, l)
		var offset int
		for _, v := range rsp.Data {
			copy(arena[offset:], v)
			k1 := unsafe.String(unsafe.SliceData(arena[offset:]), len(v))
			offset += len(v)
			m[k1] = struct{}{}
		}
		c.locker.Lock()
		c.Labels[label] = m
		c.locker.Unlock()
	}
	return nil
}

func (c *DataSourceClient) TriggerLoadLabelValues() {
	if !c.loadLabelValuesRunning.CompareAndSwap(false, true) {
		return
	}
	go func() {
		defer c.loadLabelValuesRunning.Store(false)
		if err := c.LoadLabelValues(); err != nil {
			log.Printf("LoadLabelValues for datasource [%s] failed: %v", c.Name, err)
		}
		log.Printf("datasource [%s] load label values success", c.Name)
	}()
}

func (c *DataSourceClient) GetLabels() map[string]map[string]struct{} {
	c.locker.RLock()
	defer c.locker.RUnlock()
	labels := make(map[string]map[string]struct{}, len(c.Labels))
	for labelName, values := range c.Labels {
		labels[labelName] = values
	}
	return labels
}

func (c *DataSourceClient) GetMetricNames() []string {
	c.locker.RLock()
	defer c.locker.RUnlock()
	metricNames := make([]string, 0, len(c.MetricNames))
	for name := range c.MetricNames {
		metricNames = append(metricNames, name)
	}
	return metricNames
}

var AllDataSources sync.Map // key: datasource_name (string), value: *DataSourceClient

func LoadAllMetricsDataSources() error {
	db := GetMysql()
	rows, err := db.Query(
		"SELECT vm_datasource_id, datasource_name, addr FROM victoria_metrics_data_source ORDER BY datasource_name LIMIT 1000",
	)
	if err != nil {
		return fmt.Errorf("query victoria_metrics_data_source fail, err=%+v", err)
	}
	defer rows.Close()
	cnt := 0
	for rows.Next() {
		var id uint64
		var name, addr string
		if err = rows.Scan(&id, &name, &addr); err != nil {
			return fmt.Errorf("scan victoria_metrics_data_source fail, err=%+v", err)
		}
		AllDataSources.Store(name, &DataSourceClient{
			Addr:   addr,
			Client: &http.Client{Timeout: 10 * time.Second}, // todo: 超时时间做成可以配置的
			ID:     id,
			Name:   name,
		})
		cnt++
	}
	if err = rows.Err(); err != nil {
		return fmt.Errorf("rows error from victoria_metrics_data_source, err=%+v", err)
	}

	checkAllDataSources() // populate labels before the HTTP server starts
	go healthCheckLoop()
	log.Println("\tload metric datasource:", cnt)
	return nil
}

func AddDataSource(name, addr string) error {
	// 先检查连接是否可用
	c := &DataSourceClient{
		Addr:   addr,
		Client: &http.Client{Timeout: 10 * time.Second},
	}
	_, err := c.LoadLabels(10000)
	if err != nil {
		return fmt.Errorf("connect to datasource %s fail, err=%+v", addr, err)
	}
	AllDataSources.Store(name, c)
	go func() {
		err := c.LoadMetricNames()
		if err != nil {
			log.Printf("LoadMetricNames %s failed: %v", name, err)
		}
	}()
	return nil
}

func DeleteDataSource(name string) {
	AllDataSources.Delete(name)
}

func GetDataSource(name string) *DataSourceClient {
	v, ok := AllDataSources.Load(name)
	if !ok {
		return nil
	}
	ds, ok := v.(*DataSourceClient)
	if !ok {
		panic("impossible: value in allDataSources is not *DataSourceClient")
	}
	return ds
}

func checkAllDataSources() {
	AllDataSources.Range(func(key, value any) bool {
		name := key.(string)
		ds := value.(*DataSourceClient)
		changed, err := ds.LoadLabels(10000)
		if err != nil {
			log.Printf("datasource %s health check failed: %v, removing", name, err)
			AllDataSources.Delete(key)
			// todo: 踢掉数据源后，应该定期加载，否则数据源恢复后无法访问
		}
		log.Printf("datasource [%s] load labels success", name)
		go func() {
			err := ds.LoadMetricNames()
			if err != nil {
				log.Printf("LoadMetricNames %s failed: %v", name, err)
			}
			log.Printf("datasource [%s] load metric names success", name)
		}()
		if changed {
			ds.TriggerLoadLabelValues() // 加载 label value
		}
		return true
	})
}

func healthCheckLoop() {
	interval := time.Duration(config.Get().MetricDataSource.ResfreshIntervalSeconds) * time.Second
	if interval <= 0 {
		interval = time.Minute
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for range ticker.C {
		log.Println("\tcheckAllDataSources(metric)")
		checkAllDataSources()
	}
}
