package metricdata

import (
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
	vmpb "github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api"
)

func GetSeriesByDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			io.Copy(io.Discard, r.Body)
			r.Body.Close()
			return
		}
		if !strings.HasPrefix(r.Header.Get("Content-Type"), "application/protobuf") {
			w.WriteHeader(http.StatusBadRequest)
			io.Copy(io.Discard, r.Body)
			r.Body.Close()
			return
		}
		body, err := io.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			r.Body.Close()
			return
		}
		_ = r.Body.Close()

		req := &pb.ReadonlyGetSeriesByDatasourceRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, r *pb.GetSeriesByDatasourceResponse) {
			rsp := &pb.GetSeriesByDatasourceResponse{Code: code, Message: msg}
			if r != nil {
				//rsp.Series = r.Series
				rsp.Tags = r.Tags
				rsp.Ts = r.Ts
			}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		_, ok := api.OnlineUsers.Load(req.Session)
		if !ok {
			respond(1, "invalid session", nil)
			return
		}

		ds := global.GetDataSource(req.VmDatasourceName)
		if ds == nil {
			respond(3, "datasource not available", nil)
			return
		}

		names := strings.Split(req.MetricName, ",")
		matchParts := make([]string, 0, len(names))
		for _, name := range names {
			name = strings.TrimSpace(name)
			if name != "" {
				matchParts = append(matchParts, "match[]="+name)
			}
		}
		postBody := strings.NewReader(strings.Join(matchParts, "&"))
		httpResp, err := ds.Client.Post(ds.Addr+"/api/v1/series", "application/x-www-form-urlencoded", postBody)
		if err != nil {
			respond(4, fmt.Sprintf("query series fail: %v", err), nil)
			return
		}
		defer httpResp.Body.Close()
		if httpResp.StatusCode != http.StatusOK {
			io.Copy(io.Discard, httpResp.Body)
			respond(5, fmt.Sprintf("query series fail, status=%d", httpResp.StatusCode), nil)
			return
		}
		respBody, err := io.ReadAll(httpResp.Body)
		if err != nil {
			respond(6, fmt.Sprintf("read series response fail: %v", err), nil)
			return
		}

		var vmResp vmpb.ReadonlyQuerySeriesResponse
		if err = vmResp.FromJSON(respBody); err != nil {
			respond(7, fmt.Sprintf("parse series response fail: %v", err), nil)
			return
		}
		if vmResp.Status != "success" {
			respond(8, fmt.Sprintf("query series fail, status=%s", vmResp.Status), nil)
			return
		}
		ts := &pb.GetSeriesByDatasourceResponse{}
		// 格式 1
		{
			series := make([]pb.MetricTags, 0, len(vmResp.Data))
			for _, ts := range vmResp.Data {
				m := pb.MetricTags{
					Tags: make(map[string]string, len(ts.Labels)),
				}
				for k, v := range ts.Labels {
					m.Tags[k] = v
				}
				series = append(series, m)
			}
			ts.Ts = series
		}
		// 格式 2
		// {
		// 	// todo: 准备废弃
		// 	series := make([]string, 0, len(vmResp.Data))
		// 	for _, ts := range vmResp.Data {
		// 		b, e := json.Marshal(ts.Labels)
		// 		if e != nil {
		// 			continue
		// 		}
		// 		series = append(series, string(b))
		// 	}
		// 	ts.Series = series
		// }
		// 加工标签，统计每个标签 key 有多少种 value，value 是什么
		tags := processLabels(vmResp.Data)
		ts.Tags = make(map[string]*pb.TagValues, len(tags))
		for k, v := range tags {
			values := make([]string, 0, len(v))
			showTimes := make([]int32, 0, len(v))
			for value, shows := range v {
				values = append(values, value)
				showTimes = append(showTimes, shows)
			}
			ts.Tags[k] = &pb.TagValues{Values: values, ShowTimes: showTimes}
		}
		respond(0, "success", ts)
	}
}

func processLabels(series []vmpb.ReadonlyTimeSeries) map[string]map[string]int32 {
	keys := make(map[string]map[string]int32, 32)
	for _, ts := range series {
		tags := ts.Labels
		for k, v := range tags {
			if k == "__name__" {
				continue
			}
			m, ok := keys[k]
			if !ok {
				m = make(map[string]int32)
				keys[k] = m
			}
			m[v]++
			// 统计每个 key 有多少种 value，每种 value 出现多少次
		}
	}
	return keys
}
