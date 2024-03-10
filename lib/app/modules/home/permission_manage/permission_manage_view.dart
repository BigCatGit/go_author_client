import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';

import 'permission_manage_controller.dart';

class PermissionManageView extends GetView<PermissionManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  PermissionManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "权限管理",
      searchUrl: "/admin/system/permission/listPage",
      insertUrl: "/admin/system/permission/insert",
      updateUrl: "/admin/system/permission/update",
      deleteUrl: "/admin/system/permission/delete",
      cleanUrl: "/admin/system/permission/clean",
      queryParam: QueryParam(),
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          allowEditing: false,
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'int',
          ctrlType: 'dropdown',
          name: "module_id",
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "模块ID",
          required: true,
          optionsUrl: "/admin/system/module/listAll",
          optionsColName: "name",
          optionsColValue: "id",
          allowSearch: true,
          selectable: true,
          multipleSelect: false,
        ),
        // BigDataColumn(
        //   dataType: 'string',
        //   name: "module.name",
        //   allowEditing: false,
        //   allowResizeWidth: true,
        //   minimumWidth: 240,
        //   label: "模块名",
        //   required: true,
        // ),
        BigDataColumn(
          dataType: 'int',
          ctrlType: 'dropdown',
          name: "role_id",
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "角色ID",
          required: true,
          optionsUrl: "/admin/system/role/listAll",
          optionsColName: "name",
          optionsColValue: "id",
          allowSearch: true,
          onDropdownWillAppear: (toolbarAction, options) {
            if (options.isNotEmpty && options.first["name"] == "超级管理员") {
              options.removeAt(0);
            }
          },
          selectable: true,
          multipleSelect: false,
        ),
        // BigDataColumn(
        //   dataType: 'string',
        //   name: "role.name",
        //   allowEditing: false,
        //   allowResizeWidth: true,
        //   minimumWidth: 240,
        //   label: "角色名",
        //   required: true,
        // ),
        BigDataColumn(
          dataType: 'bool',
          ctrlType: 'dropdown',
          name: "visible",
          minimumWidth: 120,
          label: "可见性",
          required: true,
          options: [
            {"name": "可见", "value": true},
            {"name": "不可见", "value": false},
          ],
          allowSearch: true,
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
          dataType: 'datetime',
          name: "delete_time",
          minimumWidth: 240,
          label: "删除时间",
          allowEditing: false,
          visible: false,
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
    );
  }
}
