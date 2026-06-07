import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'session.dart';

class AddDatasourcePage extends StatefulWidget {
  final AppSession session;

  const AddDatasourcePage({super.key, required this.session});

  @override
  State<AddDatasourcePage> createState() => _AddDatasourcePageState();
}

class _AddDatasourcePageState extends State<AddDatasourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addrController = TextEditingController();
  final _addrFocusNode = FocusNode();
  bool _loading = false;
  String? _resultMessage;
  bool _resultSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addrController.dispose();
    _addrFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    try {
      final request = AddDatasourceRequest(
        session: widget.session.sessionToken,
        datasourceName: _nameController.text,
        addr: _addrController.text,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/add_datasource');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = AddDatasourceResponse.fromBuffer(response.bodyBytes);
        setState(() {
          _resultSuccess = decoded.code == 0;
          _resultMessage = decoded.message.isNotEmpty
              ? decoded.message
              : (decoded.code == 0 ? 'Data source added successfully' : 'Failed (code: ${decoded.code})');
        });
      } else {
        setState(() {
          _resultSuccess = false;
          _resultMessage = 'HTTP Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _resultSuccess = false;
        _resultMessage = 'Error: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Data Source',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_addrFocusNode),
                    decoration: const InputDecoration(
                      labelText: 'Data Source Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addrController,
                    focusNode: _addrFocusNode,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loading ? null : _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Data Source Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                  if (_resultMessage != null) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      _resultMessage!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: _resultSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
