import 'dart:convert';
import 'dart:math' show max, min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';

const _kSeriesColors = [
  Color(0xFF5C6BC0),
  Color(0xFF26A69A),
  Color(0xFFFF7043),
  Color(0xFFAB47BC),
  Color(0xFF66BB6A),
  Color(0xFF42A5F5),
];

class _BucketData {
  final double upperBound;
  final List<double> points;
  final String tagLabel;
  _BucketData({required this.upperBound, required this.points, required this.tagLabel});
}

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
  String? _error;
  String? _resultJson;
  String? _metricKind;

  // Shared chart state (Counter and Gauge reuse the same widget/data)
  String? _counterQuery;
  String? _gaugeQuery;
  bool _counterLoading = false;
  String? _counterError;
  List<int>? _counterTimestamps;
  List<({String label, List<double> points, Map<String, String> tags})>? _counterSeries;
  // Unit suffix shown in tooltip: '/s', '/min', or '' (Gauge)
  String _chartUnit = '';
  int? _chartHoveredIndex;

  // Static metric table state
  List<({double value, Map<String, String> tags})>? _staticSeries;

  // Tags extracted from the initial range query, used by the Counter tags panel.
  // (The counter chart query uses `sum by ()` which strips all labels.)
  List<Map<String, String>>? _rawCounterTagsList;

  // Histogram heatmap state
  List<int>? _histogramTimestamps;
  List<_BucketData>? _histogramBuckets;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void setCounterQuery(String? query) {
    _counterQuery = query;
  }

  void setGaugeQuery(String? query) {
    _gaugeQuery = query;
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
      _chartHoveredIndex = null;
      _staticSeries = null;
      _rawCounterTagsList = null;
      _histogramTimestamps = null;
      _histogramBuckets = null;
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

  Future<void> _fetchCounterChart() async {
    final query = _counterQuery;
    if (query == null) return;

    setState(() {
      _counterLoading = true;
      _counterError = null;
      _counterTimestamps = null;
      _counterSeries = null;
      _chartUnit = '';
    });

    // Executes one range request; sets _counterError and returns null on failure.
    Future<GetRangeByDatasourceResponse?> doFetch(String q) async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: [q],
        start: (nowSec - 1800).toString(),
        end: nowSec.toString(),
        step: '1m',
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
      if (mounted) setState(() => _counterLoading = false);
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

  Future<void> _fetchGaugeChart() async {
    final query = _gaugeQuery;
    if (query == null) return;

    setState(() {
      _counterLoading = true;
      _counterError = null;
      _counterTimestamps = null;
      _counterSeries = null;
      _chartUnit = '';
    });

    try {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final request = GetRangeByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        queries: [query],
        start: (nowSec - 1800).toString(),
        end: nowSec.toString(),
        step: '1m',
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
      if (mounted) setState(() => _counterLoading = false);
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
    var buckets = sortedBounds.map((bound) => _BucketData(
      upperBound: bound,
      points: List<double>.from(bucketMap[bound]!),
      tagLabel: _formatAxisValue(bound),
    )).toList();

    // Prometheus cumulative buckets: compute per-bucket differential counts.
    if (hasLe) {
      for (int i = buckets.length - 1; i > 0; i--) {
        final curr = buckets[i].points;
        final prev = buckets[i - 1].points;
        buckets[i] = _BucketData(
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
        child: _HeatmapChart(
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

  Widget _buildCounterChart() {
    const chartHeight = 200.0;

    if (_counterLoading) {
      return const SizedBox(
        height: chartHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_counterError != null) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Text(
            'Chart: $_counterError',
            style: const TextStyle(color: Colors.red, fontSize: 11),
          ),
        ),
      );
    }

    final ts = _counterTimestamps;
    final series = _counterSeries;
    if (ts == null || series == null || series.isEmpty) {
      return const SizedBox.shrink();
    }

    final n = ts.length;
    if (n == 0) return const SizedBox.shrink();

    // Compute Y range across all series
    double maxY = 0, minY = double.infinity;
    for (final s in series) {
      final pts = s.points;
      for (final v in pts) {
        if (v > maxY) maxY = v;
        if (v < minY) minY = v;
      }
    }
    if (minY == double.infinity) minY = 0;
    final range = maxY - minY;
    final displayMax = maxY + (range > 0 ? range * 0.1 : max(maxY * 0.1, 0.001));
    final displayMin = (minY - (range > 0 ? range * 0.1 : 0)).clamp(0.0, double.infinity);

    final xInterval = max(1, (n / 6).ceil()).toDouble();

    // Build bars first so showingTooltipIndicators can reference them.
    final bars = series.asMap().entries.map((entry) {
      final idx = entry.key;
      final s = entry.value;
      final color = _kSeriesColors[idx % _kSeriesColors.length];
      final pts = s.points;
      final count = min(n, pts.length);
      final spots = List.generate(count, (i) => FlSpot(i.toDouble(), pts[i]));
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();

    // Compute which spots to pin the tooltip to (column-based, never disappears).
    final hoveredIdx = _chartHoveredIndex;
    final showingIndicators = (hoveredIdx == null || bars.isEmpty)
        ? <ShowingTooltipIndicators>[]
        : () {
            final spots = bars.asMap().entries
                .where((e) => hoveredIdx < e.value.spots.length)
                .map((e) => LineBarSpot(e.value, e.key, e.value.spots[hoveredIdx]))
                .toList();
            return spots.isEmpty ? <ShowingTooltipIndicators>[] : [ShowingTooltipIndicators(spots)];
          }();

    // Horizontal crosshair lines for each series at the hovered index.
    final extraLines = <HorizontalLine>[];
    if (hoveredIdx != null) {
      for (int i = 0; i < series.length; i++) {
        final pts = series[i].points;
        if (hoveredIdx < pts.length) {
          extraLines.add(HorizontalLine(
            y: pts[hoveredIdx],
            color: _kSeriesColors[i % _kSeriesColors.length].withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [5, 4],
          ));
        }
      }
    }

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (n - 1).toDouble(),
            minY: displayMin,
            maxY: displayMax,
            showingTooltipIndicators: showingIndicators,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 64,
                  getTitlesWidget: (v, _) => Text(
                    _formatAxisValue(v),
                    style: const TextStyle(
                        fontSize: 9, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: xInterval,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt().clamp(0, ts.length - 1);
                    final dt = DateTime.fromMillisecondsSinceEpoch(
                        ts[i] * 1000);
                    final hh = dt.hour.toString().padLeft(2, '0');
                    final mm = dt.minute.toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$hh:$mm',
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF6B7280)),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              // Disable built-in threshold-based detection so the tooltip
              // never disappears while the cursor is over the chart.
              handleBuiltInTouches: false,
              // Large threshold so lineBarSpots always resolves to the
              // nearest column regardless of vertical mouse position.
              touchSpotThreshold: 1000,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                if (!mounted) return;
                int? newIdx;
                if (event is! FlPointerExitEvent) {
                  final spots = response?.lineBarSpots;
                  if (spots != null && spots.isNotEmpty) {
                    newIdx = spots.first.spotIndex;
                  }
                }
                if (newIdx != _chartHoveredIndex) {
                  setState(() => _chartHoveredIndex = newIdx);
                }
              },
              getTouchedSpotIndicator: (barData, spotIndexes) =>
                  spotIndexes.map((_) => TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.grey.withValues(alpha: 0.5),
                          strokeWidth: 1,
                          dashArray: [5, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 5,
                                color: barData.color ?? Colors.grey,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                      )).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.white,
                tooltipBorder: BorderSide(color: Colors.grey.shade300),
                tooltipRoundedRadius: 4,
                getTooltipItems: (spots) =>
                    spots.asMap().entries.map((entry) {
                  final spot = entry.value;
                  final i = spot.x.toInt().clamp(0, ts.length - 1);
                  final dt = DateTime.fromMillisecondsSinceEpoch(
                      ts[i] * 1000);
                  final hh = dt.hour.toString().padLeft(2, '0');
                  final mm = dt.minute.toString().padLeft(2, '0');
                  final header = entry.key == 0 ? '$hh:$mm\n' : '';
                  return LineTooltipItem(
                    header,
                    const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: '${_formatAxisValue(spot.y)}$_chartUnit',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kSeriesColors[
                              spot.barIndex % _kSeriesColors.length],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: extraLines),
            lineBarsData: bars,
          ),
        ),
      ),
    );
  }

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
            child: const Row(
              children: [
                Icon(Icons.timeline, size: 16, color: Color(0xFF5C6BC0)),
                SizedBox(width: 8),
                Text(
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
              _buildCounterChart(),
              _buildKindLabel(
                'Counter  ·  ${_chartUnit == '/min' ? 'per minute' : 'per second'}',
                Colors.red.shade50,
                Colors.red,
              ),
              Expanded(child: _buildSeriesTagsPanel()),
            ] else if (_metricKind == null) ...[
              // Undetected type → treat as Gauge
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

// ──────────────────────────────────────────────
// Heatmap widget
// ──────────────────────────────────────────────

class _HeatmapChart extends StatefulWidget {
  final List<int> timestamps;
  final List<_BucketData> buckets;
  final double minValue;
  final double maxValue;
  final String Function(double) formatValue;

  const _HeatmapChart({
    required this.timestamps,
    required this.buckets,
    required this.minValue,
    required this.maxValue,
    required this.formatValue,
  });

  @override
  State<_HeatmapChart> createState() => _HeatmapChartState();
}

class _HeatmapChartState extends State<_HeatmapChart> {
  Offset? _hoverPos;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        if (_hoverPos != e.localPosition) {
          setState(() => _hoverPos = e.localPosition);
        }
      },
      onExit: (_) => setState(() => _hoverPos = null),
      child: CustomPaint(
        painter: _HeatmapPainter(
          timestamps: widget.timestamps,
          buckets: widget.buckets,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          hoverPos: _hoverPos,
          formatValue: widget.formatValue,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  static const _leftPad = 60.0;
  static const _rightPad = 8.0;
  static const _topPad = 4.0;
  static const _xAxisH = 22.0;
  static const _colorBarH = 10.0;
  static const _bottomPad = _xAxisH + _colorBarH + 14.0;

  final List<int> timestamps;
  final List<_BucketData> buckets;
  final double minValue;
  final double maxValue;
  final Offset? hoverPos;
  final String Function(double) formatValue;

  _HeatmapPainter({
    required this.timestamps,
    required this.buckets,
    required this.minValue,
    required this.maxValue,
    required this.hoverPos,
    required this.formatValue,
  });

  Color _heatColor(double t) {
    const low = Color(0xFFECEFF1);
    const high = Color(0xFF0D47A1);
    return Color.lerp(low, high, t.clamp(0.0, 1.0))!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridW = size.width - _leftPad - _rightPad;
    final gridH = size.height - _topPad - _bottomPad;
    if (gridW <= 0 || gridH <= 0) return;

    final n = timestamps.length;
    final m = buckets.length;
    if (n == 0 || m == 0) return;

    final cellW = gridW / n;
    final cellH = gridH / m;
    final valueRange = maxValue - minValue;

    // Determine hover cell
    int? hovCol, hovRow;
    final hp = hoverPos;
    if (hp != null) {
      final dx = hp.dx - _leftPad;
      final dy = hp.dy - _topPad;
      if (dx >= 0 && dx < gridW && dy >= 0 && dy < gridH) {
        hovCol = (dx / cellW).floor().clamp(0, n - 1);
        hovRow = (m - 1) - (dy / cellH).floor().clamp(0, m - 1);
      }
    }

    // Draw cells (row 0 = lowest bucket at bottom, row m-1 = highest at top)
    final cellPaint = Paint();
    for (int col = 0; col < n; col++) {
      for (int row = 0; row < m; row++) {
        final screenRow = (m - 1) - row;
        final left = _leftPad + col * cellW;
        final top = _topPad + screenRow * cellH;
        final rect = Rect.fromLTWH(left, top, cellW, cellH);

        final pts = buckets[row].points;
        final val = col < pts.length ? pts[col] : 0.0;
        final t = valueRange > 0 ? (val - minValue) / valueRange : 0.0;
        cellPaint.color = (hovCol == col && hovRow == row)
            ? _heatColor(t).withValues(alpha: 0.55)
            : _heatColor(t);
        canvas.drawRect(rect, cellPaint);
      }
    }

    // Grid border
    canvas.drawRect(
      Rect.fromLTWH(_leftPad, _topPad, gridW, gridH),
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Y-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final maxYLabels = max(1, (gridH / 14).floor());
    final yStep = max(1, (m / maxYLabels).ceil());
    for (int row = 0; row < m; row += yStep) {
      final screenRow = (m - 1) - row;
      final y = _topPad + (screenRow + 0.5) * cellH;
      tp.text = TextSpan(
        text: buckets[row].tagLabel,
        style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
      );
      tp.layout(maxWidth: _leftPad - 4);
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, y - tp.height / 2));
    }

    // X-axis labels
    final maxXLabels = max(1, (gridW / 34).floor());
    final xStep = max(1, (n / maxXLabels).ceil());
    for (int col = 0; col < n; col += xStep) {
      final x = _leftPad + (col + 0.5) * cellW;
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[col] * 1000);
      final label =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      tp.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, _topPad + gridH + 4));
    }

    // Color bar
    final barTop = _topPad + gridH + _xAxisH;
    final barRect = Rect.fromLTWH(_leftPad, barTop, gridW, _colorBarH);
    canvas.drawRect(
      barRect,
      Paint()
        ..shader = LinearGradient(
          colors: [_heatColor(0), _heatColor(1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(barRect),
    );
    canvas.drawRect(
      barRect,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Color bar min/max labels
    tp.text = TextSpan(
      text: formatValue(minValue),
      style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
    );
    tp.layout();
    tp.paint(canvas, Offset(_leftPad, barTop + _colorBarH + 2));

    tp.text = TextSpan(
      text: formatValue(maxValue),
      style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
    );
    tp.layout();
    tp.paint(canvas, Offset(_leftPad + gridW - tp.width, barTop + _colorBarH + 2));

    // Tooltip
    if (hovCol != null && hovRow != null) {
      _drawTooltip(canvas, size, hovCol, hovRow, cellW, cellH, m);
    }
  }

  void _drawTooltip(
      Canvas canvas, Size size, int col, int row, double cellW, double cellH, int m) {
    final bucket = buckets[row];
    final pts = bucket.points;
    final val = col < pts.length ? pts[col] : 0.0;
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[col] * 1000);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final tipText = '$time  ≤${bucket.tagLabel}  ${formatValue(val)}';

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: tipText,
      style: const TextStyle(fontSize: 10, color: Color(0xFF212121)),
    );
    tp.layout(maxWidth: size.width - 24);

    final tipW = tp.width + 12;
    final tipH = tp.height + 8;
    final screenRow = (m - 1) - row;
    var tipX = _leftPad + (col + 1) * cellW + 4;
    var tipY = _topPad + screenRow * cellH - tipH - 2;
    tipX = tipX.clamp(0.0, size.width - tipW);
    tipY = tipY.clamp(0.0, size.height - tipH);

    final tipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tipX, tipY, tipW, tipH),
      const Radius.circular(4),
    );
    canvas.drawRRect(tipRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      tipRRect,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(tipX + 6, tipY + 4));
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.hoverPos != hoverPos ||
      !identical(old.timestamps, timestamps) ||
      !identical(old.buckets, buckets) ||
      old.minValue != minValue ||
      old.maxValue != maxValue;
}
