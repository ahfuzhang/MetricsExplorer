package menu

import (
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func ListMenu() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyGetMenuListRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, menus []pb.Menu) {
			rsp := &pb.GetMenuListResponse{Code: code, Message: msg, Menus: menus}
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
			"SELECT menu_id, menu_name, parent_id, role_id, link, target, bit_flags FROM menus ORDER BY menu_id LIMIT 10000",
		)
		if err != nil {
			respond(2, "database error: "+err.Error(), nil)
			return
		}
		defer rows.Close()

		menus := make([]pb.Menu, 0, 64)
		for rows.Next() {
			var m pb.Menu
			if err = rows.Scan(&m.MenuId, &m.MenuName, &m.ParentId, &m.RoleId, &m.Link, &m.Target, &m.BitFlags); err != nil {
				respond(3, "scan error: "+err.Error(), nil)
				return
			}
			menus = append(menus, m)
		}
		if err = rows.Err(); err != nil {
			respond(4, "rows error: "+err.Error(), nil)
			return
		}

		respond(0, "success", menus)
	}
}
