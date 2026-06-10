import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';
import 'counter_chart.dart';
import 'heatmap.dart';

class RangeQueryPanel extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;

  const RangeQueryPanel({
    super.key,
    required this.session,
    required this.datasource,
  });

  @override
  State<RangeQueryPanel> createState() => RangeQueryPanelState();
}

class RangeQueryPanelState extends State<RangeQueryPanel> {
  final _scrollCtrl = ScrollController();
  bool _loading = false;
  bool _refreshing = false;
  String? _error;
  String? _resultJson;
  String? _metricKind;

  // Shared chart state (Counter and Gauge reuse the same widget/data)
  String? _counterQuery;
  String? _gaugeQuery;
  bool _counterLoading = false;
  String? _counterError;
  List<int>? _counterTimestamps;
  List<SeriesData>? _counterSeries;
  // Unit suffix shown in tooltip: '/s', '/min', or '' (Gauge)
  String _chartUnit = '';

  // Static metric table state
  List<({double value, Map<String, String> tags})>? _staticSeries;

  // Tags extracted from the initial range query, used by the Counter tags panel.
  // (The counter chart query uses `sum by ()` which strips all labels.)
  List<Map<String, String>>? _rawCounterTagsList;

  // Histogram heatmap state
  List<int>? _histogramTimestamps;
  List<BucketData>? _histogramBuckets;
  List<String>? _histogramQueries;

  // Time range controls (Counter / Gauge bar)
  static const _startOptions = [
    'now-5m', 'now-10m', 'now-15m', 'now-30m',
    'now-1h', 'now-3h', 'now-6h',
    'now-1d', 'now-2d', 'now-3d', 'now-7d',
  ];
  static const _endOptions = ['now'];

  final _startCtrl = TextEditingController(text: 'now-30m');
  final _endCtrl   = TextEditingController(text: 'now');
  final _stepCtrl  = TextEditingController(text: '60');

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  void setCounterQuery(String? query) {
    _counterQuery = query;
  }

  void setGaugeQuery(String? query) {
    _gaugeQuery = query;
  }

  int _parseTimeExpr(String expr) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final s = expr.trim();
    if (s == 'now') return now;
    final m = RegExp(r'^now-(\d+)(m|h|d)$').firstMatch(s);
    if (m != null) {
      final n = int.parse(m.group(1)!);
      final unit = m.group(2)!;
      final secs = unit == 'm' ? n * 60 : unit == 'h' ? n * 3600 : n * 86400;
      return now - secs;
    }
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;
    final dt = DateTime.tryParse(s);
    if (dt != null) return dt.millisecondsSinceEpoch ~/ 1000;
    return now;
  }

  void _onRefresh() {
    if (_metricKind == 'Counter') {
      _fetchCounterChart(isRefresh: true);
    } else if (_metricKind == null && _gaugeQuery != null) {
      _fetchGaugeChart(isRefresh: true);
    } else if (_metricKind == 'Histogram') {
      _fetchHistogramChart(isRefresh: true);
    }
  }

  String? _detectMetricKind(GetRangeByDatasourceResponse decoded) {
    final nameValues = <String>{};
    for (final qr in decoded.queriesResult) {
      for (final d in qr.datas) {
        final name = d.tags['__name__'];
        if (name != null && name.isNotEmpty) nameValues.add(name);
      }
    }
    if (nameValues.isNotEmpty) {
      const suffixes = ['_bucket', '_count', '_sum'];
      final prefixes = <String>{};
      var allMatch = true;
      for (final name in nameValues) {
        String? matched;
        for (final s in suffixes) {
          if (name.endsWith(s)) {
            matched = s;
            break;
          }
        }
        if (matched == null) {
          allMatch = false;
          break;
        }
        prefixes.add(name.substring(0, name.length - matched.length));
      }
      final hasBucket = nameValues.any((n) => n.endsWith('_bucket'));
      if (allMatch && prefixes.length == 1 && hasBucket) return 'Histogram';
    }

    final types = <MetricType>{};
    for (final qr in decoded.queriesResult) {
      for (final d in qr.datas) {
        types.add(d.metricType);
      }
    }
    if (types.isNotEmpty) {
      if (types.every((t) => t == MetricType.StaticValue)) return 'Static';
      if (types.every((t) => t == MetricType.Counter || t == MetricType.StaticValue) &&
          types.contains(MetricType.Counter)) {
        return 'Counter';
      }
    }
    return null;
  }

  Future<void> fetchData(List<String> queries) async {
    if (queries.isEmpty) {
      setState(() {
        _resultJson = null;
        _error = null;
        _metricKind = null;
        _counterTimestamps = null;
        _counterSeries = null;
        _counterError = null;
        _counterLoading = false;
      });
      return;
    }
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final startSec = nowSec - 1800;

    setState(() {
      _loading = true;
      _error = null;
      _resultJson = null;
      _metricKind = null;
      _counterTimestamps = null;
      _counterSeries = null;
      _chartUnit = '';
      _counterError = null;
      _counterLoading = false;
      _staticSeries = null;
      _rawCounterTagsList = null;
      _histogramTimestamps = null;
      _histogramBuckets = null;
      _histogramQueries = null;
    });
    try {
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: queries,
        start: startSec.toString(),
        end: nowSec.toString(),
        step: '1m',
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_range_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded =
            GetRangeByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          final jsonObj = {
            'timestamps': decoded.timestamps.map((t) => t.toInt()).toList(),
            'results': List.generate(decoded.queriesResult.length, (i) {
              final qr = decoded.queriesResult[i];
              return {
                'query': i < queries.length ? queries[i] : '',
                'code': qr.code,
                if (qr.message.isNotEmpty) 'message': qr.message,
                'series': qr.datas.map((d) => <String, dynamic>{
                  'tags': Map<String, String>.from(d.tags),
                  if (d.points.isNotEmpty)
                    'points': d.points.toList()
                  else
                    'const_value': d.hasConstValue() ? d.constValue : 0.0,
                }).toList(),
              };
            }),
          };
          final kind = _detectMetricKind(decoded);
          setState(() {
            _resultJson = const JsonEncoder.withIndent('  ').convert(jsonObj);
            _metricKind = kind;
            _staticSeries = kind == 'Static'
                ? _extractStaticSeries(decoded)
                : null;
            _rawCounterTagsList = kind == 'Counter'
                ? [
                    for (final qr in decoded.queriesResult)
                      for (final d in qr.datas)
                        Map<String, String>.from(d.tags)
                  ]
                : null;
          });
          if (kind == 'Counter') {
            _fetchCounterChart();
          } else if (kind == null) {
            _fetchGaugeChart();
          } else if (kind == 'Histogram') {
            setState(() => _histogramQueries = queries);
            _prepareHistogramData(decoded);
          }
        } else {
          setState(() {
            _error = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() =>
            _error = 'HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchCounterChart({bool isRefresh = false}) async {
    final query = _counterQuery;
    if (query == null) return;

    if (isRefresh) {
      setState(() {
        _refreshing = true;
        _counterError = null;
      });
    } else {
      setState(() {
        _counterLoading = true;
        _counterError = null;
        _counterTimestamps = null;
        _counterSeries = null;
        _chartUnit = '';
      });
    }

    // Executes one range request; sets _counterError and returns null on failure.
    Future<GetRangeByDatasourceResponse?> doFetch(String q) async {
      final startSec = _parseTimeExpr(_startCtrl.text);
      final endSec   = _parseTimeExpr(_endCtrl.text);
      final stepVal  = int.tryParse(_stepCtrl.text.trim()) ?? 60;
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: [q],
        start: startSec.toString(),
        end: endSec.toString(),
        step: '${stepVal}s',
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_range_by_datasource');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (resp.statusCode != 200) {
        if (mounted) setState(() => _counterError = 'HTTP ${resp.statusCode}');
        return null;
      }
      final decoded = GetRangeByDatasourceResponse.fromBuffer(resp.bodyBytes);
      if (decoded.code != 0) {
        if (mounted) {
          setState(() => _counterError = decoded.message.isNotEmpty
              ? decoded.message
              : 'No data');
        }
        return null;
      }
      return decoded;
    }

    try {
      // First fetch with rate (per-second) query.
      var decoded = await doFetch(query);
      if (decoded == null || !mounted) return;

      var unit = '/s';

      // If >50% of all data points are < 1, switch to increase (per-minute).
      int total = 0, belowOne = 0;
      for (final qr in decoded.queriesResult) {
        for (final d in qr.datas) {
          for (final v in d.points) {
            total++;
            if (v < 1) belowOne++;
          }
        }
      }
      if (total > 0 && belowOne * 2 > total) {
        final increaseQuery = query.replaceFirst('rate(', 'increase(');
        final decoded2 = await doFetch(increaseQuery);
        if (decoded2 == null || !mounted) return;
        decoded = decoded2;
        unit = '/min';
      }

      final ts = decoded.timestamps.map((t) => t.toInt()).toList();
      final series = _parseSeries(decoded);

      if (mounted) {
        setState(() {
          _counterTimestamps = ts;
          _counterSeries = series;
          _chartUnit = unit;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _counterError = 'Error: $e');
    } finally {
      if (mounted) setState(() { _counterLoading = false; _refreshing = false; });
    }
  }

  List<({String label, List<double> points, Map<String, String> tags})> _parseSeries(
      GetRangeByDatasourceResponse decoded) {
    if (decoded.queriesResult.isEmpty) return [];
    return decoded.queriesResult[0].datas
        .where((d) => d.points.isNotEmpty)
        .map((d) {
          final name = d.tags['__name__'] ?? '';
          final others = d.tags.entries
              .where((e) => e.key != '__name__')
              .map((e) => '${e.key}="${e.value}"')
              .join(', ');
          final label = others.isEmpty ? name : '$name{$others}';
          return (label: label, points: d.points.toList(), tags: Map<String, String>.from(d.tags));
        })
        .toList();
  }

  Future<void> _fetchGaugeChart({bool isRefresh = false}) async {
    final query = _gaugeQuery;
    if (query == null) return;

    if (isRefresh) {
      setState(() {
        _refreshing = true;
        _counterError = null;
      });
    } else {
      setState(() {
        _counterLoading = true;
        _counterError = null;
        _counterTimestamps = null;
        _counterSeries = null;
        _chartUnit = '';
      });
    }

    try {
      final startSec = _parseTimeExpr(_startCtrl.text);
      final endSec   = _parseTimeExpr(_endCtrl.text);
      final stepVal  = int.tryParse(_stepCtrl.text.trim()) ?? 60;
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: [query],
        start: startSec.toString(),
        end: endSec.toString(),
        step: '${stepVal}s',
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_range_by_datasource');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (resp.statusCode != 200) {
        if (mounted) setState(() => _counterError = 'HTTP ${resp.statusCode}');
        return;
      }
      final decoded = GetRangeByDatasourceResponse.fromBuffer(resp.bodyBytes);
      if (decoded.code != 0) {
        if (mounted) {
          setState(() => _counterError = decoded.message.isNotEmpty
              ? decoded.message
              : 'No data');
        }
        return;
      }
      final ts = decoded.timestamps.map((t) => t.toInt()).toList();
      final series = _parseSeries(decoded);
      if (mounted) {
        setState(() {
          _counterTimestamps = ts;
          _counterSeries = series;
          // _chartUnit stays '' — Gauge shows raw values without a rate unit
        });
      }
    } catch (e) {
      if (mounted) setState(() => _counterError = 'Error: $e');
    } finally {
      if (mounted) setState(() { _counterLoading = false; _refreshing = false; });
    }
  }

  Future<void> _fetchHistogramChart({bool isRefresh = false}) async {
    final queries = _histogramQueries;
    if (queries == null || queries.isEmpty) return;

    if (isRefresh) {
      setState(() => _refreshing = true);
    } else {
      setState(() {
        _histogramTimestamps = null;
        _histogramBuckets = null;
      });
    }

    try {
      final startSec = _parseTimeExpr(_startCtrl.text);
      final endSec   = _parseTimeExpr(_endCtrl.text);
      final stepVal  = int.tryParse(_stepCtrl.text.trim()) ?? 60;
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: queries,
        start: startSec.toString(),
        end: endSec.toString(),
        step: '${stepVal}s',
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_range_by_datasource');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (resp.statusCode != 200) return;
      final decoded = GetRangeByDatasourceResponse.fromBuffer(resp.bodyBytes);
      if (decoded.code != 0) return;
      if (mounted) _prepareHistogramData(decoded);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  List<({double value, Map<String, String> tags})> _extractStaticSeries(
      GetRangeByDatasourceResponse decoded) {
    final result = <({double value, Map<String, String> tags})>[];
    for (final qr in decoded.queriesResult) {
      for (final d in qr.datas) {
        final value = d.hasConstValue() ? d.constValue : 0.0;
        result.add((value: value, tags: Map<String, String>.from(d.tags)));
      }
    }
    return result;
  }

  void _prepareHistogramData(GetRangeByDatasourceResponse decoded) {
    final timestamps = decoded.timestamps.map((t) => t.toInt()).toList();
    final n = timestamps.length;

    // Accumulate points per upper-bound, summing across series with same bound.
    final bucketMap = <double, List<double>>{};
    bool hasLe = false;

    for (final qr in decoded.queriesResult) {
      for (final d in qr.datas) {
        final name = d.tags['__name__'] ?? '';
        if (!name.endsWith('_bucket')) continue;
        if (d.points.isEmpty) continue;

        double? upperBound;
        final le = d.tags['le'];
        if (le != null) {
          if (le == '+Inf') continue;
          upperBound = double.tryParse(le);
          if (upperBound != null) hasLe = true;
        } else {
          final vmrange = d.tags['vmrange'];
          if (vmrange != null) {
            final parts = vmrange.split('...');
            if (parts.length >= 2) upperBound = double.tryParse(parts[1]);
          }
        }

        if (upperBound == null || upperBound.isInfinite || upperBound.isNaN) continue;

        final existing = bucketMap.putIfAbsent(upperBound, () => List.filled(n, 0.0));
        for (int i = 0; i < d.points.length && i < n; i++) {
          existing[i] += d.points[i];
        }
      }
    }

    if (bucketMap.isEmpty) {
      setState(() {
        _histogramTimestamps = timestamps;
        _histogramBuckets = [];
      });
      return;
    }

    final sortedBounds = bucketMap.keys.toList()..sort();
    var buckets = sortedBounds.map((bound) => BucketData(
      upperBound: bound,
      points: List<double>.from(bucketMap[bound]!),
      tagLabel: _formatAxisValue(bound),
    )).toList();

    // Prometheus cumulative buckets: compute per-bucket differential counts.
    if (hasLe) {
      for (int i = buckets.length - 1; i > 0; i--) {
        final curr = buckets[i].points;
        final prev = buckets[i - 1].points;
        buckets[i] = BucketData(
          upperBound: buckets[i].upperBound,
          tagLabel: buckets[i].tagLabel,
          points: List.generate(n, (j) {
            final d = curr[j] - prev[j];
            return d < 0 ? 0.0 : d;
          }),
        );
      }
    }

    setState(() {
      _histogramTimestamps = timestamps;
      _histogramBuckets = buckets;
    });
  }

  Widget _buildHeatmap() {
    const chartHeight = 240.0;
    final ts = _histogramTimestamps;
    final buckets = _histogramBuckets;

    if (ts == null || buckets == null || ts.isEmpty || buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    double minVal = double.infinity;
    double maxVal = -double.infinity;
    for (final b in buckets) {
      for (final v in b.points) {
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
      }
    }
    if (minVal == double.infinity) minVal = 0;
    if (maxVal == -double.infinity) maxVal = 0;

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
        child: HeatmapChart(
          timestamps: ts,
          buckets: buckets,
          minValue: minVal,
          maxValue: maxVal,
          formatValue: _formatAxisValue,
        ),
      ),
    );
  }

  // For a group of tag maps sharing the same constValue, returns one display
  // string per map after stripping tags that are identical across all maps.
  List<String> _computeDiffLabels(List<Map<String, String>> tagMaps) {
    if (tagMaps.isEmpty) return [];

    if (tagMaps.length == 1) {
      final label = tagMaps.first.entries
          .where((e) => e.key != '__name__')
          .map((e) => '${e.key}="${e.value}"')
          .join(', ');
      return [label];
    }

    // Build the common map from the first entry, then whittle it down.
    final common = Map.fromEntries(
      tagMaps.first.entries.where((e) => e.key != '__name__'),
    );
    for (final m in tagMaps.skip(1)) {
      common.removeWhere((k, v) => m[k] != v);
    }

    return tagMaps.map((m) {
      final diff = m.entries
          .where((e) => e.key != '__name__' && common[e.key] != e.value)
          .map((e) => '${e.key}="${e.value}"')
          .join(', ');
      return diff;
    }).toList();
  }

  Widget _buildStaticTable() {
    final series = _staticSeries;
    if (series == null || series.isEmpty) return const SizedBox.shrink();

    // Group by value.
    final groups = <double, List<Map<String, String>>>{};
    for (final s in series) {
      groups.putIfAbsent(s.value, () => []).add(s.tags);
    }

    final sortedValues = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    // Build row data: one entry per unique value.
    final rows = <({List<String> labels, double value})>[];
    if (sortedValues.length == 1) {
      rows.add((labels: ['All'], value: sortedValues.first));
    } else {
      for (final v in sortedValues) {
        rows.add((
          labels: _computeDiffLabels(groups[v]!),
          value: v,
        ));
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows.map((row) => TableRow(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: row.labels.map((lbl) => SelectableText(
                    lbl.isEmpty ? '(all same)' : lbl,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF1565C0),
                    ),
                  )).toList(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  _formatAxisValue(row.value),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildSeriesTagsPanel() {
    final tagsList = _rawCounterTagsList;
    if (tagsList == null || tagsList.isEmpty) return const SizedBox.shrink();
    final n = tagsList.length;

    // Count occurrences of each tag value (exclude __name__)
    final tagValueCounts = <String, Map<String, int>>{};
    for (final tags in tagsList) {
      for (final entry in tags.entries) {
        if (entry.key == '__name__') continue;
        final vc = tagValueCounts.putIfAbsent(entry.key, () => {});
        vc[entry.value] = (vc[entry.value] ?? 0) + 1;
      }
    }

    if (tagValueCounts.isEmpty) return const SizedBox.shrink();

    // Separate tags where all series share the same single value (common)
    final commonParts = <String>[];
    final variableTagNames = <String>[];
    for (final entry in tagValueCounts.entries) {
      final valueCounts = entry.value;
      if (valueCounts.length == 1 && valueCounts.values.first == n) {
        commonParts.add('${entry.key}=${valueCounts.keys.first}');
      } else {
        variableTagNames.add(entry.key);
      }
    }

    // Sort variable tags by distinct value count descending
    variableTagNames.sort((a, b) =>
        tagValueCounts[b]!.length.compareTo(tagValueCounts[a]!.length));

    return Scrollbar(
      controller: _scrollCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4FB),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (commonParts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SelectableText(
                    commonParts.join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ...variableTagNames.map((tagName) {
                final sortedValues = tagValueCounts[tagName]!.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$tagName=[',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF333333),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: sortedValues.map((ve) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAF6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              '${ve.key}(${ve.value})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Color(0xFF333333),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                      const Text(
                        ']',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComboField({
    required TextEditingController ctrl,
    required List<String> options,
    double width = 130,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          suffixIconConstraints: const BoxConstraints(maxWidth: 24, maxHeight: 30),
          suffixIcon: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_drop_down, size: 18),
            onSelected: (v) => ctrl.text = v,
            itemBuilder: (_) => options
                .map((o) => PopupMenuItem<String>(
                      value: o,
                      height: 36,
                      child: Text(o, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text('Start:', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          _buildComboField(ctrl: _startCtrl, options: _startOptions, width: 125),
          const SizedBox(width: 10),
          const Text('End:', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          _buildComboField(ctrl: _endCtrl, options: _endOptions, width: 80),
          const SizedBox(width: 10),
          const Text('Step:', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          SizedBox(
            width: 56,
            child: TextField(
              controller: _stepCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text('seconds', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Refresh', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindLabel(String label, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: bgColor,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatAxisValue(double v) {
    if (v.abs() >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}G';
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    if (v.abs() < 0.001 && v != 0) return v.toStringAsExponential(2);
    return v.toStringAsFixed(3);
  }

  Widget _buildCounterChart() => CounterChart(
    isLoading: _counterLoading,
    error: _counterError,
    timestamps: _counterTimestamps ?? [],
    series: _counterSeries ?? [],
    unit: _chartUnit,
    formatValue: _formatAxisValue,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FD),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timeline, size: 16, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 8),
                if (_refreshing) ...[
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else
                  const Text(
                    'Range Data (last 30 min)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _error!,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: 'monospace'),
                ),
              ),
            )
          else if (_resultJson == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Click a metric name to load range data',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else ...[
            if (_metricKind == 'Counter') ...[
              _buildTimeRangeBar(),
              _buildCounterChart(),
              _buildKindLabel(
                'Counter  ·  ${_chartUnit == '/min' ? 'per minute' : 'per second'}',
                Colors.red.shade50,
                Colors.red,
              ),
              Expanded(child: _buildSeriesTagsPanel()),
            ] else if (_metricKind == null) ...[
              // Undetected type → treat as Gauge
              _buildTimeRangeBar(),
              _buildCounterChart(),
              _buildKindLabel('Gauge', Colors.teal.shade50, Colors.teal),
              Expanded(
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _resultJson!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (_metricKind == 'Histogram') ...[
              _buildTimeRangeBar(),
              _buildHeatmap(),
              _buildKindLabel('Histogram', Colors.purple.shade50, Colors.purple),
              Expanded(
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _resultJson!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              if (_metricKind == 'Static') _buildStaticTable(),
              _buildKindLabel(_metricKind!, Colors.red.shade50, Colors.red),
              Expanded(
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _resultJson!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
