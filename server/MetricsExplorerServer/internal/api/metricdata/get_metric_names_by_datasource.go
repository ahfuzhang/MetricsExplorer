package metricdata

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func GetMetricNamesByDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyGetMetricNamesByDatasourceRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, metricNames []string) {
			rsp := &pb.GetMetricNamesByDatasourceResponse{Code: code, Message: msg, MetricNames: metricNames}
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
		respond(0, "success", ds.GetMetricNames())
	}
}
