package user

import (
	"io"
	"net/http"
	"strings"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func ListUser() http.HandlerFunc {
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

		req := &pb.ReadonlyListUserRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, users []pb.User) {
			rsp := &pb.ListUserResponse{Code: code, Message: msg, Users: users}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		info, ok := api.OnlineUsers.Load(req.Session)
		if !ok || info == nil {
			respond(1, "invalid session", nil)
			return
		}
		u, ok1 := info.(*api.OnlineUser)
		if !ok1 {
			respond(11, "invalid data type, internal error", nil)
			return
		}
		if u.UserName != config.Get().Admin.Name {
			respond(12, "only admin user allowd", nil)
			return
		}

		db := global.GetMysql()
		rows, err := db.Query(
			"SELECT user_id, user_name FROM users ORDER BY user_name LIMIT 1000",
		)
		if err != nil {
			respond(2, "database error: "+err.Error(), nil)
			return
		}
		defer rows.Close()

		users := make([]pb.User, 0, 64)
		for rows.Next() {
			var user pb.User
			if err = rows.Scan(&user.UserId, &user.UserName); err != nil {
				respond(3, "scan error: "+err.Error(), nil)
				return
			}
			users = append(users, user)
		}
		if err = rows.Err(); err != nil {
			respond(4, "rows error: "+err.Error(), nil)
			return
		}

		respond(0, "success", users)
	}
}
