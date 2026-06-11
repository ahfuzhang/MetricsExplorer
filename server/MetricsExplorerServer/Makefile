
init:
	go mod init github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer

build:
	go build -o ../../build/MetricsExplorerServer main.go

run:
	../../build/MetricsExplorerServer \
	  -config.file=MetricsExplorerServer.yaml \
	  -metrics.push.addr="http://127.0.0.1:8428/api/v1/import/prometheus?extra_label=env=prod&extra_label=app=demo&pod=metrics-explorer-server-1" \
	  -metrics.push.interval.seconds=1

firewall:
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw \
    --add /Users/ahfu/code/github.com/ahfuzhang/MetricsExplorer/build/MetricsExplorerServer
	