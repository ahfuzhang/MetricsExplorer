package httpserver

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/VictoriaMetrics/metrics"

	metricsexplorer "github.com/ahfuzhang/MetricsExplorer"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api/datasource"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api/menu"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api/metricdata"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/api/user"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/middleware"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

type Server struct {
	httpServer *http.Server
}

func New() *Server {
	var cfg *pb.ReadonlyMetricsExplorerConfigs = config.Get()
	mux := http.NewServeMux()
	mux.HandleFunc("/ping", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("pong"))
	})

	pathPrefix := cfg.Http.Path
	if pathPrefix == "" {
		pathPrefix = "/"
	} else {
		if pathPrefix[0] != '/' {
			pathPrefix = "/" + pathPrefix
		}
		if pathPrefix[len(pathPrefix)-1] != '/' {
			pathPrefix = pathPrefix + "/"
		}
	}
	mux.HandleFunc(pathPrefix+"api/v1/get_global_configs", api.GetGlobalConfigs(cfg))
	mux.HandleFunc(pathPrefix+"api/v1/login", api.Login())
	mux.HandleFunc(pathPrefix+"api/v1/logout", api.Logout())
	mux.HandleFunc(pathPrefix+"api/v1/add_user", user.AddUser())
	mux.HandleFunc(pathPrefix+"api/v1/list_user", user.ListUser())
	mux.HandleFunc(pathPrefix+"api/v1/remove_user", user.RemoveUser())
	mux.HandleFunc(pathPrefix+"api/v1/list_datasource", datasource.ListDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/add_datasource", datasource.AddDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/remove_datasource", datasource.RemoveDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/list_menu", menu.ListMenu())
	mux.HandleFunc(pathPrefix+"api/v1/load_menu", menu.LoadMenu())
	mux.HandleFunc(pathPrefix+"api/v1/add_menu", menu.AddMenu())
	mux.HandleFunc(pathPrefix+"api/v1/remove_menu", menu.RemoveMenu())
	mux.HandleFunc(pathPrefix+"api/v1/modify_menu", menu.ModifyMenu())
	mux.HandleFunc(pathPrefix+"api/v1/get_labels_by_datasource", metricdata.GetLabelsByDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/get_metric_names_by_datasource", metricdata.GetMetricNamesByDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/get_series_by_datasource", metricdata.GetSeriesByDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/get_range_by_datasource", metricdata.GetRangeByDatasource())
	mux.HandleFunc(pathPrefix+"api/v1/get_pods_by_datasource", metricdata.GetPodsByDatasource())

	indexTarget := pathPrefix + "web/index.html"
	mux.HandleFunc(pathPrefix, func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, indexTarget, http.StatusFound)
	})
	mux.HandleFunc(pathPrefix+"index.html", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, indexTarget, http.StatusFound)
	})

	webPrefix := pathPrefix + "web/"
	mux.Handle(webPrefix, http.StripPrefix(webPrefix, http.FileServer(http.FS(metricsexplorer.WebFS()))))

	mux.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		metrics.WritePrometheus(w, true)
	})

	var protocols http.Protocols
	protocols.SetHTTP1(true)
	protocols.SetHTTP2(true)

	srv := &http.Server{
		Addr:      fmt.Sprintf(":%d", cfg.Http.Port),
		Handler:   middleware.Compress(mux),
		Protocols: &protocols,
	}
	log.Println("init web server ok")
	return &Server{httpServer: srv}
}

// Start begins listening and blocks until the server stops.
func (s *Server) Start() error {
	ln, err := net.Listen("tcp", s.httpServer.Addr)
	if err != nil {
		return err
	}
	return s.httpServer.Serve(ln)
}

func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}
