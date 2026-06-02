-- 提供管理后台所需的基本表
CREATE DATABASE IF NOT EXISTS `metrics_explorer`
/*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */
;

use metrics_explorer;

-- 数据源表
create table IF NOT EXISTS `victoria_metrics_data_source`(
    vm_datasource_id bigint unsigned AUTO_INCREMENT not null comment 'victoria_metrics_data_source id',
    datasource_name varchar(200) not null comment 'datasource name',
    addr varchar(500) default '' comment 'http://127.0.0.1:8481/select/0/prometheus/',
    primary key (vm_datasource_id),
    unique (datasource_name),
    unique (addr)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'victoria_metrics_data_source';

/*
insert into victoria_metrics_data_source(datasource_name, addr) values ('local docker', 'http://127.0.0.1:8481');
insert into victoria_metrics_data_source(datasource_name, addr) values ('k9s port forward', 'http://127.0.0.1:8481/select/0/prometheus');
*/
