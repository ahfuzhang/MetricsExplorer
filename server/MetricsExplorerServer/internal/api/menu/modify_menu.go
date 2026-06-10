package menu

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func ModifyMenu() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyModifyMenuRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.ModifyMenuResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}
		user, code, msg := api.Auth(req.Session, true)
		if code != 0 {
			respond(code, msg)
			return
		}

		if req.Menu.MenuId == 0 {
			respond(5, "menu_id is required")
			return
		}
		if req.Menu.MenuName == "" {
			respond(6, "menu_name is required")
			return
		}

		db := global.GetMysql()
		_, err = db.Exec(
			"INSERT INTO log_menus (op_user, op_type, op_time, menu_id, menu_name, parent_id, role_id, link, `target`, bit_flags) "+
				"SELECT ?, ?, UNIX_TIMESTAMP(), menu_id, menu_name, parent_id, role_id, link, `target`, bit_flags FROM menus WHERE menu_id = ?",
			user.UserName, "modify", req.Menu.MenuId,
		)
		if err != nil {
			respond(2, "log menu error: "+err.Error())
			return
		}
		result, err := db.Exec(
			"UPDATE menus SET menu_name=?, parent_id=?, role_id=?, link=?, target=?, bit_flags=? WHERE menu_id=?",
			req.Menu.MenuName, req.Menu.ParentId, req.Menu.RoleId, req.Menu.Link, req.Menu.Target, req.Menu.BitFlags, req.Menu.MenuId,
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
			respond(4, "menu not found")
			return
		}

		respond(0, "success")
	}
}
