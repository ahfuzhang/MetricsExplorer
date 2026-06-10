package menu

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func AddMenu() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyAddMenuRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.AddMenuResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		_, code, msg := api.Auth(req.Session, true)
		if code != 0 {
			respond(code, msg)
			return
		}

		if req.Menu.MenuName == "" {
			respond(5, "menu_name is required")
			return
		}

		db := global.GetMysql()
		result, err := db.Exec(
			"INSERT INTO menus(menu_name, parent_id, role_id, link, target, bit_flags) VALUES(?, ?, ?, ?, ?, ?)",
			req.Menu.MenuName, req.Menu.ParentId, req.Menu.RoleId, req.Menu.Link, req.Menu.Target, req.Menu.BitFlags,
		)
		if err != nil {
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
