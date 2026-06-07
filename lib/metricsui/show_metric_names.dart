import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';
import 'range_query.dart';
import 'tag_filter.dart';

class _MetricEntry {
  final String displayName;
  final String queryName;
  final bool isHistogram;
  const _MetricEntry({required this.displayName, required this.queryName, this.isHistogram = false});
}

List<_MetricEntry> _buildMetricEntries(List<String> items) {
  final nameSet = items.toSet();
  final handled = <String>{};
  final entries = <_MetricEntry>[];
  for (final name in items) {
    if (handled.contains(name)) continue;
    if (name.endsWith('_bucket')) {
      final base = name.substring(0, name.length - 7);
      final countName = '${base}_count';
      final sumName = '${base}_sum';
      if (nameSet.contains(countName) && nameSet.contains(sumName)) {
        entries.add(_MetricEntry(
          displayName: base,
          queryName: '$name,$countName,$sumName',
          isHistogram: true,
        ));
        handled.addAll([name, countName, sumName]);
        continue;
      }
    }
    entries.add(_MetricEntry(displayName: name, queryName: name));
    handled.add(name);
  }
  return entries;
}

Map<String, List<String>> _groupByPrefix(List<String> names) {
  final map = <String, List<String>>{};
  for (final name in names) {
    final idx = name.indexOf('_');
    final prefix = idx >= 0 ? name.substring(0, idx) : name;
    map.putIfAbsent(prefix, () => []).add(name);
  }
  return map;
}

// Embeddable panel (no Scaffold) for use inside a split-view layout.
class ShowMetricNamesPanel extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;
  final VoidCallback? onClose;

  const ShowMetricNamesPanel({
    super.key,
    required this.session,
    required this.datasource,
    this.onClose,
  });

  @override
  State<ShowMetricNamesPanel> createState() => _ShowMetricNamesPanelState();
}

class _ShowMetricNamesPanelState extends State<ShowMetricNamesPanel> {
  List<String> _names = [];
  List<String> _filtered = [];
  Map<String, List<String>> _grouped = {};
  Set<String> _expandedPrefixes = {};
  bool _loading = false;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();
  final _rangeKey = GlobalKey<RangeQueryPanelState>();
  final _filterKey = GlobalKey<TagFilterPanelState>();
  String? _selectedMetricName;
  double _leftFraction = 0.2;
  double _midFraction = 0.4;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _fetchMetricNames();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _names
          : _names.where((n) => n.toLowerCase().contains(q)).toList();
      _grouped = _groupByPrefix(_filtered);
      if (q.isNotEmpty) {
        _expandedPrefixes = _grouped.keys.toSet();
      }
    });
  }

  Future<void> _fetchMetricNames() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final request = GetMetricNamesByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_metric_names_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded =
            GetMetricNamesByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _names = decoded.metricNames.toList()..sort();
            _filtered = _names;
            _grouped = _groupByPrefix(_names);
            _expandedPrefixes = {};
          });
        } else {
          setState(() {
            _errorMessage = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() => _errorMessage =
            'HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildGroupedList() {
    final sortedPrefixes = _grouped.keys.toList()
      ..sort((a, b) => _grouped[b]!.length.compareTo(_grouped[a]!.length));
    if (sortedPrefixes.isEmpty) {
      return const Center(
        child: Text('No metric names found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: sortedPrefixes.length,
      itemBuilder: (context, i) {
        final prefix = sortedPrefixes[i];
        final items = _grouped[prefix]!;
        final expanded = _expandedPrefixes.contains(prefix);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() {
                if (expanded) {
                  _expandedPrefixes.remove(prefix);
                } else {
                  _expandedPrefixes.add(prefix);
                }
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: const Color(0xFF5C6BC0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$prefix (${items.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              ..._buildMetricEntries(items).map((entry) {
                final isSelected = entry.queryName == _selectedMetricName;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedMetricName = entry.queryName);
                    _filterKey.currentState?.loadMetric(entry.queryName);
                  },
                  child: Container(
                    color: isSelected
                        ? const Color(0xFFE8EAF6)
                        : Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 40, right: 16, top: 6, bottom: 6),
                      child: entry.isHistogram
                          ? RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: entry.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    color: isSelected
                                        ? const Color(0xFF3949AB)
                                        : const Color(0xFF333333),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                const TextSpan(
                                  text: '  (histogram)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey,
                                  ),
                                ),
                              ]),
                            )
                          : Text(
                              entry.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: isSelected
                                    ? const Color(0xFF3949AB)
                                    : const Color(0xFF333333),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            const Divider(height: 1, thickness: 1),
          ],
        );
      },
    );
  }

  Widget _buildLeftContent() {
    return Column(
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
              const Icon(Icons.bar_chart, size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Metric Names — ${widget.datasource.datasourceName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                tooltip: 'Refresh',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: _loading ? null : _fetchMetricNames,
              ),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onClose,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Filter metric names...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_errorMessage != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _errorMessage!,
                style: const TextStyle(
                    color: Colors.red, fontFamily: 'monospace'),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${_grouped.length} prefixes, ${_filtered.length} / ${_names.length} metric names',
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(child: _buildGroupedList()),
        ],
      ],
    );
  }

  static const _kDividerWidth = 6.0;
  static const _kMinFraction = 0.1;

  Widget _buildResizeDivider({required void Function(double dx, double total) onDrag}) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx, context.size?.width ?? 800),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: SizedBox(
          width: _kDividerWidth,
          child: Center(
            child: Container(width: 1, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final available = totalWidth - _kDividerWidth * 2;
        final leftW = available * _leftFraction;
        final midW = available * _midFraction;
        final rightW = available * (1 - _leftFraction - _midFraction);

        return Row(
          children: [
            SizedBox(width: leftW, child: _buildLeftContent()),
            _buildResizeDivider(onDrag: (dx, _) {
              setState(() {
                final df = dx / available;
                _leftFraction = (_leftFraction + df).clamp(
                  _kMinFraction,
                  1 - _midFraction - _kMinFraction,
                );
              });
            }),
            SizedBox(
              width: midW,
              child: TagFilterPanel(
                key: _filterKey,
                session: widget.session,
                datasource: widget.datasource,
                onCounterQueryChanged: (q) =>
                    _rangeKey.currentState?.setCounterQuery(q),
                onGaugeQueryChanged: (q) =>
                    _rangeKey.currentState?.setGaugeQuery(q),
                onQueriesChanged: (q) => _rangeKey.currentState?.fetchData(q),
              ),
            ),
            _buildResizeDivider(onDrag: (dx, _) {
              setState(() {
                final df = dx / available;
                _midFraction = (_midFraction + df).clamp(
                  _kMinFraction,
                  1 - _leftFraction - _kMinFraction,
                );
              });
            }),
            SizedBox(
              width: rightW,
              child: RangeQueryPanel(
                key: _rangeKey,
                session: widget.session,
                datasource: widget.datasource,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShowMetricNamesPage extends StatelessWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;

  const ShowMetricNamesPage(
      {super.key, required this.session, required this.datasource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowMetricNamesPanel(
        session: session,
        datasource: datasource,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
