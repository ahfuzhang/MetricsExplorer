import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';
import 'tag_filter.dart';

String _countStr(int count) => count >= 1000 ? '1000+' : '$count';

const double _kDividerWidth = 4.0;
const double _kMinPaneFrac = 0.05;

// ─── Draggable vertical divider ──────────────────────────────────────────────

class _PaneDivider extends StatelessWidget {
  final double totalWidth;
  final void Function(double delta) onDrag;

  const _PaneDivider({required this.totalWidth, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx / totalWidth),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: _kDividerWidth,
          color: Colors.grey.shade300,
          child: Center(
            child: Container(width: 1, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}

// ─── ShowLabelsPanel (no Scaffold) ───────────────────────────────────────────

class ShowLabelsPanel extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;
  final VoidCallback? onClose;

  const ShowLabelsPanel({
    super.key,
    required this.session,
    required this.datasource,
    this.onClose,
  });

  @override
  State<ShowLabelsPanel> createState() => _ShowLabelsPanelState();
}

class _ShowLabelsPanelState extends State<ShowLabelsPanel> {
  List<String> _labels = [];
  List<String> _filtered = [];
  Map<String, int> _labelCounts = {};
  Map<String, List<String>> _labelValues = {};
  final Set<String> _expanded = {};
  bool _loading = false;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();

  // pane split fractions (of total width)
  double _div1Frac = 0.20;
  double _div2Frac = 0.60;

  // middle pane: tag filter panel
  final _tagFilterKey = GlobalKey<TagFilterPanelState>();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _fetchLabels();
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
          ? _labels
          : _labels.where((l) => l.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _fetchLabels() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final request = GetLabelsByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/get_labels_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded = GetLabelsByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _labelCounts = decoded.labels.map((k, v) => MapEntry(k, v.values.length));
            _labelValues = decoded.labels.map(
              (k, v) => MapEntry(k, (v.values.toList()..sort()).take(100).toList()),
            );
            _labels = decoded.labels.keys.toList()
              ..sort((a, b) {
                final cmp = (_labelCounts[a] ?? 0).compareTo(_labelCounts[b] ?? 0);
                return cmp != 0 ? cmp : a.toLowerCase().compareTo(b.toLowerCase());
              });
            _filtered = _labels;
          });
        } else {
          setState(() {
            _errorMessage = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() =>
            _errorMessage = 'HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onValueTap(String labelName, String labelValue) {
    final selector = '{$labelName="$labelValue"}';
    _tagFilterKey.currentState?.loadMetric(selector);
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Filter labels...',
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
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              '${_filtered.length} / ${_labels.length} labels',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No labels found', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => _LabelItem(
                      label: _filtered[i],
                      count: _labelCounts[_filtered[i]] ?? 0,
                      values: _labelValues[_filtered[i]] ?? [],
                      expanded: _expanded.contains(_filtered[i]),
                      onTap: () => setState(() {
                        final l = _filtered[i];
                        if (_expanded.contains(l)) {
                          _expanded.remove(l);
                        } else {
                          _expanded.add(l);
                        }
                      }),
                      onValueTap: _onValueTap,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiddlePanel() {
    return TagFilterPanel(
      key: _tagFilterKey,
      session: widget.session,
      datasource: widget.datasource,
      onQueriesChanged: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header bar — full width
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FD),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Icon(Icons.label_outline, size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Labels — ${widget.datasource.datasourceName}',
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
                onPressed: _loading ? null : _fetchLabels,
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
        // Three-pane body
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final leftW = _div1Frac * totalWidth;
              final midW = (_div2Frac - _div1Frac) * totalWidth - _kDividerWidth;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: leftW, child: _buildLeftPanel()),
                  _PaneDivider(
                    totalWidth: totalWidth,
                    onDrag: (delta) => setState(() {
                      _div1Frac = (_div1Frac + delta)
                          .clamp(_kMinPaneFrac, _div2Frac - _kMinPaneFrac);
                    }),
                  ),
                  SizedBox(width: midW, child: _buildMiddlePanel()),
                  _PaneDivider(
                    totalWidth: totalWidth,
                    onDrag: (delta) => setState(() {
                      _div2Frac = (_div2Frac + delta)
                          .clamp(_div1Frac + _kMinPaneFrac, 1.0 - _kMinPaneFrac);
                    }),
                  ),
                  Expanded(child: Container(color: Colors.grey.shade50)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── ShowLabelsPage (with Scaffold) ──────────────────────────────────────────

class ShowLabelsPage extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;

  const ShowLabelsPage({super.key, required this.session, required this.datasource});

  @override
  State<ShowLabelsPage> createState() => _ShowLabelsPageState();
}

class _ShowLabelsPageState extends State<ShowLabelsPage> {
  List<String> _labels = [];
  List<String> _filtered = [];
  Map<String, int> _labelCounts = {};
  Map<String, List<String>> _labelValues = {};
  final Set<String> _expanded = {};
  bool _loading = false;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();

  double _div1Frac = 0.20;
  double _div2Frac = 0.60;

  final _tagFilterKey = GlobalKey<TagFilterPanelState>();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _fetchLabels();
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
          ? _labels
          : _labels.where((l) => l.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _fetchLabels() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final request = GetLabelsByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/get_labels_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded = GetLabelsByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _labelCounts = decoded.labels.map((k, v) => MapEntry(k, v.values.length));
            _labelValues = decoded.labels.map(
              (k, v) => MapEntry(k, (v.values.toList()..sort()).take(100).toList()),
            );
            _labels = decoded.labels.keys.toList()
              ..sort((a, b) {
                final cmp = (_labelCounts[a] ?? 0).compareTo(_labelCounts[b] ?? 0);
                return cmp != 0 ? cmp : a.toLowerCase().compareTo(b.toLowerCase());
              });
            _filtered = _labels;
          });
        } else {
          setState(() {
            _errorMessage = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() => _errorMessage = 'HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onValueTap(String labelName, String labelValue) {
    final selector = '{$labelName="$labelValue"}';
    _tagFilterKey.currentState?.loadMetric(selector);
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Filter labels...',
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
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              '${_filtered.length} / ${_labels.length} labels',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No labels found', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => _LabelItem(
                      label: _filtered[i],
                      count: _labelCounts[_filtered[i]] ?? 0,
                      values: _labelValues[_filtered[i]] ?? [],
                      expanded: _expanded.contains(_filtered[i]),
                      onTap: () => setState(() {
                        final l = _filtered[i];
                        if (_expanded.contains(l)) {
                          _expanded.remove(l);
                        } else {
                          _expanded.add(l);
                        }
                      }),
                      onValueTap: _onValueTap,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labels — ${widget.datasource.datasourceName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetchLabels,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final leftW = _div1Frac * totalWidth;
          final midW = (_div2Frac - _div1Frac) * totalWidth - _kDividerWidth;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: leftW, child: _buildLeftPanel()),
              _PaneDivider(
                totalWidth: totalWidth,
                onDrag: (delta) => setState(() {
                  _div1Frac = (_div1Frac + delta)
                      .clamp(_kMinPaneFrac, _div2Frac - _kMinPaneFrac);
                }),
              ),
              SizedBox(
                width: midW,
                child: TagFilterPanel(
                  key: _tagFilterKey,
                  session: widget.session,
                  datasource: widget.datasource,
                  onQueriesChanged: (_) {},
                ),
              ),
              _PaneDivider(
                totalWidth: totalWidth,
                onDrag: (delta) => setState(() {
                  _div2Frac = (_div2Frac + delta)
                      .clamp(_div1Frac + _kMinPaneFrac, 1.0 - _kMinPaneFrac);
                }),
              ),
              Expanded(child: Container(color: Colors.grey.shade50)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Label list item ──────────────────────────────────────────────────────────

class _LabelItem extends StatelessWidget {
  final String label;
  final int count;
  final List<String> values;
  final bool expanded;
  final VoidCallback onTap;
  final void Function(String label, String value)? onValueTap;

  const _LabelItem({
    required this.label,
    required this.count,
    required this.values,
    required this.expanded,
    required this.onTap,
    this.onValueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
                Text(
                  '(${_countStr(count)})',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final v in values)
                  InkWell(
                    onTap: onValueTap != null ? () => onValueTap!(label, v) : null,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 36, right: 16, top: 4, bottom: 4),
                      child: Text(
                        v,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: onValueTap != null
                              ? const Color(0xFF1565C0)
                              : Colors.grey.shade800,
                          decoration: onValueTap != null
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                if (count > 100)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 36, right: 16, top: 4, bottom: 8),
                    child: Text(
                      '... ${count - 100} more values',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
              ],
            ),
          ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
