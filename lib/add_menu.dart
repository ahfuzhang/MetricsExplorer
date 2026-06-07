import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'session.dart';

class AddMenuPage extends StatefulWidget {
  final AppSession session;

  const AddMenuPage({super.key, required this.session});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _menuNameController = TextEditingController();
  final _parentIdController = TextEditingController(text: '0');
  final _roleIdController = TextEditingController(text: '0');
  final _linkController = TextEditingController();
  final _targetController = TextEditingController();
  final _bitFlagsController = TextEditingController(text: '0');
  bool _loading = false;
  String? _resultMessage;
  bool _resultSuccess = false;

  @override
  void dispose() {
    _menuNameController.dispose();
    _parentIdController.dispose();
    _roleIdController.dispose();
    _linkController.dispose();
    _targetController.dispose();
    _bitFlagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    try {
      final menu = Menu(
        menuName: _menuNameController.text,
        parentId: Int64.parseInt(_parentIdController.text.isEmpty ? '0' : _parentIdController.text),
        roleId: Int64.parseInt(_roleIdController.text.isEmpty ? '0' : _roleIdController.text),
        link: _linkController.text,
        target: _targetController.text,
        bitFlags: Int64.parseInt(_bitFlagsController.text.isEmpty ? '0' : _bitFlagsController.text),
      );

      final request = AddMenuRequest(
        session: widget.session.sessionToken,
        menu: menu,
      );

      final uri = Uri.parse('${widget.session.apiPath}api/v1/add_menu');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = AddMenuResponse.fromBuffer(response.bodyBytes);
        setState(() {
          _resultSuccess = decoded.code == 0;
          _resultMessage = decoded.message.isNotEmpty
              ? decoded.message
              : (decoded.code == 0 ? 'Menu added successfully' : 'Failed (code: ${decoded.code})');
        });
        if (_resultSuccess) {
          _menuNameController.clear();
          _parentIdController.text = '0';
          _roleIdController.text = '0';
          _linkController.clear();
          _targetController.clear();
          _bitFlagsController.text = '0';
        }
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                    'Add Menu',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _menuNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Menu Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Menu name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parentIdController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Parent ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _roleIdController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Role ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bitFlagsController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _loading ? null : _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Bit Flags',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
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
