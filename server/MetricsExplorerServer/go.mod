module github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer

go 1.25.0

require (
	github.com/VictoriaMetrics/metrics v1.43.2
	github.com/ahfuzhang/MetricsExplorer v0.0.0
	github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer v0.0.0
	github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api v0.0.0
	github.com/go-sql-driver/mysql v1.10.0
	github.com/google/uuid v1.6.0
	github.com/klauspost/compress v1.18.6
	gopkg.in/yaml.v3 v3.0.1
)

require (
	filippo.io/edwards25519 v1.2.0 // indirect
	github.com/ahfuzhang/BaoHuLu v0.11.0 // indirect
	github.com/valyala/fastrand v1.1.0 // indirect
	github.com/valyala/histogram v1.2.0 // indirect
	golang.org/x/sync v0.20.0 // indirect
	golang.org/x/sys v0.38.0 // indirect
)

replace github.com/ahfuzhang/MetricsExplorer => ../../

replace github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer => ../generated/metrics_explorer

replace github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api => ../generated/victoria_metrics_api
