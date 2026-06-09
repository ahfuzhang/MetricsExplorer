package user

import (
	"errors"
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
	mysqldriver "github.com/go-sql-driver/mysql"
)

func AddUser() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyAddUserRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.AddUserResponse{Code: code, Message: msg}
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

		db := global.GetMysql()
		result, err := db.Exec(
			"INSERT INTO users(user_name, `passwd`) VALUES(?, ?)",
			req.UserName, req.Sha256,
		)
		if err != nil {
			var mysqlErr *mysqldriver.MySQLError
			if errors.As(err, &mysqlErr) && mysqlErr.Number == 1062 {
				respond(4, "username already exists")
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

		respond(0, "success")
	}
}
