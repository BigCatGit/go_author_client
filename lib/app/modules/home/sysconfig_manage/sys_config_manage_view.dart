import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';

import 'sys_config_manage_controller.dart';

class SysConfigManageView extends GetView<SysConfigManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  SysConfigManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "系统配置",
      searchUrl: "/admin/system/sysConfig/listPage",
      insertUrl: "/admin/system/sysConfig/insert",
      updateUrl: "/admin/system/sysConfig/update",
      deleteUrl: "/admin/system/sysConfig/delete",
      cleanUrl: "/admin/system/sysConfig/clean",
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
          allowEditing: false,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "名称",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "version_number",
          allowEditing: false,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "版本号",
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
