package datasource

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func RemoveDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyRemoveDatasourceRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.RemoveDatasourceResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		info, ok := api.OnlineUsers.Load(req.Session)
		if !ok || info == nil {
			respond(1, "invalid session")
			return
		}
		u, ok1 := info.(*api.OnlineUser)
		if !ok1 {
			respond(11, "invalid data type, internal error")
			return
		}
		if u.UserName != config.Get().Admin.Name {
			respond(12, "only admin user allowd")
			return
		}

		if req.VmDatasourceId == 0 {
			respond(5, "vm_datasource_id is required")
			return
		}

		db := global.GetMysql()
		var datasourceName string
		err = db.QueryRow(
			"SELECT datasource_name FROM victoria_metrics_data_source WHERE vm_datasource_id = ?",
			req.VmDatasourceId,
		).Scan(&datasourceName)
		if err != nil {
			respond(4, "datasource not found")
			return
		}

		result, err := db.Exec(
			"DELETE FROM victoria_metrics_data_source WHERE vm_datasource_id = ?",
			req.VmDatasourceId,
		)
		if err != nil {
			respond(2, "database error: "+err.Error())
			return
		}

		rowsAffected, err := result.RowsAffected()
		if err != nil {
			respond(3, "get rows affected error: "+err.Error())
			return
		}
		if rowsAffected == 0 {
			respond(4, "datasource not found")
			return
		}
		global.DeleteDataSource(datasourceName)
		respond(0, "success")
	}
}
