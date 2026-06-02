import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'generated/api.pb.dart';
import 'add_datasource.dart';
import 'add_menu.dart';
import 'add_user.dart';
import 'list_datasource.dart';
import 'list_menu.dart';
import 'list_user.dart';

void main() {
  runApp(const MyApp());
}

// ─── App entry ────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetricsExplorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const GlobalConfigPage(),
    );
  }
}

// ─── Session (shared across all authenticated API calls) ──────────────────────

class AppSession {
  final String apiPath;
  final String sessionToken;
  final String userName;
  final String salt;

  const AppSession({
    required this.apiPath,
    required this.sessionToken,
    required this.userName,
    required this.salt,
  });

  Map<String, String> get headers => {
        'Content-Type': 'application/protobuf',
        'X-Session': sessionToken,
      };
}

// ─── Global config ────────────────────────────────────────────────────────────

class GlobalConfigPage extends StatefulWidget {
  const GlobalConfigPage({super.key});

  @override
  State<GlobalConfigPage> createState() => _GlobalConfigPageState();
}

class _GlobalConfigPageState extends State<GlobalConfigPage> {
  @override
  void initState() {
    super.initState();
    _fetchGlobalConfigs();
  }

  Future<void> _fetchGlobalConfigs() async {
    try {
      final uri = Uri.base.resolve('../api/v1/get_global_configs');
      final response =
          await http.post(uri, headers: {'Content-Type': 'application/protobuf'});
      if (response.statusCode == 200) {
        final decoded = GetGlobalConfigsResponse.fromBuffer(response.bodyBytes);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginPage(salt: decoded.salt, apiPath: decoded.apiPath),
          ),
        );
      } else {
        _showError('HTTP Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ErrorPage(message: message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ─── Error page ───────────────────────────────────────────────────────────────

class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

// ─── Login ────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  final String salt;
  final String apiPath;

  const LoginPage({super.key, required this.salt, required this.apiPath});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final hashedPassword =
          sha256.convert(utf8.encode(widget.salt + _passwordController.text)).toString();

      final request = LoginRequest(
        userName: _userNameController.text,
        passwd: hashedPassword,
      );

      final uri = Uri.parse('${widget.apiPath}api/v1/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/protobuf'},
        body: request.writeToBuffer(),
      );

      if (response.statusCode == 200) {
        final decoded = LoginResponse.fromBuffer(response.bodyBytes);
        if (decoded.code == 0 && decoded.session.isNotEmpty) {
          if (!mounted) return;
          final session = AppSession(
            apiPath: widget.apiPath,
            sessionToken: decoded.session,
            userName: _userNameController.text,
            salt: widget.salt,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainPage(session: session)),
          );
          return;
        }
        setState(() {
          _errorMessage = decoded.message.isNotEmpty
              ? decoded.message
              : 'Login failed (code: ${decoded.code})';
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetricsExplorer'),
      ),
      body: Center(
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
                      'Log In',
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
                      onFieldSubmitted: (_) => _loading ? null : _login(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password is required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('LogIn'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tree node data model ─────────────────────────────────────────────────────

class TreeNode {
  final String id;
  final String label;
  final String link;
  final bool expanded;
  final List<TreeNode> children;

  const TreeNode({
    required this.id,
    required this.label,
    this.link = '',
    this.expanded = true,
    this.children = const [],
  });
}

// ─── Main page ────────────────────────────────────────────────────────────────

class MainPage extends StatefulWidget {
  final AppSession session;

  const MainPage({super.key, required this.session});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double? _sidebarWidth;
  bool _sidebarVisible = true;
  String? _selectedNodeId;
  List<TreeNode> _menuTree = [];
  bool _menuLoading = true;

  static const double _minSidebarWidth = 140;
  static const double _dividerWidth = 5;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
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
        if (decoded.code == 0 && decoded.hasMenus()) {
          setState(() {
            _menuTree = _convertMenuTree(decoded.menus.children);
            _menuLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _menuLoading = false);
  }

  List<TreeNode> _convertMenuTree(List<MenuTreeNode> nodes) {
    return nodes
        .map((n) => TreeNode(
              id: n.menuId.toString(),
              label: n.menuName,
              link: n.link,
              expanded: n.expanded,
              children: _convertMenuTree(n.children),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetricsExplorer'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Hello, ${widget.session.userName}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _sidebarWidth ??= constraints.maxWidth * 0.2;
          final maxSidebar = constraints.maxWidth * 0.6;

          return Row(
            children: [
              if (_sidebarVisible) ...[
                SizedBox(
                  width: _sidebarWidth,
                  child: _buildSidebar(),
                ),
                _ResizeDivider(
                  width: _dividerWidth,
                  onDrag: (d) {
                    setState(() {
                      _sidebarWidth = (_sidebarWidth! + d.delta.dx)
                          .clamp(_minSidebarWidth, maxSidebar);
                    });
                  },
                ),
              ] else
                _CollapsedStrip(
                  onTap: () => setState(() => _sidebarVisible = true),
                ),
              Expanded(child: _buildContentArea()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Hide sidebar',
                  child: InkWell(
                    onTap: () => setState(() => _sidebarVisible = false),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.keyboard_double_arrow_left,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _menuLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _menuTree
                          .map((n) => _SidebarTreeNode(
                                node: n,
                                selectedId: _selectedNodeId,
                                onSelected: (link) =>
                                    setState(() => _selectedNodeId = link),
                                depth: 0,
                              ))
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    if (_selectedNodeId == null) {
      return const Center(
        child: Text(
          'Select an item from the menu',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    if (_selectedNodeId == 'user') {
      return ListUserPage(
        session: widget.session,
        onAddUser: () => setState(() => _selectedNodeId = 'add_user'),
      );
    }
    if (_selectedNodeId == 'add_user') {
      return AddUserPage(session: widget.session);
    }
    if (_selectedNodeId == 'data_source') {
      return ListDatasourcePage(
        session: widget.session,
        onAddDatasource: () => setState(() => _selectedNodeId = 'add_datasource'),
      );
    }
    if (_selectedNodeId == 'add_datasource') {
      return AddDatasourcePage(session: widget.session);
    }
    if (_selectedNodeId == 'menus') {
      return ListMenuPage(
        session: widget.session,
        onAddMenu: () => setState(() => _selectedNodeId = 'add_menu'),
      );
    }
    if (_selectedNodeId == 'add_menu') {
      return AddMenuPage(session: widget.session);
    }
    return Center(
      child: Text(
        'Content: $_selectedNodeId',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

// ─── Animated resize divider ──────────────────────────────────────────────────

class _ResizeDivider extends StatefulWidget {
  final double width;
  final GestureDragUpdateCallback onDrag;

  const _ResizeDivider({required this.width, required this.onDrag});

  @override
  State<_ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends State<_ResizeDivider> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onHorizontalDragUpdate: widget.onDrag,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          color: _isHovered
              ? const Color(0xFF5C6BC0).withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}

// ─── Collapsed sidebar strip ──────────────────────────────────────────────────

class _CollapsedStrip extends StatefulWidget {
  final VoidCallback onTap;

  const _CollapsedStrip({required this.onTap});

  @override
  State<_CollapsedStrip> createState() => _CollapsedStripState();
}

class _CollapsedStripState extends State<_CollapsedStrip> {
  bool _isHovered = false;
  static const double _baseWidth = 10.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Show sidebar',
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isHovered ? _baseWidth * 2.4 : _baseWidth,
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFF5C6BC0).withValues(alpha: 0.15)
                  : Colors.grey.shade200,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: AnimatedOpacity(
              opacity: _isHovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Center(
                child: Icon(
                  Icons.keyboard_double_arrow_right,
                  size: 16,
                  color: Color(0xFF5C6BC0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated sidebar tree node ───────────────────────────────────────────────

class _SidebarTreeNode extends StatefulWidget {
  final TreeNode node;
  final String? selectedId;
  final void Function(String id) onSelected;
  final int depth;

  const _SidebarTreeNode({
    required this.node,
    required this.selectedId,
    required this.onSelected,
    required this.depth,
  });

  @override
  State<_SidebarTreeNode> createState() => _SidebarTreeNodeState();
}

class _SidebarTreeNodeState extends State<_SidebarTreeNode>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  bool _isHovered = false;

  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.node.expanded;
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.node.expanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  bool _containsSelected(TreeNode node, String? selectedId) {
    if (selectedId == null) return false;
    if (node.link.isNotEmpty && node.link == selectedId) return true;
    for (final child in node.children) {
      if (_containsSelected(child, selectedId)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLeaf = widget.node.link.isNotEmpty;
    final isSelected = isLeaf && widget.node.link == widget.selectedId;
    final hasSelectedChild =
        !isLeaf && _containsSelected(widget.node, widget.selectedId);
    final leftPadding = 12.0 + widget.depth * 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: isLeaf ? () => widget.onSelected(widget.node.link) : _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(
                left: leftPadding,
                right: 12,
                top: 7,
                bottom: 7,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5C6BC0).withValues(alpha: 0.12)
                    : _isHovered
                        ? Colors.grey.withValues(alpha: 0.12)
                        : Colors.transparent,
                border: isSelected
                    ? const Border(
                        left: BorderSide(color: Color(0xFF5C6BC0), width: 3),
                      )
                    : const Border(
                        left: BorderSide(color: Colors.transparent, width: 3),
                      ),
              ),
              child: Row(
                children: [
                  if (!isLeaf) ...[
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: hasSelectedChild
                            ? const Color(0xFF5C6BC0)
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else
                    const SizedBox(width: 20),
                  Icon(
                    isLeaf ? Icons.article_outlined : Icons.folder_outlined,
                    size: 15,
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : hasSelectedChild
                            ? const Color(0xFF5C6BC0).withValues(alpha: 0.7)
                            : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.node.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isSelected
                            ? const Color(0xFF3949AB)
                            : hasSelectedChild
                                ? const Color(0xFF5C6BC0)
                                : const Color(0xFF333333),
                        fontWeight: (isSelected || (hasSelectedChild && !isLeaf))
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLeaf)
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.node.children
                  .map((c) => _SidebarTreeNode(
                        node: c,
                        selectedId: widget.selectedId,
                        onSelected: widget.onSelected,
                        depth: widget.depth + 1,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
