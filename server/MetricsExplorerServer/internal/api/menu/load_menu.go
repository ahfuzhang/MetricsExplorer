package menu

import (
	"fmt"
	"net/http"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func LoadMenu() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := api.Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyLoadMenuTreeRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, root pb.MenuTreeNode) {
			rsp := &pb.LoadMenuTreeResponse{Code: code, Message: msg, Menus: root}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		user, code, msg := api.Auth(req.Session, false)
		if code != 0 {
			respond(code, msg, pb.MenuTreeNode{})
			return
		}
		// u, ok := api.OnlineUsers.Load(req.Session)
		// if !ok {
		// 	respond(1, "invalid session", pb.MenuTreeNode{})
		// 	return
		// }
		isAdmin := user.UserName == config.Get().Admin.Name

		db := global.GetMysql()
		rows, err := db.Query(
			"SELECT menu_id, menu_name, parent_id, link, target, bit_flags FROM menus ORDER BY menu_id LIMIT 10000",
		)
		if err != nil {
			respond(2, "database error: "+err.Error(), pb.MenuTreeNode{})
			return
		}
		defer rows.Close()

		type menuRow struct {
			menuID   uint64
			menuName string
			parentID uint64
			link     string
			target   string
			bitFlags uint64
		}

		allRows := make([]menuRow, 0, 64)
		for rows.Next() {
			var m menuRow
			if err = rows.Scan(&m.menuID, &m.menuName, &m.parentID, &m.link, &m.target, &m.bitFlags); err != nil {
				respond(3, "scan error: "+err.Error(), pb.MenuTreeNode{})
				return
			}
			allRows = append(allRows, m)
		}
		if err = rows.Err(); err != nil {
			respond(4, "rows error: "+err.Error(), pb.MenuTreeNode{})
			return
		}
		var maxMenuID uint64
		childrenOf := make(map[uint64][]menuRow, len(allRows))
		idToRow := make(map[uint64]menuRow, len(allRows))
		isAdminOnly := func(m menuRow) bool {
			return m.menuName == "Admin" || m.menuName == "Users" || m.menuName == "Menus" || m.menuName == "Datasources"
		}
		for _, m := range allRows {
			if !isAdmin && isAdminOnly(m) {
				continue
			}
			if m.menuID > maxMenuID {
				maxMenuID = m.menuID
			}
			idToRow[m.menuID] = m
			childrenOf[m.parentID] = append(childrenOf[m.parentID], m)
		}

		visited := make(map[uint64]struct{}, len(allRows))
		var buildNode func(m menuRow) pb.MenuTreeNode
		buildNode = func(m menuRow) pb.MenuTreeNode {
			visited[m.menuID] = struct{}{}
			node := pb.MenuTreeNode{
				MenuId:   m.menuID,
				MenuName: m.menuName,
				Link:     m.link,
				Target:   m.target,
				BitFlags: m.bitFlags,
			}
			for _, child := range childrenOf[m.menuID] {
				if _, seen := visited[child.menuID]; seen {
					continue
				}
				node.Children = append(node.Children, buildNode(child))
			}
			return node
		}

		root, exists := idToRow[1]
		if !exists {
			respond(5, "root menu not found", pb.MenuTreeNode{})
			return
		}
		menus := buildNode(root)
		AddMetricDataSources(&menus, maxMenuID)
		respond(0, "success", menus)
	}
}

func AddMetricDataSources(menu *pb.MenuTreeNode, maxMenuID uint64) {
	maxMenuID += 10000
	getMenuID := func() uint64 {
		maxMenuID++
		return maxMenuID
	}
	for i, item := range menu.Children {
		if item.MenuName == "Metric Data Sources" {
			// 这里加入 metrics 数据源
			global.AllDataSources.Range(func(key, value any) bool {
				name, ok1 := key.(string)
				ds, ok2 := value.(*global.DataSourceClient)
				if ok1 && ok2 {
					item.Children = append(item.Children, pb.MenuTreeNode{
						MenuName: name,
						MenuId:   getMenuID(),
						Link:     fmt.Sprintf(`{"id":%d,"name":"%s"}`, ds.ID, name),
						Target:   "content",
						BitFlags: 1, // Set the bit flag for expanded state
						Children: []pb.MenuTreeNode{
							//
							pb.MenuTreeNode{
								MenuName: "Labels",
								MenuId:   getMenuID(),
								Link:     fmt.Sprintf(`{"id":%d,"name":"%s"}`, ds.ID, name),
								Target:   "content",
							},
							pb.MenuTreeNode{
								MenuName: "Metric Names",
								MenuId:   getMenuID(),
								Link:     fmt.Sprintf(`{"id":%d,"name":"%s"}`, ds.ID, name),
								Target:   "content",
							},
							pb.MenuTreeNode{
								MenuName: "Pods",
								MenuId:   getMenuID(),
								Link:     fmt.Sprintf(`{"id":%d,"name":"%s"}`, ds.ID, name),
								Target:   "content",
							},
						},
					})
				}
				return true
			})
			menu.Children[i] = item
			break
		}
	}
}
