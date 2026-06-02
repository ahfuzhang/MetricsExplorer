package metricdata

import (
	"io"
	"net/http"
	"strings"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func GetLabelsByDatasource() http.HandlerFunc {
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

		req := &pb.ReadonlyGetLabelsByDatasourceRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, labels []string) {
			rsp := &pb.GetLabelsByDatasourceResponse{Code: code, Message: msg, Labels: labels}
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

		labels := make([]string, 0, len(ds.Labels))
		for label := range ds.Labels {
			labels = append(labels, label)
		}
		// sort.Slice(labels, func(i, j int) bool {
		// 	return strings.ToLower(labels[i]) < strings.ToLower(labels[j])
		// })

		respond(0, "success", labels)
	}
}
