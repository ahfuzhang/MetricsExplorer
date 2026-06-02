import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'main.dart';

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
  bool _loading = false;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();

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
      final uri =
          Uri.parse('${widget.session.apiPath}api/v1/get_metric_names_by_datasource');
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
                style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${_filtered.length} / ${_names.length} metric names',
              style:
                  TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No metric names found',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, thickness: 1),
                    itemBuilder: (context, i) => Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SelectableText(
                        _filtered[i],
                        style: const TextStyle(
                            fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

class ShowMetricNamesPage extends StatefulWidget {
  final AppSession session;
  final VictoriaMetricsDatasource datasource;

  const ShowMetricNamesPage({super.key, required this.session, required this.datasource});

  @override
  State<ShowMetricNamesPage> createState() => _ShowMetricNamesPageState();
}

class _ShowMetricNamesPageState extends State<ShowMetricNamesPage> {
  List<String> _names = [];
  List<String> _filtered = [];
  bool _loading = false;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();

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
      final uri = Uri.parse('${widget.session.apiPath}api/v1/get_metric_names_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded = GetMetricNamesByDatasourceResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _names = decoded.metricNames.toList()..sort();
            _filtered = _names;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metric Names — ${widget.datasource.datasourceName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetchMetricNames,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${_filtered.length} / ${_names.length} metric names',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('No metric names found', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SelectableText(
                          _filtered[i],
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
