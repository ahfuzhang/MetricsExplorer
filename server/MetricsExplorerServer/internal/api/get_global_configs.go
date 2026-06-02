package api

import (
	"net/http"

	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func GetGlobalConfigs(cfg *pb.ReadonlyMetricsExplorerConfigs) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		w.Header().Set("Content-Type", "application/protobuf")
		w.WriteHeader(http.StatusOK)
		rsp := &pb.GetGlobalConfigsResponse{
			Salt:    cfg.Salt,
			APIPath: cfg.Http.Path,
		}
		arr := rsp.ToProtobuf(nil)
		// todo
		_, _ = w.Write(arr)
	}
}
