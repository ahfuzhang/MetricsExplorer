package metricdata

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"unsafe"

	"golang.org/x/sync/errgroup"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

type rangeQueryResult struct {
	qr pb.QueryResult
	//timestamps []int64
	//arena []byte
}

func CloneMap(m map[string]string) map[string]string {
	var l int
	for k, v := range m {
		l += len(k) + len(v)
	}
	arena := make([]byte, l)
	out := make(map[string]string, len(m))
	var offset int
	for k, v := range m {
		copy(arena[offset:], unsafe.Slice(unsafe.StringData(k), len(k)))
		k1 := unsafe.String(unsafe.SliceData(arena[offset:]), len(k))
		offset += len(k)
		copy(arena[offset:], unsafe.Slice(unsafe.StringData(v), len(v)))
		v1 := unsafe.String(unsafe.SliceData(arena[offset:]), len(v))
		offset += len(v)
		out[k1] = v1
	}
	return out
}

func IsCounter(arr []float64) bool {
	v := arr[0]
	for _, vv := range arr[1:] {
		if v > vv {
			return false
		}
		v = vv
	}
	return true
}

func GetRangeByDatasource() http.HandlerFunc {
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

		req := &pb.ReadonlyGetRangeByDatasourceRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, rsp *pb.GetRangeByDatasourceResponse) {
			if rsp == nil {
				rsp = &pb.GetRangeByDatasourceResponse{}
			}
			rsp.Code = code
			rsp.Message = msg
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

		n := len(req.Queries)
		results := make([]rangeQueryResult, n)

		g, _ := errgroup.WithContext(r.Context())
		g.SetLimit(5)
		rspData := &pb.GetRangeByDatasourceResponse{
			QueriesResult: make([]pb.QueryResult, n),
		}
		var hasTimestamps bool

		for i, query := range req.Queries {
			g.Go(func() error {
				vmRsp, queryErr := ds.QueryRange(&global.RangeQueryRequest{
					Query:   query,
					Start:   req.Start,
					End:     req.End,
					Step:    req.Step,
					Timeout: req.Timeout,
				})
				if queryErr != nil {
					results[i].qr = pb.QueryResult{Code: 1, Message: fmt.Sprintf("query failed: %v", queryErr)}
					return nil
				}
				defer func() {
					vmRsp.Reset() // 一定要保障，生命周期内，所有的数据都复制走了
					global.PutRangeQueryResponse(vmRsp)
				}()

				metricList := vmRsp.Data.Result
				if len(metricList) == 0 {
					return nil
				}
				// 时间戳，处理一次就够了
				if !hasTimestamps {
					if !hasTimestamps { // 双检查锁
						hasTimestamps = true
						// extract timestamps from the first metric (all metrics share the same time axis)
						firstValues := metricList[0].Values
						timestamps := make([]int64, 0, len(firstValues))
						for _, series := range firstValues {
							if len(series.Values) >= 1 {
								timestamps = append(timestamps, int64(series.Values[0]))
							}
						}
						rspData.Timestamps = timestamps
					}
				}
				//results[i].timestamps = timestamps

				// build one RangeData per metric
				datas := make([]pb.RangeData, 0, len(metricList))
				for _, metricData := range metricList { // 遍历同一个查询返回的多个 metrics
					rawPoints := make([]float64, 0, len(metricData.Values))
					for _, series := range metricData.Values {
						if len(series.Values) >= 2 {
							rawPoints = append(rawPoints, series.Values[1])
						}
					}
					rd := pb.RangeData{
						Tags: CloneMap(metricData.Metric), // 这里应该复制
					}
					if len(rawPoints) > 0 {
						allSame := true
						first := rawPoints[0]
						for _, v := range rawPoints[1:] {
							if v != first {
								allSame = false
								break
							}
						}
						if allSame {
							rd.ConstValue = first
							rd.MetricType = pb.Staticvalue
						} else {
							rd.Points = rawPoints
							if IsCounter(rawPoints) {
								rd.MetricType = pb.Counter
							}
						}
					}
					datas = append(datas, rd)
				}
				results[i].qr = pb.QueryResult{Datas: datas}
				return nil
			})
		}

		_ = g.Wait()

		for i := range results {
			rspData.QueriesResult[i] = results[i].qr
			// if rspData.Timestamps == nil && len(results[i].timestamps) > 0 {
			// 	rspData.Timestamps = results[i].timestamps
			// }
		}

		respond(0, "success", rspData)
	}
}
