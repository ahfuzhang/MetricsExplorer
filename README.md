
# [WIP]MetricsExplorer

I hate spending time creating Grafana dashboards. So I'm going to create a tool that lets me browse metrics data without writing PromQL.

> 我恨死了花时间去做 grafana dashboard.所以我准备做一个不用写 promql 就能浏览 metrics 数据的工具。

# Plan & Design

## 前端

* 使用 flutter 框架来制作 UI
  - 一期支持(非移动端的) WEB UI
  - 二期支持 macos/windows 的 native APP
  - 三期支持 android / ios
* 第一个界面是登录界面
  - 填写服务器的 URL，允许包含路径
  - 填写用户名/密码, 或者填写 APP KEY
  - 默认勾选保存按钮
  - 选择配置文件的保存位置，默认是 ${HOME}/MetricsExplorer.yaml
* 第二个界面是主界面
  - 左侧 20% 是导航栏
    - 采用类似 TreeView 的控件
    - 菜单树由服务器生成
  - 右侧 80% 是内容区域  
* 表格数据
  - 提供类似 DataGrid 的组件来展示表格，支持分页、客户端排序等能力
  - 表格的配置，来自服务器端的 JSON/protobuf 数据
* 通讯协议
  - 支持 protobuf 格式的二进制数据

### 菜单树

* 所有人
  - 登录
  - 退出登录
* 管理员
  - 用户
    - 浏览用户
    - 添加用户
    - 修改用户
    - 删除用户
  - 数据源
    - 浏览数据源
    - 添加数据源
    - 删除数据源
    - 测试数据源
  - 权限配置
    - 用户与数据源的匹配关系
* 用户
  - 显示数据源的菜单树
  - 配置 APP KEY
* 数据源
  - 点击某个数据源开始浏览

### 数据源浏览

* 参考资料
  - https://docs.victoriametrics.com/victoriametrics/url-examples/
* 查询标签
  - https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1labels

```bash
curl http://<vmselect>:8481/select/0/prometheus/api/v1/labels
```

* 查询标签的值
  - https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1labelvalues

```bash
curl http://<vmselect>:8481/select/0/prometheus/api/v1/label/job/values
```

* instant query
  - https://docs.victoriametrics.com/victoriametrics/keyconcepts/#instant-query

```bash
curl "http://<victoria-metrics-addr>/api/v1/query?query=foo_bar&time=2022-05-10T08:03:00.000Z"
```

* range query
  - https://docs.victoriametrics.com/victoriametrics/keyconcepts/#range-query

```bash
curl "http://<victoria-metrics-addr>/api/v1/query_range?query=foo_bar&step=1m&start=2022-05-10T07:59:00.000Z&end=2022-05-10T08:17:00.000Z"
```

* query series
  - https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1series

```bash
curl http://<vmselect>:8481/select/0/prometheus/api/v1/series -d 'match[]=vm_http_request_errors_total'
```

* meta data
  - https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1metadata

```bash
curl -X GET http://<vmselect>:8481/select/0/prometheus/api/v1/metadata
```

### UI 交互功能

* 时间范围选择
* 标签过滤
* 多曲线
* 双坐标轴
* 单位选择



## 后端

* 使用 golang 1.24 开发后端
* 支持 http1 和 http2 h2c

### 配置文件

* salt: 用于密码加盐的字符串
* rules.yaml
  - 只要发现某个规律，就把这个规律写入 yaml 中

### 数据库

* 使用 mysql 存储各种配置
  - 用户表：主要是用户名和密码
  - menu: 菜单树的配置
  - metric data source: 数据源的配置
  - user profile: 用户自定义的界面配置
  - dash board 配置

### 鉴权

* session 鉴权
* app key 鉴权

### metrics

* 自动识别常数
  - 值一直保持不变
* 自动识别 counter
  - 如果后面的值都不小于前面的值，则就是 counter
  - 名字存在 _total
  - 进一步的单位的识别
    - _bytes_total 以字节数为单位
    - _seconds_total 以秒为单位
* 自动识别 histogram
  - 存在 _bucket, _sum, _count
  - 自动绘制 heat map
  - 自动绘制 p95, p99
  - 识别单位
    - _seconds_bucket: 以秒为单位

### local cache

使用 fastcache，缓存所有从 VictoriaMetrics 得到的数据。

### 常见经验的模式总结

对已知的 metric，直接绘制最佳的图形展示效果。

* 微服务层面
  - cpu
  - 内存
  - 磁盘
  - 网络
  - runtime

* 机器层面 (node)
  - cpu
  - 内存
  - 磁盘
  - 网络

* 常见的组件
  - istio
  - apisix
  - haproxy
  - mysql
  - redis

### 其他

* 选择 step
* 选择单位
* 选择时间窗口  xx/min, xx/s

# 高级功能

* 整理好的 dashboard，导出为 grafana 的 dashboard
* 规则数据库：一个 metrics, 识别过一次之后，大家都知道那是什么了
* native client 的 GPU 渲染
* 服务器端渲染：利用服务器强大的 cpu 和内存，提前把曲线图绘制成图片
  - 致敬: monitor.server.com

## 性能

* 使用 protobuf
* 使用 zstd 压缩
* local cache，空间换时间

# License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Fuchun Zhang
