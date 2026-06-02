CREATE DATABASE `general_crud_db`
/*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */
;

use general_crud_db;

create table mysql_db_dsn(
    dsn_id bigint unsigned AUTO_INCREMENT not null comment 'dsn id',
    db_name varchar(100) default '' comment 'db_name',
    dsn varchar(500) default '' comment 'dsn',
    primary key (dsn_id),
    unique (db_name),
    unique (dsn)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'mysql db 的连接信息';

create table data_source(
    data_source_id bigint unsigned AUTO_INCREMENT not null comment 'data source id',
    data_source_name varchar(200) not null comment 'data source name',
    ds_type tinyint not null default 0 comment 'data source type, 1-mysql, 2-es',
    role_id bigint unsigned not null default 0 comment 'bind with role table',
    fields text not null comment 'yaml format, define schema',
    frontend_fields text not null comment 'yaml format, for frontend',
    frontend_js text not null comment 'javascript code for frontend',
    mysql_db_dsn_id bigint unsigned default 0 comment 'link to mysql_db_dsn',
    dsn varchar(500) not null default '' comment 'user/pass etc.Deprecated',
    primary key (data_source_id),
    unique index idx_data_source_name (data_source_name),
    foreign key (mysql_db_dsn_id) REFERENCES mysql_db_dsn(dsn_id)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;

/*
 alter table data_source add column mysql_db_dsn_id bigint unsigned default 0 comment 'link to mysql_db_dsn';
 ALTER TABLE data_source ADD CONSTRAINT fk_mysql_db_dsn_id FOREIGN KEY (mysql_db_dsn_id) REFERENCES mysql_db_dsn(dsn_id);
 */
create table data_view(
    view_id bigint unsigned AUTO_INCREMENT not null comment 'view id',
    data_view_name varchar(200) not null comment 'view name',
    data_source_id bigint unsigned not null comment 'point to data source id',
    creator bigint unsigned not null comment '',
    configs text not null comment 'yaml format, define data view',
    primary key (view_id),
    key idx_view_name(data_view_name, creator),
    foreign key (data_source_id) REFERENCES data_source(data_source_id) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = '';

create table log_mysql_db_dsn(
    op_type varchar(50) comment 'operator type: create, update, delete etc.',
    op_user varchar(200) comment 'operate user',
    op_time bigint comment 'oprate time, to milliseconds',
    dsn_id bigint unsigned comment 'dsn id',
    db_name varchar(100) default '' comment 'db_name',
    dsn varchar(500) default '' comment 'dsn'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 comment = 'mysql db 的连接信息';

create table log_data_source(
    op_type varchar(50) comment 'operator type: create, update, delete etc.',
    op_user varchar(200) comment 'operate user',
    op_time bigint comment 'oprate time, to milliseconds',
    data_source_id bigint unsigned comment 'data source id',
    data_source_name varchar(200) comment '',
    ds_type tinyint default 0 comment '',
    dsn varchar(500) comment '',
    role_id bigint unsigned default 0 comment '',
    fields text comment '',
    frontend_fields text comment 'yaml format, for frontend',
    frontend_js text comment 'javascript code for frontend',
    mysql_db_dsn_id bigint unsigned default 0 comment 'link to mysql_db_dsn'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 comment 'save old data before change';

/*
 alter table log_data_source add column mysql_db_dsn_id bigint unsigned default 0 comment 'link to mysql_db_dsn';
 */
create table log_data_view(
    op_type varchar(50) comment 'operator type: create, update, delete etc.',
    op_user varchar(200) comment 'operate user',
    op_time bigint comment 'oprate time, to milliseconds',
    view_id bigint unsigned comment '',
    data_view_name varchar(200) comment '',
    data_source_id bigint unsigned comment '',
    creator bigint unsigned comment '',
    configs text comment ''
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 comment = 'save old data before change';

/*
 INSERT INTO
 `general_crud_db`.`data_source` (
 `data_source_name`,
 `ds_type`,
 `dsn`,
 `role_id`,
 `fields`,
 `fe_fields`
 )
 VALUES
 (
 'general_crud_db.data_source.root',
 1,
 'root:123456@tcp(127.0.0.1:3306)/general_crud_db?tls=skip-verify&autocommit=true&timeout=10s',
 0,
 '',
 ''
 );
 */