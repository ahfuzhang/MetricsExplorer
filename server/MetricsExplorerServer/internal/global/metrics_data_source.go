package global

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"
	"time"
	"unsafe"

	"github.com/ahfuzhang/BaoHuLu/dependencies/golang/fastjson"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api"
)

type DataSourceClient struct {
	Addr       string
	Client     *http.Client
	Labels     map[string]struct{}
	labelArena []byte
	rsp        pb.ReadonlyQueryLabelResponse
	parser     fastjson.Parser
	//
	MetricNames     map[string]struct{}
	metricNameArena []byte
	//
	locker sync.Mutex
}

func (c *DataSourceClient) LoadMetricNames() error {
	resp, err := c.Client.Get(c.Addr + "/api/v1/label/__name__/values")
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
	if err = c.rsp.FromJSON(body, &c.parser); err != nil {
		return fmt.Errorf("parse metric names response from datasource %s fail, err=%+v", c.Addr, err)
	}
	if c.rsp.Status != "success" {
		return fmt.Errorf("get metric names from datasource %s fail, response status=%s", c.Addr, c.rsp.Status)
	}
	// 先检查是否有变化
	if len(c.MetricNames) == len(c.rsp.Data) {
		for _, name := range c.rsp.Data {
			if _, ok := c.MetricNames[name]; !ok {
				// 有新的指标，更新
				goto UPDATE
			}
		}
	}
	// 指标没有变化，不更新了
	return nil

UPDATE:

	c.MetricNames = make(map[string]struct{}, len(c.rsp.Data))
	bytesNeeded := 0
	for _, name := range c.rsp.Data {
		bytesNeeded += len(name)
	}
	c.metricNameArena = make([]byte, bytesNeeded)
	offset := 0
	for _, name := range c.rsp.Data {
		copy(c.metricNameArena[offset:], name)
		k := unsafe.String(unsafe.SliceData(c.metricNameArena[offset:offset+len(name)]), len(name))
		c.MetricNames[k] = struct{}{}
		offset += len(name)
	}
	c.rsp.Reset()
	c.parser.Reset()
	return nil
}

func (c *DataSourceClient) LoadLabels() error {
	// todo: 考虑加一个锁
	resp, err := c.Client.Get(c.Addr + "/api/v1/labels")
	if err != nil {
		return fmt.Errorf("get labels from datasource %s fail, err=%+v", c.Addr, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		io.Copy(io.Discard, resp.Body)
		return fmt.Errorf("get labels from datasource %s fail, status code=%d", c.Addr, resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		io.Copy(io.Discard, resp.Body)
		return fmt.Errorf("read labels response from datasource %s fail, err=%+v", c.Addr, err)
	}
	c.locker.Lock()
	defer c.locker.Unlock()
	c.rsp.Reset()
	if err = c.rsp.FromJSON(body, &c.parser); err != nil {
		return fmt.Errorf("parse labels response from datasource %s fail, err=%+v", c.Addr, err)
	}
	if c.rsp.Status != "success" {
		return fmt.Errorf("get labels from datasource [%s] fail, response status=%s", c.Addr, c.rsp.Status)
	}
	// 先检查是否有变化
	if len(c.Labels) == len(c.rsp.Data) {
		for _, label := range c.rsp.Data {
			if _, ok := c.Labels[label]; !ok {
				// 有新的标签，更新
				goto UPDATE
			}
		}
	}
	// 标签没有变化，不更新了
	return nil

UPDATE:

	c.Labels = make(map[string]struct{}, len(c.rsp.Data))
	// 计算字节数
	bytesNeeded := 0
	for _, label := range c.rsp.Data {
		bytesNeeded += len(label)
	}
	// 分配一次内存
	c.labelArena = make([]byte, bytesNeeded)
	// 将标签复制到 arena 中，并更新 Labels map 中的指针
	offset := 0
	for _, label := range c.rsp.Data {
		copy(c.labelArena[offset:], label)
		k := unsafe.String(unsafe.SliceData(c.labelArena[offset:offset+len(label)]), len(label))
		c.Labels[k] = struct{}{}
		offset += len(label)
	}
	// for _, label := range c.rsp.Data {
	// 	c.Labels[label] = struct{}{}
	// }
	c.rsp.Reset()
	c.parser.Reset()
	return nil
}

var allDataSources sync.Map // key: datasource_name (string), value: *DataSourceClient

func LoadAllMetricsDataSources() error {
	db := GetMysql()
	rows, err := db.Query(
		"SELECT datasource_name, addr FROM victoria_metrics_data_source ORDER BY datasource_name LIMIT 1000",
	)
	if err != nil {
		return fmt.Errorf("query victoria_metrics_data_source fail, err=%+v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var name, addr string
		if err = rows.Scan(&name, &addr); err != nil {
			return fmt.Errorf("scan victoria_metrics_data_source fail, err=%+v", err)
		}
		allDataSources.Store(name, &DataSourceClient{
			Addr:   addr,
			Client: &http.Client{Timeout: 10 * time.Second}, // todo: 超时时间做成可以配置的
		})
	}
	if err = rows.Err(); err != nil {
		return fmt.Errorf("rows error from victoria_metrics_data_source, err=%+v", err)
	}

	go healthCheckLoop()
	return nil
}

func AddDataSource(name, addr string) error {
	// 先检查连接是否可用
	c := &DataSourceClient{
		Addr:   addr,
		Client: &http.Client{Timeout: 10 * time.Second},
	}
	if err := c.LoadLabels(); err != nil {
		return fmt.Errorf("connect to datasource %s fail, err=%+v", addr, err)
	}
	allDataSources.Store(name, c)
	go func() {
		err := c.LoadMetricNames()
		if err != nil {
			log.Printf("LoadMetricNames %s failed: %v", name, err)
		}
	}()
	return nil
}

func DeleteDataSource(name string) {
	allDataSources.Delete(name)
}

func GetDataSource(name string) *DataSourceClient {
	v, ok := allDataSources.Load(name)
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
	allDataSources.Range(func(key, value any) bool {
		name := key.(string)
		ds := value.(*DataSourceClient)
		if err := ds.LoadLabels(); err != nil {
			log.Printf("datasource %s health check failed: %v, removing", name, err)
			allDataSources.Delete(key)
		}
		log.Printf("datasource [%s] load labels success", name)
		go func() {
			err := ds.LoadMetricNames()
			if err != nil {
				log.Printf("LoadMetricNames %s failed: %v", name, err)
			}
			log.Printf("datasource [%s] load metric names success", name)
		}()
		return true
	})
}

func healthCheckLoop() {
	checkAllDataSources()
	//
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()
	for range ticker.C {
		checkAllDataSources()
	}
}
