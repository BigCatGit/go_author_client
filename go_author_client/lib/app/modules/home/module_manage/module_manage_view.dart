import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';

import 'module_manage_controller.dart';

class ModuleManageView extends GetView<ModuleManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ModuleManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "模块管理",
      searchUrl: "/admin/system/module/listPage",
      insertUrl: "/admin/system/module/insert",
      updateUrl: "/admin/system/module/update",
      deleteUrl: "/admin/system/module/delete",
      cleanUrl: "/admin/system/module/clean",
      queryParam: QueryParam(),
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          allowEditing: false,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "name",
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "模块名",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "path",
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "路径",
          required: true,
        ),
        BigDataColumn(
          dataType: 'image',
          name: "icon",
          minimumWidth: 120,
          label: "图标",
        ),
        BigDataColumn(
          dataType: 'string',
          name: "method",
          minimumWidth: 120,
          label: "方法",
          required: true,
        ),
        BigDataColumn(
          dataType: 'bool',
          ctrlType: "dropdown",
          name: "hidden",
          minimumWidth: 120,
          label: "隐藏",
          required: true,
        ),
        BigDataColumn(
          dataType: 'int',
          name: "parent_id",
          minimumWidth: 120,
          label: "父ID",
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
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "update_time",
          minimumWidth: 240,
          label: "更新时间",
        ),
        BigDataColumn(
          dataType: 'datetime',
          name: "delete_time",
          minimumWidth: 240,
          label: "删除时间",
          allowEditing: false,
          visible: false,
        ),
      ],
    );
  }
}
