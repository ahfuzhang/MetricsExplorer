package menu

import (
	"io"
	"net/http"
	"strings"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func LoadMenu() http.HandlerFunc {
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

		req := &pb.ReadonlyLoadMenuTreeRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string, root pb.MenuTreeNode) {
			rsp := &pb.LoadMenuTreeResponse{Code: code, Message: msg, Menus: root}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		_, ok := api.OnlineUsers.Load(req.Session)
		if !ok {
			respond(1, "invalid session", pb.MenuTreeNode{})
			return
		}

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

		childrenOf := make(map[uint64][]menuRow, len(allRows))
		idToRow := make(map[uint64]menuRow, len(allRows))
		for _, m := range allRows {
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
				Expanded: m.bitFlags&1 == 1,
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

		respond(0, "success", buildNode(root))
	}
}
