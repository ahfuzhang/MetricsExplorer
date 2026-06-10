package metricdata

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func GetPodsByDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyGetPodsRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, pods map[string]*pb.PodGroup) {
			rsp := &pb.GetPodsResponse{Code: code, Message: msg, Pods: pods}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		_, code, msg := api.Auth(req.Session, false)
		if code != 0 {
			respond(code, msg, nil)
			return
		}

		ds := global.GetDataSource(req.VmDatasourceName)
		if ds == nil {
			respond(3, "datasource not available", nil)
			return
		}

		pods := ds.GetPods()
		result := make(map[string]*pb.PodGroup, len(pods))
		for prefix, podSet := range pods {
			names := make([]string, 0, len(podSet))
			for name := range podSet {
				names = append(names, name)
			}
			result[prefix] = &pb.PodGroup{PodName: names}
		}
		respond(0, "success", result)
	}
}
