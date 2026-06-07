import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../generated/api.pb.dart';
import '../session.dart';

// ─── Show labels by datasource name (from JSON menu link) ────────────────────

class ShowLabelsByDatasourceNamePanel extends StatefulWidget {
  final AppSession session;
  final String datasourceName;

  const ShowLabelsByDatasourceNamePanel({
    super.key,
    required this.session,
    required this.datasourceName,
  });

  @override
  State<ShowLabelsByDatasourceNamePanel> createState() =>
      _ShowLabelsByDatasourceNamePanelState();
}

class _ShowLabelsByDatasourceNamePanelState
    extends State<ShowLabelsByDatasourceNamePanel> {
  bool _loading = true;
  String? _errorMessage;
  List<MapEntry<String, int>>? _labels;

  @override
  void initState() {
    super.initState();
    _fetchLabels();
  }

  @override
  void didUpdateWidget(ShowLabelsByDatasourceNamePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasourceName != widget.datasourceName) {
      _fetchLabels();
    }
  }

  Future<void> _fetchLabels() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _labels = null;
    });
    try {
      final request = GetLabelsByDatasourceRequest(
        session: widget.session.sessionToken,
        vmDatasourceName: widget.datasourceName,
      );
      final uri = Uri.parse(
          '${widget.session.apiPath}api/v1/get_labels_by_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded =
            GetLabelsByDatasourceResponse.fromBuffer(response.bodyBytes);
        final entries = decoded.labels.entries
            .map((e) => MapEntry(e.key, e.value.values.length))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        if (mounted) setState(() => _labels = entries);
      } else {
        if (mounted) {
          setState(
              () => _errorMessage = 'HTTP Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatCount(int count) =>
      count >= 1000 ? '(1000+)' : '($count)';

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
              const Icon(Icons.label_outline,
                  size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Labels — ${widget.datasourceName}',
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
                onPressed: _loading ? null : _fetchLabels,
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
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _labels?.length ?? 0,
              itemBuilder: (context, index) {
                final entry = _labels![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                              fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ),
                      Text(
                        _formatCount(entry.value),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
