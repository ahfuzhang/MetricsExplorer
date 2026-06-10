import 'dart:convert';

import 'package:flutter/material.dart';

import 'add_datasource.dart';
import 'add_menu.dart';
import 'add_user.dart';
import 'generated/api.pb.dart';
import 'list_datasource.dart';
import 'list_menu.dart';
import 'list_user.dart';
import 'metricsui/show_labels.dart';
import 'metricsui/show_metric_names.dart';
import 'metricsui/show_pods.dart';
import 'session.dart';

// ─── Tree node data model ─────────────────────────────────────────────────────

class TreeNode {
  final String id;
  final String label;
  final String link;
  final int bitFlags;
  final List<TreeNode> children;

  const TreeNode({
    required this.id,
    required this.label,
    this.link = '',
    this.bitFlags = 0,
    this.children = const [],
  });

  // bit 0: non-leaf node should be expanded by default
  bool get expanded => (bitFlags & 1) != 0;

  // bit 1: all descendant nodes should be sorted by menu name
  bool get sortChildrenByName => (bitFlags & 2) != 0;
}

// ─── Animated sidebar tree node ───────────────────────────────────────────────

class SidebarTreeNode extends StatefulWidget {
  final TreeNode node;
  final String? selectedId;
  final void Function(String id, String link) onSelected;
  final int depth;

  const SidebarTreeNode({
    super.key,
    required this.node,
    required this.selectedId,
    required this.onSelected,
    required this.depth,
  });

  @override
  State<SidebarTreeNode> createState() => _SidebarTreeNodeState();
}

class _SidebarTreeNodeState extends State<SidebarTreeNode>
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
    if (node.id == selectedId) return true;
    for (final child in node.children) {
      if (_containsSelected(child, selectedId)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLeaf = widget.node.children.isEmpty;
    final isSelected = isLeaf && widget.node.id == widget.selectedId;
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
            onTap: isLeaf ? () => widget.onSelected(widget.node.id, widget.node.link) : _toggle,
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
                  .map((c) => SidebarTreeNode(
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

// ─── Content area router ──────────────────────────────────────────────────────

class ContentArea extends StatelessWidget {
  final String? selectedNodeId;
  final AppSession session;
  final void Function(String id) onNavigate;

  const ContentArea({
    super.key,
    required this.selectedNodeId,
    required this.session,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedNodeId == null) {
      return const Center(
        child: Text(
          'Select an item from the menu',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    if (selectedNodeId == 'user') {
      return ListUserPage(
        session: session,
        onAddUser: () => onNavigate('add_user'),
      );
    }
    if (selectedNodeId == 'add_user') {
      return AddUserPage(session: session);
    }
    if (selectedNodeId == 'data_source') {
      return ListDatasourcePage(
        session: session,
        onAddDatasource: () => onNavigate('add_datasource'),
      );
    }
    if (selectedNodeId == 'add_datasource') {
      return AddDatasourcePage(session: session);
    }
    if (selectedNodeId == 'menus') {
      return ListMenuPage(
        session: session,
        onAddMenu: () => onNavigate('add_menu'),
      );
    }
    if (selectedNodeId == 'add_menu') {
      return AddMenuPage(session: session);
    }
    if (selectedNodeId!.startsWith('{')) {
      try {
        final map = jsonDecode(selectedNodeId!) as Map<String, dynamic>;
        final name = map['name'] as String?;
        final type = map['type'] as String?;
        if (name != null && type != null) {
          final ds = VictoriaMetricsDatasource(datasourceName: name);
          if (type == 'Labels') {
            return ShowLabelsPanel(
              key: ValueKey('labels_$name'),
              session: session,
              datasource: ds,
            );
          }
          if (type == 'Metric Names') {
            return ShowMetricNamesPanel(
              key: ValueKey('metric_names_$name'),
              session: session,
              datasource: ds,
            );
          }
          if (type == 'Pods') {
            return ShowPodsPanel(
              key: ValueKey('pods_$name'),
              session: session,
              datasource: ds,
            );
          }
        }
      } catch (_) {}
    }
    return Center(
      child: Text(
        'Content: $selectedNodeId',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

