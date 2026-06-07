import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';

class TagFilterPanel extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;
  final void Function(List<String> queries) onQueriesChanged;
  final void Function(String? counterQuery)? onCounterQueryChanged;
  final void Function(String? gaugeQuery)? onGaugeQueryChanged;

  const TagFilterPanel({
    super.key,
    required this.session,
    required this.datasource,
    required this.onQueriesChanged,
    this.onCounterQueryChanged,
    this.onGaugeQueryChanged,
  });

  @override
  State<TagFilterPanel> createState() => TagFilterPanelState();
}

class TagFilterPanelState extends State<TagFilterPanel> {
  final _scrollCtrl = ScrollController();
  String? _selectedMetricName;
  List<MetricTags> _ts = [];
  Map<String, TagValues> _tags = {};
  bool _loading = false;
  String? _error;
  Map<String, Set<String>> _activeFilters = {};
  bool _showPredictions = false;
  String? _lastToggledTag;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<MetricTags> get _displayedTs {
    if (_activeFilters.isEmpty) return _ts;
    return _ts.where((metric) {
      for (final entry in _activeFilters.entries) {
        final tag = entry.key;
        final selected = entry.value;
        if (selected.isEmpty) continue;
        if (!selected.any((v) => metric.tags[tag] == v)) return false;
      }
      return true;
    }).toList();
  }

  // For histogram queries (comma-separated names), return the base prefix.
  String get _metricDisplayName {
    if (_selectedMetricName == null) return '';
    if (_selectedMetricName!.contains(',')) {
      final first = _selectedMetricName!.split(',').first;
      return first.endsWith('_bucket')
          ? first.substring(0, first.length - 7)
          : first;
    }
    return _selectedMetricName!;
  }

  String _formatPrometheus(MetricTags metric) {
    final name = metric.tags['__name__'] ?? _metricDisplayName;
    final labels = metric.tags.entries
        .where((e) => e.key != '__name__')
        .map((e) => '${e.key}="${e.value}"')
        .join(', ');
    return labels.isEmpty ? name : '$name{$labels}';
  }

  void _toggleFilter(String tag, String value) {
    setState(() {
      _showPredictions = false;
      _lastToggledTag = tag;
      final set = _activeFilters.putIfAbsent(tag, () => {});
      if (set.contains(value)) {
        set.remove(value);
        if (set.isEmpty) _activeFilters.remove(tag);
      } else {
        set.add(value);
      }
    });
    widget.onCounterQueryChanged?.call(_buildCounterQuery());
    widget.onGaugeQueryChanged?.call(_buildGaugeQuery());
    widget.onQueriesChanged(_displayedTs.map(_formatPrometheus).toList());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showPredictions = true);
    });
  }

  String _buildFilterStr() {
    final filters = <String>[];
    for (final entry in _activeFilters.entries) {
      final tag = entry.key;
      final values = entry.value;
      if (values.isEmpty) continue;
      if (values.length == 1) {
        filters.add('$tag="${values.first}"');
      } else {
        filters.add('$tag=~"(${values.join('|')})"');
      }
    }
    return filters.isEmpty ? '' : filters.join(', ');
  }

  String _buildCounterQuery() {
    final metricName = (_selectedMetricName ?? '').split(',').first;
    return 'sum by () (rate($metricName{${_buildFilterStr()}}[1m]))';
  }

  String _buildGaugeQuery() {
    final metricName = (_selectedMetricName ?? '').split(',').first;
    return 'sum by () ($metricName{${_buildFilterStr()}})';
  }

  // Returns true if adding this tag=value to the current filters would yield
  // empty results. Only predicts for the tag immediately below the last
  // toggled tag in display order, and only when that tag has no active filter.
  bool _wouldYieldEmpty(String tag, String value, String? predictionTarget) {
    if (!_showPredictions) return false;
    if (tag != predictionTarget) return false;
    return !_displayedTs.any((m) => m.tags[tag] == value);
  }

  Future<void> loadMetric(String metricName) async {
    widget.onQueriesChanged([]);
    setState(() {
      _selectedMetricName = metricName;
      _loading = true;
      _error = null;
      _ts = [];
      _tags = {};
      _activeFilters = {};
    });
    try {
      final request = GetSeriesByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
        metricName: metricName,
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_series_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded =
            GetSeriesByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _ts = decoded.ts.toList();
            _tags = Map.from(decoded.tags);
          });
          widget.onCounterQueryChanged?.call(_buildCounterQuery());
          widget.onGaugeQueryChanged?.call(_buildGaugeQuery());
          widget.onQueriesChanged(_displayedTs.map(_formatPrometheus).toList());
        } else {
          setState(() {
            _error = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() => _error =
            'HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildTagsSection() {
    if (_tags.isEmpty || _ts.isEmpty) return const SizedBox.shrink();
    final n = _ts.length;

    final commonParts = <String>[];
    final otherTags = <MapEntry<String, TagValues>>[];

    for (final entry in _tags.entries) {
      final tv = entry.value;
      bool isCommon = false;
      for (int i = 0; i < tv.showTimes.length && i < tv.values.length; i++) {
        if (tv.showTimes[i] == n) {
          commonParts.add('${entry.key}=${tv.values[i]}');
          isCommon = true;
          break;
        }
      }
      if (!isCommon) otherTags.add(entry);
    }

    // sort ascending by number of distinct values
    otherTags.sort(
        (a, b) => a.value.values.length.compareTo(b.value.values.length));

    // Prediction target: the tag immediately after _lastToggledTag in display
    // order, provided it has no active filter (adding a value is AND semantics).
    String? predictionTarget;
    if (_lastToggledTag != null) {
      final tagNames = otherTags.map((e) => e.key).toList();
      final idx = tagNames.indexOf(_lastToggledTag!);
      if (idx >= 0 && idx + 1 < tagNames.length) {
        final next = tagNames[idx + 1];
        if (!_activeFilters.containsKey(next)) predictionTarget = next;
      }
    }

    return Container(
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
          ...otherTags.map((entry) {
            final tv = entry.value;
            final tag = entry.key;
            final selectedValues = _activeFilters[tag] ?? {};
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tag=[',
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
                      children: List.generate(tv.values.length, (i) {
                        final value = tv.values[i];
                        final count =
                            i < tv.showTimes.length ? tv.showTimes[i] : 0;
                        final isSelected = selectedValues.contains(value);
                        final isEmpty =
                            _wouldYieldEmpty(tag, value, predictionTarget);
                        return GestureDetector(
                          onTap: () => _toggleFilter(tag, value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3949AB)
                                  : const Color(0xFFE8EAF6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isEmpty
                                    ? Colors.red
                                    : isSelected
                                        ? const Color(0xFF3949AB)
                                        : Colors.grey.shade400,
                                width: isEmpty ? 1.5 : 1.0,
                              ),
                            ),
                            child: Text(
                              '$value($count)',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: isSelected
                                    ? Colors.white
                                    : isEmpty
                                        ? Colors.red.shade700
                                        : const Color(0xFF333333),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.format_list_bulleted,
                  size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedMetricName != null
                      ? (_activeFilters.isEmpty
                          ? 'Series — $_metricDisplayName (${_ts.length})'
                          : 'Series — $_metricDisplayName (${_displayedTs.length}/${_ts.length})')
                      : 'Series',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
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
        else if (_selectedMetricName == null)
          const Expanded(
            child: Center(
              child: Text(
                'Click a metric name to view its series',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else if (_ts.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No series found',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          Expanded(
            child: Scrollbar(
              controller: _scrollCtrl,
              thumbVisibility: true,
              child: CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  SliverToBoxAdapter(child: _buildTagsSection()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: SelectableText(
                          _formatPrometheus(_displayedTs[i]),
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      childCount: _displayedTs.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
