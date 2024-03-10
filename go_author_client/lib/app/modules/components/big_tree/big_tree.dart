import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/modules/components/dashed_line/dashed_line.dart';

import 'big_node.dart';

class BigTree extends StatelessWidget {
  late BuildContext context;
  final double indent = 25;
  late EdgeInsetsGeometry titlePadding;
  late RxList<BigNode> nodes;
  bool checkable;
  bool checkedAll = false;
  bool verticalLineVisable = false;
  bool horizontalLineVisable = false;
  // 所有节点的"线性"缓存
  late Map<int, BigNode> nodesMap = {};
  // 半选节点
  Set<int> halfCheckedNodes = {};
  // 全选节点
  Set<int> fullCheckedNodes = {};
  // 初始化时选中的节点
  RxList<int> initCheckedNodes;

  Function(int status, BigNode node, Set<int> halfCheckedNodes, Set<int> fullCheckedNodes)? onChange;
  Function(bool expanded, BigNode node)? onExpanded;

  BigTree({
    super.key,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 0),
    // 必须是树型结构数据
    required this.nodes,
    // 构造参数，只需要设置全选节点，初始化过程中会自动将父节点设置为半选
    required this.initCheckedNodes,
    this.onChange,
    this.onExpanded,
    this.checkable = false,
    this.checkedAll = false,
    this.verticalLineVisable = false,
    this.horizontalLineVisable = false,
  });

  @override
  Widget build(BuildContext context) {
    this.context = context;
    nodesToMap(this.nodes);
    fullCheckedNodes.addAll(initCheckedNodes);
    selectNodeIds(BIGTREE_STATUS_CHECKED_FULL, initCheckedNodes);
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (BuildContext context, int index) {
        return buildNode(nodes[index], 0);
      },
    );
  }

  bool isSingleNode(BigNode node) {
    return node.childs.isEmpty;
  }

  void nodesToMap(List<BigNode> nodes) {
    for (var node in nodes) {
      if (this.checkedAll) {
        node.checked!.value = BIGTREE_STATUS_CHECKED_FULL;
      }
      nodesMap[node.id] = node;
      nodesToMap(node.childs);
    }
  }

  // index为不可展开的菜单项的累计下标
  Widget buildNode(BigNode node, int level) {
    if (isSingleNode(node)) {
      return Obx(() {
        return ListTile(
          // leading: VerticalDivider(width: 2),
          title: Row(
            children: [
              // 左侧缩进
              if (!verticalLineVisable) SizedBox(width: level * indent),
              if (verticalLineVisable)
                for (int i = 0; i < level; i++)
                  // 缩进线
                  SizedBox(
                    width: indent,
                    height: 40.0,
                    // 实线
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     right: BorderSide(width: 0.8, color: Colors.grey),
                    //     top: BorderSide(width: 0),
                    //     bottom: BorderSide(width: 0),
                    //   ),
                    // ),
                    // 虚线
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DashedLine(
                        axis: Axis.vertical,
                        dashedWidth: 1,
                        dashedHeight: 1,
                        dashedTotalLengthWith: 38,
                      ),
                    ),
                  ),

              // 带缩进线时添加的占位
              if (verticalLineVisable)
                SizedBox(
                  width: indent / 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    // 水平线
                    child: horizontalLineVisable
                        ? DashedLine(
                            axis: Axis.horizontal,
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            dashedWidth: 2,
                            dashedHeight: 1,
                            count: 4,
                          )
                        : null,
                  ),
                ),

              // 展开图标, 这里只是占位符
              SizedBox(
                width: 24,
                child: Icon(Icons.arrow_right),
              ),
              // 可点击部分, 这里点击复选框图标和标题都是选中，如果希望只点复选框就选中，直接使用Checkbox即可
              InkWell(
                child: Row(
                  children: [
                    // 选择框, 由于使用了obx, 所以第二个条件设置为永远false
                    if (this.checkable || node.checked!.value == -1)
                      node.checked!.value == BIGTREE_STATUS_CHECKED_FULL //
                          ? Icon(Icons.check_box_outlined) //
                          : (node.checked!.value == BIGTREE_STATUS_CHECKED_HALF ? Icon(Icons.square_sharp) : Icon(Icons.check_box_outline_blank)),
                    // 节点名
                    Padding(
                      padding: titlePadding,
                      child: Text(node.title, style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                onTap: () {
                  int newStatus = node.checked!.value > 0 ? BIGTREE_STATUS_CHECKED_NONE : BIGTREE_STATUS_CHECKED_FULL;
                  selectNode(newStatus, node);
                  if (this.onChange != null) {
                    this.onChange!(newStatus, node, halfCheckedNodes, fullCheckedNodes);
                  }
                },
              ),
            ],
          ),
        );
      });
    } else {
      return Obx(() {
        return Theme(
          data: Theme.of(context).copyWith(
            // 去掉展开时的上下横线
            dividerColor: Colors.transparent,
            // 缩小行距, 目前不支持自定义行距
            listTileTheme: ListTileTheme.of(context).copyWith(
              dense: true,
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.all(0),
            ),
          ),
          child: ExpansionTile(
            // backgroundColor: node.id % 2 == 0 ? Colors.blue : Colors.green,
            // 隐藏右侧箭头图标
            trailing: Container(width: 0, height: 0, color: Colors.red),
            leading: null,
            childrenPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            title: Row(
              children: [
                // 左侧缩进
                if (!verticalLineVisable) SizedBox(width: level * indent),
                if (verticalLineVisable)
                  for (int i = 0; i < level; i++)
                    // 缩进线
                    SizedBox(
                      width: indent,
                      height: 40.0,
                      // 实线
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     right: BorderSide(width: 0.8, color: Colors.grey),
                      //     top: BorderSide(width: 0),
                      //     bottom: BorderSide(width: 0),
                      //   ),
                      // ),
                      // 虚线
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DashedLine(
                          axis: Axis.vertical,
                          dashedWidth: 1,
                          dashedHeight: 1,
                          dashedTotalLengthWith: 38,
                        ),
                      ),
                    ),

                // 带缩进线时添加的占位
                if (verticalLineVisable)
                  SizedBox(
                    width: indent / 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      // 水平线
                      child: horizontalLineVisable && node.parentId > 0
                          ? DashedLine(
                              axis: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                              dashedWidth: 2,
                              dashedHeight: 1,
                              count: 4,
                            )
                          : null,
                    ),
                  ),

                // 展开图标
                SizedBox(
                  width: 24,
                  child: !node.expanded!.value ? Icon(Icons.chevron_right) : Icon(Icons.expand_more),
                ),
                // 可点击部分, 这里点击复选框图标和标题都是选中，如果希望只点复选框就选中，直接使用Checkbox即可
                InkWell(
                  child: Row(
                    children: [
                      // 选择框, 由于使用了obx, 所以第二个条件设置为永远false
                      if (this.checkable || node.checked!.value == -1)
                        node.checked!.value == BIGTREE_STATUS_CHECKED_FULL //
                            ? Icon(Icons.check_box_outlined) //
                            : (node.checked!.value == BIGTREE_STATUS_CHECKED_HALF ? Icon(Icons.square_sharp) : Icon(Icons.check_box_outline_blank)),
                      // 节点名
                      Padding(
                        padding: titlePadding,
                        child: Text(node.title, style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  onTap: () {
                    // 被点击的节点，只会出现未选或全选的状态，半选只有子节点选中状态变化才会出现
                    int newStatus = node.checked!.value <= BIGTREE_STATUS_CHECKED_HALF ? BIGTREE_STATUS_CHECKED_FULL : BIGTREE_STATUS_CHECKED_NONE;
                    selectNode(newStatus, node);
                    if (this.onChange != null) {
                      this.onChange!(newStatus, node, halfCheckedNodes, fullCheckedNodes);
                    }
                  },
                ),
              ],
            ),
            // 控制是否展开的属性
            initiallyExpanded: node.expanded!.value,
            children: node.childs.map((child) {
              return buildNode(child, level + 1);
            }).toList(),
            onExpansionChanged: (bool expanded) {
              node.expanded!.value = expanded;
              // 由于ExpansionTile收起时，会将所有嵌套的子ExpansionTile也同时收起
              // 所以需要同步子ExpansionTile的属性
              syncExpansionTile(expanded, node);
              if (this.onExpanded != null) {
                this.onExpanded!(expanded, node);
              }
            },
          ),
        );
      });
    }
  }

  // 获取子节点选中数量来判断是否是全选或者半选
  int getCheckedCount(BigNode node) {
    int count = 0;
    for (var n in node.childs) {
      if (n.checked!.value > BIGTREE_STATUS_CHECKED_NONE) {
        count++;
      }
    }
    return count;
  }

  // 收起复合节点时同步子复合节点的图标状态
  void syncExpansionTile(bool expanded, BigNode node) {
    if (expanded) {
      return;
    }
    for (var child in node.childs) {
      if (!isSingleNode(child)) {
        child.expanded!.value = expanded;
        syncExpansionTile(expanded, child);
      }
    }
  }

  // 同步选中状态缓存数组
  void syncCheckedCache(BigNode node) {
    switch (node.checked!.value) {
      case BIGTREE_STATUS_CHECKED_FULL:
        fullCheckedNodes.add(node.id);
        halfCheckedNodes.remove(node.id);
        break;
      case BIGTREE_STATUS_CHECKED_HALF:
        halfCheckedNodes.add(node.id);
        fullCheckedNodes.remove(node.id);
        break;
      default:
        fullCheckedNodes.remove(node.id);
        halfCheckedNodes.remove(node.id);
        break;
    }
  }

  // 递归选择子节点
  void selectChilds(int status, BigNode node) {
    node.checked!.value = status;
    syncCheckedCache(node);
    for (var child in node.childs) {
      child.checked!.value = status != BIGTREE_STATUS_CHECKED_NONE ? BIGTREE_STATUS_CHECKED_FULL : BIGTREE_STATUS_CHECKED_NONE;
      syncCheckedCache(child);
      if (child.childs.isNotEmpty) {
        selectChilds(status, child);
      }
    }
  }

  // 递归选择父节点
  void selectParent(int status, BigNode? parent) {
    if (parent == null) {
      return;
    }
    // 再来检测是否是半选
    int selectCount = getCheckedCount(parent);
    if (selectCount <= 0) {
      // 未选状态
      parent.checked!.value = BIGTREE_STATUS_CHECKED_NONE;
    } else if (selectCount >= parent.childs.length) {
      // 全选状态
      parent.checked!.value = BIGTREE_STATUS_CHECKED_FULL;
    } else {
      // 半选状态
      parent.checked!.value = BIGTREE_STATUS_CHECKED_HALF;
    }
    syncCheckedCache(parent);
    if (parent.parentId > 0) {
      selectParent(status, nodesMap[parent.parentId]);
    }
  }

  // 设置节点选中状态, 包括子节点和父节点的选择状态同步
  void selectNode(int status, BigNode node) {
    node.checked!.value = status;
    syncCheckedCache(node);
    // 设置父节点
    if (node.parentId > 0) {
      selectParent(status, nodesMap[node.parentId]);
    }
    // 设置子节点
    for (BigNode child in node.childs) {
      selectChilds(status, child);
    }
  }

  // 批量选中节点
  void selectNodes(int status, List<BigNode> nodes) {
    for (var node in nodes) {
      selectNode(status, node);
    }
  }

  // 批量选中节点
  void selectNodeIds(int status, List<int> ids) {
    for (var id in ids) {
      var node = nodesMap[id];
      if (node != null) {
        selectNode(status, node);
      }
    }
  }

  List<BigNode> idsToNodes(Set<int> ids) {
    List<BigNode> list = [];
    for (var id in ids) {
      var node = nodesMap[id];
      if (node != null) {
        list.add(node);
      }
    }
    return list;
  }
}
