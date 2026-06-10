import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';
import 'range_query.dart';
import 'tag_filter.dart';

class ShowPodsPanel extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;
  final VoidCallback? onClose;

  const ShowPodsPanel({
    super.key,
    required this.session,
    required this.datasource,
    this.onClose,
  });

  @override
  State<ShowPodsPanel> createState() => _ShowPodsPanelState();
}

class _ShowPodsPanelState extends State<ShowPodsPanel> {
  Map<String, List<String>> _groups = {};
  Set<String> _expandedGroups = {};
  bool _loading = false;
  String? _errorMessage;
  final _rangeKey = GlobalKey<RangeQueryPanelState>();
  final _filterKey = GlobalKey<TagFilterPanelState>();
  String? _selectedPodName;
  double _leftFraction = 0.2;
  double _midFraction = 0.4;
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchPods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPods() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final request = GetPodsRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasource.datasourceName,
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_pods_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded = GetPodsResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          final groups = <String, List<String>>{};
          for (final entry in decoded.pods.entries) {
            groups[entry.key] = entry.value.podName.toList();
          }
          setState(() {
            _groups = groups;
            _expandedGroups = {};
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
    final filter = _searchText.toLowerCase();
    final sortedGroups = _groups.keys.toList()
      ..sort((a, b) => _groups[b]!.length.compareTo(_groups[a]!.length));
    if (sortedGroups.isEmpty) {
      return const Center(
        child: Text('No pods found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: sortedGroups.length,
      itemBuilder: (context, i) {
        final group = sortedGroups[i];
        final allPods = _groups[group]!.toList()..sort();
        final pods = filter.isEmpty
            ? allPods
            : allPods
                .where((p) => p.toLowerCase().contains(filter))
                .toList();
        if (pods.isEmpty) return const SizedBox.shrink();
        final expanded = filter.isNotEmpty || _expandedGroups.contains(group);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() {
                if (expanded) {
                  _expandedGroups.remove(group);
                } else {
                  _expandedGroups.add(group);
                }
              }),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: const Color(0xFF5C6BC0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$group (${pods.length})',
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
              ...pods.map((podName) {
                final isSelected = podName == _selectedPodName;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedPodName = podName);
                    _filterKey.currentState?.loadMetric('{pod="$podName"}');
                  },
                  child: Container(
                    color: isSelected
                        ? const Color(0xFFE8EAF6)
                        : Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 40, right: 16, top: 6, bottom: 6),
                      child: Text(
                        podName,
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
              const Icon(Icons.cloud_outlined,
                  size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pods — ${widget.datasource.datasourceName}',
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
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: _loading ? null : _fetchPods,
              ),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onClose,
                ),
            ],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Filter pods...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, size: 16, color: Colors.grey),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              onChanged: (v) => setState(() => _searchText = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              '${_groups.length} groups',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline),
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

  Widget _buildResizeDivider(
      {required void Function(double dx, double total) onDrag}) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) =>
          onDrag(d.delta.dx, context.size?.width ?? 800),
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
                onQueriesChanged: (q) =>
                    _rangeKey.currentState?.fetchData(q),
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

class ShowPodsPage extends StatelessWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;

  const ShowPodsPage(
      {super.key, required this.session, required this.datasource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPodsPanel(
        session: session,
        datasource: datasource,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
