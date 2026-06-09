-- 提供管理后台所需的基本表
CREATE DATABASE IF NOT EXISTS `metrics_explorer`
/*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */
;

use metrics_explorer;

-- 用户表，管理员的信息
create table IF NOT EXISTS `users`(
    user_id bigint unsigned AUTO_INCREMENT not null comment 'user id',
    user_name varchar(200) not null comment 'user name',
    `passwd` varchar(200) default '' comment 'user password, use sha256 hashcode',
    primary key (user_id),
    unique (user_name)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'admin users';

--insert into users(user_name, `passwd`) values('admin', '');

-- 角色信息
create table IF NOT EXISTS roles(
    role_id bigint unsigned AUTO_INCREMENT not null comment 'role id',
    role_name varchar(200) not null comment 'role name',
    primary key (role_id),
    unique (role_name)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'admin roles';

-- 权限信息
create table IF NOT EXISTS rights(
    right_id bigint unsigned AUTO_INCREMENT not null comment 'right id',
    right_name varchar(200) not null comment 'right name',
    primary key (right_id),
    unique (right_name)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'admin rights';

create table IF NOT EXISTS user_roles(
    user_id bigint unsigned not null comment 'user id',
    role_id bigint unsigned not null comment 'role id',
    primary key (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'user roles';

create table IF NOT EXISTS role_rights(
    role_id bigint unsigned not null comment 'role id',
    right_id bigint unsigned not null comment 'right id',
    primary key (role_id, right_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (right_id) REFERENCES rights(right_id)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'role rights';

create table IF NOT EXISTS menus(
    menu_id bigint unsigned AUTO_INCREMENT not null comment 'menu id',
    menu_name varchar(200) not null comment 'menu name',
    parent_id bigint unsigned default 0 comment 'parent id',
    role_id bigint unsigned default 0 comment 'needed role',
    link varchar(500) default '' comment 'url to jump',
    `target` varchar(50) default '' comment 'target window name(empty means open in tab),_blank means open in new window',
    bit_flags bigint unsigned default 0 comment 'node attributes: bit0-expand/collapse',
    primary key (menu_id)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 comment = 'menu tree';

create table IF NOT EXISTS log_menus(
    `op_user` varchar(100) default '',
    `op_type` varchar(100) default '',
    `op_time` bigint unsigned default 0,
    menu_id bigint unsigned not null comment 'menu id',
    menu_name varchar(200) not null comment 'menu name',
    parent_id bigint unsigned default 0 comment 'parent id',
    role_id bigint unsigned default 0 comment 'needed role',
    link varchar(500) default '' comment 'url to jump',
    `target` varchar(50) default '' comment 'target window name(empty means open in tab)',
    bit_flags bigint unsigned default 0 comment 'node attributes'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 comment = 'log menu tree';

/*
 alter table menus add column link varchar(500) default '' comment 'url to jump';
 alter table menus add column `target` varchar(50) default '' comment 'target window name(empty means open in tab)';
 
 alter table menus add column bit_flags bigint unsigned default 0 comment 'node attributes';
 alter table log_menus add column bit_flags bigint unsigned default 0 comment 'node attributes';
 */
insert into
    menus(menu_name, parent_id, role_id)
values
    ('root', 1, 0);

insert into
    menus(menu_name, parent_id, role_id, bit_flags, link, `target`)
values
    ('Admin', 1, 0, 1, '', 'content'),
      ('Users', 2, 0, 0, 'user', 'content'),
      ('Menus', 2, 0, 0, 'menus', 'content'),
      ('Data Sources', 2, 0, 0, 'data_source', 'content'),
    ('Metric Data Sources', 1, 0, 1, '', 'content');

/*
 alter table users add column passwd varchar(200) default '' comment 'user password, use sha256 hashcode';
 */
 
     