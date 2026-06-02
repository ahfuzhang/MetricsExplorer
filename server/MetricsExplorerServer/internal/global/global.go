package global

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
)

var globalMysql *sql.DB

func InitMysql() error {
	cfg := config.Get()
	db, err := sql.Open("mysql", cfg.Mysql.Dsn)
	if err != nil {
		return fmt.Errorf("open mysql fail, err=%+v", err)
	}
	if err = db.Ping(); err != nil {
		return fmt.Errorf("ping mysql fail, err=%+v", err)
	}
	globalMysql = db
	return nil
}

func GetMysql() *sql.DB {
	return globalMysql
}
