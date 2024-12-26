import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../controller/menu/menu_design_controller.dart';

class Node {
  Node({
    required this.title,
    required this.id,
    Iterable<Node>? children,
    this.object,
  }) : _children = <Node>[] {
    if (children == null) return;

    for (final Node child in children) {
      child._parent = this;
      _children.add(child);
    }
  }

  final String title;
  final String id;
  final List<Node> _children;
  final Map<String, dynamic>? object;

  Iterable<Node> get children => _children;

  bool get isLeaf => _children.isEmpty;

  Node? get parent => _parent;
  Node? _parent;

  int get index => _parent?._children.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    if (node._parent == this && node.index < index) {
      index--;
    }

    node.parent?.object?.forEach((key, value) {
      if (key == "children") {
        value as List;
        value.removeWhere((element) => element["_id"] == node.object!["_id"]);
      }
    });
    node
      .._parent?._children.remove(node)
      .._parent = this;
    _children.insert(index, node);
  }
}

extension on TreeDragAndDropDetails<Node> {
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}

class DragAndDropTreeView extends StatefulWidget {
  const DragAndDropTreeView({super.key, required this.dataList});

  final List<Map<String, dynamic>> dataList;

  @override
  State<DragAndDropTreeView> createState() => _DragAndDropTreeViewState();
}

class _DragAndDropTreeViewState extends State<DragAndDropTreeView> {
  late final Node root;
  late final TreeController<Node> treeController;

  MenuDesignController menuDesignController = Get.find<MenuDesignController>();
  var temp = [];

  @override
  void initState() {
    super.initState();
    root = Node(title: "", id: "");

    populateExampleTree(root, widget.dataList);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  Future<void> onNodeAccepted(TreeDragAndDropDetails<Node> details) async {
    Node? newParent;
    int newIndex = 0;
    Node draggedNode = details.draggedNode;

    details.mapDropPosition(
      whenAbove: () {
        newParent = details.targetNode.parent;
        draggedNode.object?['parentid'] = newParent?.object?['parentid'] ?? draggedNode.object?['menuid'];
        newIndex = details.targetNode.index;
        devPrint(1);
      },
      whenInside: () {
        newParent = details.targetNode;
        newIndex = details.targetNode.children.length;
        draggedNode.object?['parentid'] = newParent?.object?['parentid'];

        treeController.setExpansionState(details.targetNode, true);
        devPrint(2);
      },
      whenBelow: () {
        newParent = details.targetNode.parent;
        draggedNode.object?['parentid'] = newParent?.object?['parentid'] ?? draggedNode.object?['menuid'];
        newIndex = details.targetNode.index + 1;
        devPrint(3);
      },
    );

    int parentDepth = 0;
    bool canAdd = true;

    if (!draggedNode.isLeaf) {
      for (var i = 0; i < draggedNode._children.length; i++) {
        if (canAdd) {
          canAdd = draggedNode._children[i].children.isEmpty;
        }
      }
    } else {
      canAdd = true;
    }

    if (canAdd) {
      if (newParent != root) {
        if (newParent!.parent != root) {
          if (newParent!.parent!.parent != root) {
            parentDepth = 3;
          } else {
            parentDepth = 2;
          }
        } else {
          parentDepth = 1;
        }
      } else {
        parentDepth = 0;
      }
      if (parentDepth < 1 || (parentDepth == 1 && draggedNode.isLeaf)) {
        (newParent ?? root).insertChild(newIndex, draggedNode);
      }
    }
    temp.clear();
    treeController.rebuild();
    var tempList = treeController.roots.toList();
    for (var i = 0; i < tempList.length; i++) {
      Map<String, dynamic>? childrenObject = {};
      childrenObject = tempList[i].object;
      List<Map<String, dynamic>> children = [];
      children = setMenuDesign(tempList[i]._children);

      childrenObject?['children'] = children;
      temp.add(childrenObject);
    }
    menuDesignController.handleTreeData(temp);
  }

  List<Map<String, dynamic>> setMenuDesign(List<Node> children) {
    List<Map<String, dynamic>> childrenList = [];
    for (var k = 0; k < children.length; k++) {
      Map<String, dynamic>? object = {};
      object = children[k].object;
      List<Map<String, dynamic>> underChildrenList = setMenuDesign(children[k]._children);
      object?['children'] = underChildrenList;
      childrenList.add(object!);
    }

    return childrenList;
  }

  @override
  Widget build(BuildContext context) {
    final IndentGuide indentGuide = DefaultIndentGuide.of(context);
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: indentGuide is AbstractLineGuide ? indentGuide.thickness : 2.0,
    );

    return AnimatedTreeView<Node>(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return DragAndDropTreeTile(
          entry: entry,
          borderSide: borderSide,
          onNodeAccepted: onNodeAccepted,
          onFolderPressed: () => treeController.toggleExpansion(entry.node),
        );
      },
      duration: const Duration(milliseconds: 300),
    );
  }
}

class DragAndDropTreeTile extends StatelessWidget {
  const DragAndDropTreeTile({
    super.key,
    required this.entry,
    required this.onNodeAccepted,
    this.borderSide = BorderSide.none,
    this.onFolderPressed,
  });

  final TreeEntry<Node> entry;
  final TreeDragTargetNodeAccepted<Node> onNodeAccepted;
  final BorderSide borderSide;
  final VoidCallback? onFolderPressed;

  @override
  Widget build(BuildContext context) {
    return TreeDragTarget<Node>(
      node: entry.node,
      onNodeAccepted: onNodeAccepted,
      canToggleExpansion: true,
      builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
        Decoration? decoration;

        if (details != null) {
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () => Border(top: borderSide),
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () => Border(bottom: borderSide),
            ),
          );
        }

        return TreeDraggable<Node>(
          node: entry.node,
          childWhenDragging: Opacity(
            opacity: .5,
            child: IgnorePointer(
              child: TreeTile(entry: entry),
            ),
          ),
          feedback: IntrinsicWidth(
            child: Material(
              elevation: 4,
              child: TreeTile(
                entry: entry,
                showIndentation: false,
                onFolderPressed: () {},
              ),
            ),
          ),
          child: TreeTile(
            entry: entry,
            onFolderPressed: entry.node.isLeaf ? null : onFolderPressed,
            decoration: decoration,
          ),
        );
      },
    );
  }
}

class TreeTile extends StatelessWidget {
  const TreeTile({
    super.key,
    required this.entry,
    this.onFolderPressed,
    this.decoration,
    this.showIndentation = true,
  });

  final TreeEntry<Node> entry;
  final VoidCallback? onFolderPressed;
  final Decoration? decoration;
  final bool showIndentation;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        children: [
          FolderButton(
            isOpen: entry.node.isLeaf ? null : entry.isExpanded,
            onPressed: onFolderPressed,
          ),
          Expanded(
            child: Text(entry.node.title),
          ),
        ],
      ),
    );

    if (decoration != null) {
      content = DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }

    if (showIndentation) {
      return TreeIndentation(
        entry: entry,
        child: content,
      );
    }

    return content;
  }
}

void populateExampleTree(
  Node node,
  List<Map<String, dynamic>> dataList, [
  int level = 0,
  int minChildCount = 3,
]) {
  if (level > 2) return;

  for (var element in dataList) {
    final child = Node(title: element["menuname"], object: element, id: element["moduleid"]).._parent = node;
    node._children.add(child);
    populateExampleTree(
      child,
      List<Map<String, dynamic>>.from(element["children"] ?? []),
      level + 1,
    );
  }
}
