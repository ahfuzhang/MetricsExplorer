package datasource

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func ListDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyListDatasourceRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, datasources []pb.VictoriaMetricsDatasource) {
			rsp := &pb.ListDatasourceResponse{Code: code, Message: msg, Datasources: datasources}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		_, code, msg := api.Auth(req.Session, true)
		if code != 0 {
			respond(code, msg, nil)
			return
		}

		db := global.GetMysql()
		rows, err := db.Query(
			"SELECT vm_datasource_id, datasource_name, addr FROM victoria_metrics_data_source ORDER BY datasource_name LIMIT 1000",
		)
		if err != nil {
			respond(2, "database error: "+err.Error(), nil)
			return
		}
		defer rows.Close()

		datasources := make([]pb.VictoriaMetricsDatasource, 0, 16)
		for rows.Next() {
			var ds pb.VictoriaMetricsDatasource
			if err = rows.Scan(&ds.VmDatasourceId, &ds.DatasourceName, &ds.Addr); err != nil {
				respond(3, "scan error: "+err.Error(), nil)
				return
			}
			datasources = append(datasources, ds)
		}
		if err = rows.Err(); err != nil {
			respond(4, "rows error: "+err.Error(), nil)
			return
		}

		respond(0, "success", datasources)
	}
}
