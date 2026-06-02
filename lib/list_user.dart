import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/api.pb.dart';
import 'main.dart';

class ListUserPage extends StatefulWidget {
  final AppSession session;
  final VoidCallback? onAddUser;

  const ListUserPage({super.key, required this.session, this.onAddUser});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<User> _users = [];
  List<User> _sortedUsers = [];
  bool _loading = false;
  String? _errorMessage;

  int _sortColumnIndex = -1;
  bool _sortAscending = true;

  static const List<String> _colLabels = ['User ID', 'User Name', 'Actions'];
  static const List<double> _minColWidths = [80.0, 120.0, 80.0];
  final List<double> _colWidths = [120.0, 240.0, 80.0];

  final _headerHorizCtrl = ScrollController();
  final _bodyHorizCtrl = ScrollController();
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _headerHorizCtrl.addListener(_onHeaderScroll);
    _bodyHorizCtrl.addListener(_onBodyScroll);
    _fetchUsers();
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

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final request = ListUserRequest(session: widget.session.sessionToken);
      final uri = Uri.parse('${widget.session.apiPath}api/v1/list_user');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = ListUserResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _users = decoded.users.toList();
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
    _sortedUsers = List.from(_users);
    if (_sortColumnIndex == 0) {
      _sortedUsers.sort((a, b) {
        final cmp = a.userId.compareTo(b.userId);
        return _sortAscending ? cmp : -cmp;
      });
    } else if (_sortColumnIndex == 1) {
      _sortedUsers.sort((a, b) {
        final cmp = a.userName.compareTo(b.userName);
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
              Text('Users', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (widget.onAddUser != null)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Add User',
                  onPressed: widget.onAddUser,
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loading ? null : _fetchUsers,
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
          // Resize handle — right 7 px of the header cell
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
    if (_sortedUsers.isEmpty) {
      return const Center(
        child: Text('No users found', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      controller: _bodyHorizCtrl,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _totalWidth,
        child: ListView.separated(
          itemCount: _sortedUsers.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
          itemBuilder: (context, i) => _buildDataRow(_sortedUsers[i], i),
        ),
      ),
    );
  }

  Widget _buildDataRow(User user, int rowIndex) {
    final isEven = rowIndex % 2 == 0;
    return Container(
      height: 36,
      color: isEven ? Colors.white : const Color(0xFFF8F9FF),
      child: Row(
        children: [
          _buildDataCell(user.userId.toString(), 0),
          _buildDataCell(user.userName, 1),
          _buildActionsCell(user),
        ],
      ),
    );
  }

  Widget _buildActionsCell(User user) {
    return SizedBox(
      width: _colWidths[2],
      height: 36,
      child: Center(
        child: IconButton(
          icon: Icon(Icons.person_remove, size: 16, color: Colors.red.shade400),
          tooltip: 'Remove',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => _confirmRemoveUser(user),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Remove user "${user.userName}" (ID: ${user.userId})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _removeUser(user);
  }

  Future<void> _removeUser(User user) async {
    try {
      final request = RemoveUserRequest(
        session: widget.session.sessionToken,
        userId: user.userId,
      );
      final uri = Uri.parse('${widget.session.apiPath}api/v1/remove_user');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = RemoveUserResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0) {
          setState(() {
            _users.removeWhere((u) => u.userId == user.userId);
            _applySorting();
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(decoded.message.isNotEmpty ? decoded.message : 'Error (code: ${decoded.code})')),
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
        'Total: ${_users.length} record${_users.length == 1 ? '' : 's'}',
        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}
