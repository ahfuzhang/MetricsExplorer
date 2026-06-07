import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'session.dart';
import 'metricsui/show_labels.dart';
import 'metricsui/show_metric_names.dart';

class ListDatasourcePage extends StatefulWidget {
  final AppSession session;
  final VoidCallback? onAddDatasource;

  const ListDatasourcePage({super.key, required this.session, this.onAddDatasource});

  @override
  State<ListDatasourcePage> createState() => _ListDatasourcePageState();
}

enum _DetailType { labels, metricNames }

class _ListDatasourcePageState extends State<ListDatasourcePage> {
  List<VictoriaMetricsDatasource> _datasources = [];
  List<VictoriaMetricsDatasource> _sorted = [];
  bool _loading = false;
  String? _errorMessage;

  _DetailType? _detailType;
  VictoriaMetricsDatasource? _detailDs;

  int _sortColumnIndex = -1;
  bool _sortAscending = true;

  static const List<String> _colLabels = ['ID', 'Name', 'Address', 'Actions'];
  static const List<double> _minColWidths = [60.0, 120.0, 160.0, 140.0];
  final List<double> _colWidths = [80.0, 200.0, 300.0, 160.0];

  final _headerHorizCtrl = ScrollController();
  final _bodyHorizCtrl = ScrollController();
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _headerHorizCtrl.addListener(_onHeaderScroll);
    _bodyHorizCtrl.addListener(_onBodyScroll);
    _fetchDatasources();
  }

  @override
  void dispose() {
    _headerHorizCtrl.dispose();
    _bodyHorizCtrl.dispose();
    super.dispose();
  }

  void _onHeaderScroll() {
    if (_syncingScroll) return;
    _syncingScroll = true;
    if (_bodyHorizCtrl.hasClients) _bodyHorizCtrl.jumpTo(_headerHorizCtrl.offset);
    _syncingScroll = false;
  }

  void _onBodyScroll() {
    if (_syncingScroll) return;
    _syncingScroll = true;
    if (_headerHorizCtrl.hasClients) _headerHorizCtrl.jumpTo(_bodyHorizCtrl.offset);
    _syncingScroll = false;
  }

  Future<void> _fetchDatasources() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final request = ListDatasourceRequest(session: widget.session.sessionToken);
      final uri = Uri.parse('${widget.session.apiPath}api/v1/list_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = ListDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _datasources = decoded.datasources.toList();
            _applySorting();
          });
        } else {
          setState(() {
            _errorMessage = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSortColumn(int colIndex) {
    setState(() {
      if (_sortColumnIndex == colIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = colIndex;
        _sortAscending = true;
      }
      _applySorting();
    });
  }

  void _applySorting() {
    _sorted = List.from(_datasources);
    if (_sortColumnIndex == 0) {
      _sorted.sort((a, b) {
        final cmp = a.vmDatasourceId.compareTo(b.vmDatasourceId);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 1) {
      _sorted.sort((a, b) {
        final cmp = a.datasourceName.compareTo(b.datasourceName);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 2) {
      _sorted.sort((a, b) {
        final cmp = a.addr.compareTo(b.addr);
        return _sortAscending ? cmp : -cmp;
      });
    }
  }

  double get _totalWidth => _colWidths.fold(0.0, (s, w) => s + w);

  Widget _buildListPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text('Data Sources', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (widget.onAddDatasource != null)
                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Data Source'),
                  onPressed: widget.onAddDatasource,
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loading ? null : _fetchDatasources,
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_errorMessage != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
              ),
            ),
          )
        else ...[
          _buildHeaderRow(),
          const Divider(height: 1, thickness: 1),
          Expanded(child: _buildBodyRows()),
          const Divider(height: 1, thickness: 1),
          _buildFooter(),
        ],
      ],
    );
  }

  void _closeDetail() => setState(() {
        _detailType = null;
        _detailDs = null;
      });

  Widget _buildDetailPanel() {
    final ds = _detailDs!;
    if (_detailType == _DetailType.labels) {
      return ShowLabelsPanel(
        key: ValueKey('labels_${ds.vmDatasourceId}'),
        session: widget.session,
        datasource: ds,
        onClose: _closeDetail,
      );
    }
    return ShowMetricNamesPanel(
      key: ValueKey('metrics_${ds.vmDatasourceId}'),
      session: widget.session,
      datasource: ds,
      onClose: _closeDetail,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_detailType != null && _detailDs != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: _buildListPanel()),
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(flex: 4, child: _buildDetailPanel()),
        ],
      );
    }
    return _buildListPanel();
  }

  Widget _buildHeaderRow() {
    return SingleChildScrollView(
      controller: _headerHorizCtrl,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _totalWidth,
        height: 40,
        child: Row(
          children: List.generate(_colLabels.length, _buildHeaderCell),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(int colIndex) {
    final isActionsCol = colIndex == _colLabels.length - 1;

    if (isActionsCol) {
      return SizedBox(
        width: _colWidths[colIndex],
        height: 40,
        child: Material(
          color: const Color(0xFFEEF0FD),
          child: Center(
            child: Text(
              _colLabels[colIndex],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF3949AB),
              ),
            ),
          ),
        ),
      );
    }

    final isSorted = _sortColumnIndex == colIndex;

    return SizedBox(
      width: _colWidths[colIndex],
      height: 40,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: const Color(0xFFEEF0FD),
              child: InkWell(
                onTap: () => _onSortColumn(colIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _colLabels[colIndex],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF3949AB),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSorted)
                        Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 13,
                          color: const Color(0xFF3949AB),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) {
                  setState(() {
                    _colWidths[colIndex] = (_colWidths[colIndex] + d.delta.dx)
                        .clamp(_minColWidths[colIndex], double.infinity);
                  });
                },
                child: Container(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyRows() {
    if (_sorted.isEmpty) {
      return const Center(
        child: Text('No data sources found', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      controller: _bodyHorizCtrl,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _totalWidth,
        child: ListView.separated(
          itemCount: _sorted.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, i) => _buildDataRow(_sorted[i], i),
        ),
      ),
    );
  }

  Widget _buildDataRow(VictoriaMetricsDatasource ds, int rowIndex) {
    final isEven = rowIndex % 2 == 0;
    return Container(
      height: 36,
      color: isEven ? Colors.white : const Color(0xFFF8F9FF),
      child: Row(
        children: [
          _buildDataCell(ds.vmDatasourceId.toString(), 0),
          _buildDataCell(ds.datasourceName, 1),
          _buildDataCell(ds.addr, 2),
          _buildActionsCell(ds),
        ],
      ),
    );
  }

  Widget _buildActionsCell(VictoriaMetricsDatasource ds) {
    return SizedBox(
      width: _colWidths[3],
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _confirmRemove(ds),
          ),
          IconButton(
            icon: const Icon(Icons.label_outline, size: 16, color: Color(0xFF5C6BC0)),
            tooltip: 'Show Labels',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() {
              _detailType = _DetailType.labels;
              _detailDs = ds;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, size: 16, color: Color(0xFF5C6BC0)),
            tooltip: 'Show Metric Names',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() {
              _detailType = _DetailType.metricNames;
              _detailDs = ds;
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(VictoriaMetricsDatasource ds) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Data Source'),
        content: Text('Remove data source "${ds.datasourceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _removeDatasource(ds);
  }

  Future<void> _removeDatasource(VictoriaMetricsDatasource ds) async {
    try {
      final request = RemoveDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceId: ds.vmDatasourceId,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/remove_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = RemoveDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _datasources.removeWhere((d) => d.vmDatasourceId == ds.vmDatasourceId);
            _applySorting();
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  decoded.message.isNotEmpty
                      ? decoded.message
                      : 'Error (code: ${decoded.code})',
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildDataCell(String text, int colIndex) {
    return SizedBox(
      width: _colWidths[colIndex],
      height: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: SelectableText(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Total: ${_datasources.length} record${_datasources.length == 1 ? '' : 's'}',
        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}
