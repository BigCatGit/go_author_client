import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_author_client/app/api/base_api.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';
import 'package:go_author_client/app/modules/components/big_tree/big_node.dart';
import 'package:go_author_client/app/modules/components/big_tree/big_tree.dart';
import 'package:go_author_client/app/modules/components/dialog/big_dialog.dart';

import 'role_manage_controller.dart';

class RoleManageView extends GetView<RoleManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final treeKey = GlobalKey<ScaffoldState>();
  final RxList<BigNode> allModules = <BigNode>[].obs;
  final RxList<int> initCheckedNodes = <int>[].obs;
  List<BigNode> hasModules = [];
  late int roleId = 0;
  final int roolNodeId = 0xFFFFFFFFFFFFFFF;
  RxBool treeCheckAll = false.obs;

  RoleManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "角色管理",
      searchUrl: "/admin/system/role/listPage",
      insertUrl: "/admin/system/role/insert",
      updateUrl: "/admin/system/role/update",
      deleteUrl: "/admin/system/role/delete",
      cleanUrl: "/admin/system/role/clean",
      queryParam: QueryParam(),
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          minimumWidth: 100,
          allowEditing: false,
          allowSearch: false,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "name",
          allowSearch: true,
          operator: "like",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "角色名",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "note",
          minimumWidth: 120,
          label: "备注",
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "create_time",
          minimumWidth: 240,
          label: "创建时间",
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "update_time",
          minimumWidth: 240,
          label: "更新时间",
        ),
        BigDataColumn(
          label: "操作",
          name: "control",
          ctrlType: "control",
          minimumWidth: 480,
          allowEditing: false,
          allowSearch: false,
          allowSorting: false,
          widgets: [
            BigButton(
              text: "设置权限",
              onPressed: (col, rowIndex, id, row) async {
                this.roleId = id;
                this.treeCheckAll.value = this.roleId == 1;
                this.closePermissionDialog();
                await initTreeData(id);
                this.openPermissionDialog();
              },
            ),
          ],
          dataType: '',
        ),
      ],
      searchFields: [
        // 嵌套子查询
        // BigDataField(
        //   label: "模块名",
        //   name: "module_name", // 这里要取一个在当前页面唯一的列名
        //   subQueryParam: SubQueryParam(
        //     table: 'module',
        //     where: 'module_id = (?)',
        //     sub_column: 'module.id',
        //     sub_where: 'module.name = ?',
        //   ),
        // ),
      ],
      coverWidget: BigDialog(
        title: "角色权限选择",
        buttonsVisible: true,
        child: Obx(
          () => Container(
            padding: EdgeInsets.all(10),
            child: BigTree(
              key: treeKey,
              titlePadding: EdgeInsets.symmetric(horizontal: 8),
              checkable: true,
              checkedAll: treeCheckAll.value,
              verticalLineVisable: true,
              horizontalLineVisable: true,
              nodes: allModules,
              initCheckedNodes: initCheckedNodes,
              onChange: (status, node, halfCheckedNodes, fullCheckedNodes) {},
            ),
          ),
        ),
        onClose: (widget) {
          (scaffoldKey.currentWidget as BigDataControl).datagrid.closeCover();
        },
        onCancel: (dialog) {
          this.closePermissionDialog();
        },
        onConfirm: (dialog) async {
          if (this.roleId == 1) {
            BotToast.showText(text: "超级管理员不可编辑权限");
            return;
          }
          var modules = [...getTreeCtrl().fullCheckedNodes, ...getTreeCtrl().halfCheckedNodes];
          modules.remove(roolNodeId);
          var resp = await BaseApi().post("/admin/system/permission/updateRolePermission", {"roleId": this.roleId, "modules": modules}, {});
          if (resp == null || resp["code"] != 200) {
            BotToast.showText(text: "请求失败");
          } else {
            BotToast.showText(text: "操作成功");
            this.closePermissionDialog();
          }
        },
      ),
    );
  }

  void openPermissionDialog() {
    (scaffoldKey.currentWidget as BigDataControl).datagrid.openCover();
  }

  void closePermissionDialog() {
    (scaffoldKey.currentWidget as BigDataControl).datagrid.closeCover();
  }

  BigTree getTreeCtrl() {
    return treeKey.currentWidget as BigTree;
  }

  Future<void> initTreeData(int id) async {
    this.allModules.value = [
      // 添加一个虚拟的根节点
      BigNode(
        id: roolNodeId,
        title: "全部",
        parentId: 0,
        expanded: true.obs,
        childs: (await this.initAllModules()).map((node) {
          node.parentId = roolNodeId;
          return node;
        }).toList(),
      )
    ];
    this.hasModules = await this.initHasModules(id);
    // 将已有的模块的最低层单节点设置为树的选中节点
    this.initCheckedNodes.clear();
    this.initTreeCheckeds(this.hasModules);
  }

  Future<List<BigNode>> initAllModules() async {
    List<BigNode> list = [];
    // 拉取后台树型数据，必须要是树型数据
    var resp = await BaseApi().get("/admin/system/module/getAllModules", {"istree": true}, {});
    if (resp == null || resp["code"] != 200) {
      return list;
    }
    return moduleTreeToBigTree(resp["data"]);
  }

  // 将服务器返回的树型数据复制为树型节点数据
  List<BigNode> moduleTreeToBigTree(List<dynamic> list) {
    List<BigNode> tree = [];
    for (var item in list) {
      tree.add(BigNode(
        id: item["id"],
        title: item["name"],
        parentId: item["parent_id"],
        childs: item["childs"] != null ? moduleTreeToBigTree(item["childs"]) : [],
      ));
    }
    return tree;
  }

  Future<List<BigNode>> initHasModules(int id) async {
    List<BigNode> list = [];
    // 拉取后台线性数据
    var resp = await BaseApi().get("/admin/system/permission/getModulesByRoleId", {
      "id": id,
      "istree": false,
    }, {});
    if (resp == null || resp["code"] != 200) {
      return list;
    }
    for (var item in resp["data"]) {
      list.add(BigNode(id: item["id"], title: item["name"], alone: item["alone"]));
    }
    return list;
  }

  // 将选中节点的所有单节点缓存到数组
  void initTreeCheckeds(List<BigNode> nodes) {
    for (var node in nodes) {
      // if (node.childs.isEmpty) {
      if (node.alone) {
        initCheckedNodes.add(node.id);
      } else {
        initTreeCheckeds(node.childs);
      }
    }
  }
}
