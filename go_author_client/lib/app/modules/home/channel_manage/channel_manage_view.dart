import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';

import 'channel_manage_controller.dart';

class ChannelManageView extends GetView<ChannelManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ChannelManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "渠道管理",
      searchUrl: "/admin/business/channel/listPage",
      insertUrl: "/admin/business/channel/insert",
      updateUrl: "/admin/business/channel/update",
      deleteUrl: "/admin/business/channel/delete",
      cleanUrl: "/admin/business/channel/clean",
      queryParam: QueryParam(),
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          allowEditing: true,
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "name",
          allowEditing: false,
          allowResizeWidth: true,
          minimumWidth: 240,
          label: "渠道名",
          required: true,
        ),
        BigDataColumn(
          dataType: 'int',
          name: "parent_id",
          allowEditing: false,
          allowResizeWidth: true,
          minimumWidth: 120,
          label: "父渠道",
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
