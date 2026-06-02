package config

import (
	"fmt"
	"os"

	metrics_explorer "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
	"gopkg.in/yaml.v3"
)

var globalConfig metrics_explorer.ReadonlyConfigs

func Load(f string) error {
	data, err := os.ReadFile(f)
	if err != nil {
		return fmt.Errorf("read config file %s fail, err=%+v", f, err)
	}

	if err := yaml.Unmarshal(data, &globalConfig); err != nil {
		return fmt.Errorf("parse config file %s fail, err=%+v", f, err)
	}
	return nil
}

func Get() *metrics_explorer.ReadonlyMetricsExplorerConfigs {
	return &globalConfig.MetricsExplorer
}
