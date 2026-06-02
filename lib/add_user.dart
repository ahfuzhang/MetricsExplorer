import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'main.dart';

class AddUserPage extends StatefulWidget {
  final AppSession session;

  const AddUserPage({super.key, required this.session});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _loading = false;
  String? _resultMessage;
  bool _resultSuccess = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    try {
      final hashedPassword = sha256
          .convert(utf8.encode(widget.session.salt + _passwordController.text))
          .toString();

      final request = AddUserRequest(
        session: widget.session.sessionToken,
        userName: _userNameController.text,
        sha256: hashedPassword,
      );

      final uri = Uri.parse('${widget.session.apiPath}api/v1/add_user');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = AddUserResponse.fromBuffer(response.bodyBytes);
        setState(() {
          _resultSuccess = decoded.code == 0;
          _resultMessage = decoded.message.isNotEmpty
              ? decoded.message
              : (decoded.code == 0
                  ? 'User added successfully'
                  : 'Failed (code: ${decoded.code})');
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
                    'Add User',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _userNameController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'User name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loading ? null : _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password is required' : null,
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
