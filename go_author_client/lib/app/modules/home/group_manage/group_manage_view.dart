import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';

import 'group_manage_controller.dart';

class GroupManageView extends GetView<GroupManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  GroupManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "分组管理",
      searchUrl: "/admin/system/group/listPage",
      insertUrl: "/admin/system/group/insert",
      updateUrl: "/admin/system/group/update",
      deleteUrl: "/admin/system/group/delete",
      cleanUrl: "/admin/system/group/clean",
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
          dataType: 'string',
          name: "name",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "分组名",
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
          dataType: 'datetime',
          name: "delete_time",
          minimumWidth: 240,
          label: "删除时间",
          allowEditing: false,
          visible: false,
        ),
      ],
      searchFields: [],
    );
  }
}
