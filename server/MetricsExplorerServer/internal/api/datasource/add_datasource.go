package datasource

import (
	"errors"
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
	mysqldriver "github.com/go-sql-driver/mysql"
)

func AddDatasource() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyAddDatasourceRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.AddDatasourceResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}
		_, code, msg := api.Auth(req.Session, true)
		if code != 0 {
			respond(code, msg)
			return
		}

		if req.DatasourceName == "" {
			respond(5, "datasource_name is required")
			return
		}
		if req.Addr == "" {
			respond(6, "addr is required")
			return
		}

		db := global.GetMysql()
		result, err := db.Exec(
			"INSERT INTO victoria_metrics_data_source(datasource_name, addr) VALUES(?, ?)",
			req.DatasourceName, req.Addr,
		)
		if err != nil {
			var mysqlErr *mysqldriver.MySQLError
			if errors.As(err, &mysqlErr) && mysqlErr.Number == 1062 {
				respond(4, "datasource already exists")
				return
			}
			respond(2, "database error: "+err.Error())
			return
		}

		rowsAffected, err := result.RowsAffected()
		if err != nil || rowsAffected != 1 {
			respond(3, "insert failed")
			return
		}
		if err := global.AddDataSource(req.DatasourceName, req.Addr); err != nil {
			respond(2, "query datasource error: "+err.Error())
			return
		}
		respond(0, "success")
	}
}
