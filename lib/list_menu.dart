import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'session.dart';

class ListMenuPage extends StatefulWidget {
  final AppSession session;
  final VoidCallback? onAddMenu;

  const ListMenuPage({super.key, required this.session, this.onAddMenu});

  @override
  State<ListMenuPage> createState() => _ListMenuPageState();
}

class _ListMenuPageState extends State<ListMenuPage> {
  List<Menu> _menus = [];
  List<Menu> _sortedMenus = [];
  bool _loading = false;
  String? _errorMessage;

  String? _menuTreeJson;
  bool _treeLoading = false;
  String? _treeErrorMessage;

  int _sortColumnIndex = -1;
  bool _sortAscending = true;

  static const List<String> _colLabels = [
    'Menu ID', 'Menu Name', 'Parent ID', 'Role ID', 'Link', 'Target', 'Bit Flags', 'Actions',
  ];
  static const List<double> _minColWidths = [
    80.0, 120.0, 80.0, 80.0, 120.0, 80.0, 80.0, 140.0,
  ];
  final List<double> _colWidths = [
    90.0, 160.0, 90.0, 80.0, 200.0, 100.0, 90.0, 140.0,
  ];

  final _headerHorizCtrl = ScrollController();
  final _bodyHorizCtrl = ScrollController();
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _headerHorizCtrl.addListener(_onHeaderScroll);
    _bodyHorizCtrl.addListener(_onBodyScroll);
    _fetchMenus();
    _fetchMenuTree();
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

  Future<void> _fetchMenus() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final request = GetMenuListRequest(session: widget.session.sessionToken);
      final uri = Uri.parse('${widget.session.apiPath}api/v1/list_menu');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = GetMenuListResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _menus = decoded.menus.toList();
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

  Future<void> _fetchMenuTree() async {
    setState(() {
      _treeLoading = true;
      _treeErrorMessage = null;
    });
    try {
      final request = LoadMenuTreeRequest(session: widget.session.sessionToken);
      final uri = Uri.parse('${widget.session.apiPath}api/v1/load_menu');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );
      if (response.statusCode == 200) {
        final decoded = LoadMenuTreeResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          final encoder = const JsonEncoder.withIndent('  ');
          setState(() => _menuTreeJson = encoder.convert(decoded.menus.toProto3Json()));
        } else {
          setState(() => _treeErrorMessage = decoded.message.isNotEmpty
              ? decoded.message
              : 'Error (code: ${decoded.code})');
        }
      } else {
        setState(() => _treeErrorMessage = 'HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _treeErrorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _treeLoading = false);
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
    _sortedMenus = List.from(_menus);
    if (_sortColumnIndex == 0) {
      _sortedMenus.sort((a, b) {
        final cmp = a.menuId.compareTo(b.menuId);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 1) {
      _sortedMenus.sort((a, b) {
        final cmp = a.menuName.compareTo(b.menuName);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 2) {
      _sortedMenus.sort((a, b) {
        final cmp = a.parentId.compareTo(b.parentId);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 3) {
      _sortedMenus.sort((a, b) {
        final cmp = a.roleId.compareTo(b.roleId);
        return _sortAscending ? cmp : -cmp;
      });
    }
  }

  double get _totalWidth => _colWidths.fold(0.0, (s, w) => s + w);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text('Menus', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (widget.onAddMenu != null)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Menu',
                  onPressed: widget.onAddMenu,
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loading ? null : _fetchMenus,
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
        const Divider(height: 1, thickness: 1),
        _buildMenuTreePanel(),
      ],
    );
  }

  Widget _buildMenuTreePanel() {
    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  'Menu Tree (JSON)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF3949AB),
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh tree',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _treeLoading ? null : _fetchMenuTree,
                ),
              ],
            ),
          ),
          Expanded(
            child: _treeLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SelectableText(
                      _treeErrorMessage != null
                          ? _treeErrorMessage!
                          : (_menuTreeJson ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: _treeErrorMessage != null ? Colors.red : null,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
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
                child: Container(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyRows() {
    if (_sortedMenus.isEmpty) {
      return const Center(
        child: Text('No menus found', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      controller: _bodyHorizCtrl,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _totalWidth,
        child: ListView.separated(
          itemCount: _sortedMenus.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, i) => _buildDataRow(_sortedMenus[i], i),
        ),
      ),
    );
  }

  Widget _buildDataRow(Menu menu, int rowIndex) {
    final isEven = rowIndex % 2 == 0;
    return Container(
      height: 36,
      color: isEven ? Colors.white : const Color(0xFFF8F9FF),
      child: Row(
        children: [
          _buildDataCell(menu.menuId.toString(), 0),
          _buildDataCell(menu.menuName, 1),
          _buildDataCell(menu.parentId.toString(), 2),
          _buildDataCell(menu.roleId.toString(), 3),
          _buildDataCell(menu.link, 4),
          _buildDataCell(menu.target, 5),
          _buildDataCell(menu.bitFlags.toString(), 6),
          _buildActionsCell(menu),
        ],
      ),
    );
  }

  Widget _buildActionsCell(Menu menu) {
    return SizedBox(
      width: _colWidths[7],
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.edit, size: 16, color: Colors.blue.shade600),
            tooltip: 'Modify',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _showModifyDialog(menu),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 16, color: Colors.red.shade400),
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _confirmRemoveMenu(menu),
          ),
        ],
      ),
    );
  }

  Future<void> _showModifyDialog(Menu menu) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ModifyMenuDialog(
        session: widget.session,
        menu: menu,
        onModified: (updated) {
          setState(() {
            final idx = _menus.indexWhere((m) => m.menuId == menu.menuId);
            if (idx >= 0) _menus[idx] = updated;
            _applySorting();
          });
        },
      ),
    );
  }

  Future<void> _confirmRemoveMenu(Menu menu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Menu'),
        content: Text('Remove menu "${menu.menuName}" (ID: ${menu.menuId})?'),
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
    if (confirmed == true) await _removeMenu(menu);
  }

  Future<void> _removeMenu(Menu menu) async {
    try {
      final request = RemoveMenuRequest(
        session: widget.session.sessionToken,
        menuId: menu.menuId,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/remove_menu');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = RemoveMenuResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _menus.removeWhere((m) => m.menuId == menu.menuId);
            _applySorting();
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(decoded.message.isNotEmpty
                    ? decoded.message
                    : 'Error (code: ${decoded.code})'),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        'Total: ${_menus.length} record${_menus.length == 1 ? '' : 's'}',
        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

class _ModifyMenuDialog extends StatefulWidget {
  final AppSession session;
  final Menu menu;
  final void Function(Menu updated) onModified;

  const _ModifyMenuDialog({
    required this.session,
    required this.menu,
    required this.onModified,
  });

  @override
  State<_ModifyMenuDialog> createState() => _ModifyMenuDialogState();
}

class _ModifyMenuDialogState extends State<_ModifyMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _menuNameController;
  late final TextEditingController _parentIdController;
  late final TextEditingController _roleIdController;
  late final TextEditingController _linkController;
  late final TextEditingController _targetController;
  late final TextEditingController _bitFlagsController;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _menuNameController = TextEditingController(text: widget.menu.menuName);
    _parentIdController = TextEditingController(text: widget.menu.parentId.toString());
    _roleIdController = TextEditingController(text: widget.menu.roleId.toString());
    _linkController = TextEditingController(text: widget.menu.link);
    _targetController = TextEditingController(text: widget.menu.target);
    _bitFlagsController = TextEditingController(text: widget.menu.bitFlags.toString());
  }

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
      _errorMessage = null;
    });

    try {
      final updatedMenu = Menu(
        menuId: widget.menu.menuId,
        menuName: _menuNameController.text,
        parentId: Int64.parseInt(_parentIdController.text.isEmpty ? '0' : _parentIdController.text),
        roleId: Int64.parseInt(_roleIdController.text.isEmpty ? '0' : _roleIdController.text),
        link: _linkController.text,
        target: _targetController.text,
        bitFlags: Int64.parseInt(_bitFlagsController.text.isEmpty ? '0' : _bitFlagsController.text),
      );

      final request = ModifyMenuRequest(
        session: widget.session.sessionToken,
        menu: updatedMenu,
      );

      final uri = Uri.parse('${widget.session.apiPath}api/v1/modify_menu');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = ModifyMenuResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          widget.onModified(updatedMenu);
          if (mounted) Navigator.of(context).pop();
        } else {
          setState(() {
            _errorMessage = decoded.message.isNotEmpty
                ? decoded.message
                : 'Error (code: ${decoded.code})';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modify Menu (ID: ${widget.menu.menuId})'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _linkController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Link',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Target',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bitFlagsController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
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
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
