package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	victoriametrics "github.com/VictoriaMetrics/metrics"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/httpserver"
)

func main() {
	log.SetFlags(log.Lshortfile | log.LstdFlags)
	configFile := flag.String("config.file", "./MetricsExplorerServer.yaml", "path to config file")
	metricsPushAddr := flag.String("metrics.push.addr", "", "URL to push metrics to (e.g. http://victoria-metrics:8428/api/v1/import/prometheus)")
	metricsPushInterval := flag.Int("metrics.push.interval.seconds", 15, "interval in seconds between metrics pushes")
	flag.Parse()

	if *metricsPushAddr != "" {
		interval := time.Duration(*metricsPushInterval) * time.Second
		if err := victoriametrics.InitPush(*metricsPushAddr, interval, "", true); err != nil {
			fmt.Fprintf(os.Stderr, "init metrics push failed: %v\n", err)
			os.Exit(1)
		}
	}

	if err := config.Load(*configFile); err != nil {
		fmt.Fprintf(os.Stderr, "read config file %s failed: %v\n", *configFile, err)
		os.Exit(1)
	}
	if err := global.InitMysql(); err != nil {
		log.Fatalln(err)
		return
	}
	// 初始化所有的数据源
	if err := global.LoadAllMetricsDataSources(); err != nil {
		log.Fatalln(err)
		return
	}
	srv := httpserver.New()
	fmt.Printf("listening on port %d\n", config.Get().Http.Port)
	if err := srv.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "http server error: %v\n", err)
		os.Exit(1)
	}
}
