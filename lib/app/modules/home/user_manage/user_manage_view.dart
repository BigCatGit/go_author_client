import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_author_client/app/api/base_api.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_column.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_control.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_grid_def.dart';

import 'user_manage_controller.dart';

class UserManageView extends GetView<UserManageController> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  UserManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigDataControl(
      key: scaffoldKey,
      title: "用户管理",
      searchUrl: "/admin/system/user/listPage",
      insertUrl: "/admin/system/user/insert",
      updateUrl: "/admin/system/user/update",
      deleteUrl: "/admin/system/user/delete",
      cleanUrl: "/admin/system/user/clean",
      queryParam: QueryParam(),
      columns: [
        BigDataColumn(
          dataType: 'int',
          name: "id",
          label: "ID",
          minimumWidth: 100,
          allowEditing: false,
          allowSearch: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "nickname",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 200,
          label: "昵称 ",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          ctrlType: BIGDATAGRID_CTRLTYPE_IMAGE,
          name: "avatar",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 200,
          label: "头像",
          allowedExtensions: ["jpg", "jpeg", "png"],
          onUploadFile: (row, path) async {
            // 如果是新增，则不上传
            if (row["id"] == null) {
              return null;
            }
            // TODO 上传到阿里云oss

            // 这里先上传到本地
            var resp = await BaseApi().upload("/admin/system/user/uploadAvatar", path, "avatarFile", {"id": row["id"]}, {});
            if (resp != null && resp["code"] == 200) {
              BotToast.showText(text: "上传成功");
              return resp["data"];
            } else {
              BotToast.showText(text: "上传失败");
              return null;
            }
          },
        ),
        BigDataColumn(
          dataType: 'string',
          name: "username",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 200,
          label: "用户名 ",
          required: true,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "password",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 150,
          label: "密码",
          required: true,
        ),
        BigDataColumn(
          dataType: 'int',
          name: "age",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 80,
          label: "年龄",
        ),
        BigDataColumn(
          dataType: 'string',
          name: "token",
          allowEditing: false,
          allowResizeWidth: true,
          minimumWidth: 150,
          label: "授权码",
        ),
        BigDataColumn(
          dataType: 'int',
          ctrlType: 'dropdown',
          name: "role_id",
          allowResizeWidth: true,
          minimumWidth: 120,
          label: "角色ID",
          required: true,
          optionsUrl: "/admin/system/role/listAll",
          optionsColName: "name",
          optionsColValue: "id",
          allowSearch: true,
          onDropdownWillAppear: (toolbarAction, options) {},
          selectable: true,
          multipleSelect: false,
        ),
        BigDataColumn(
          dataType: 'int',
          ctrlType: 'dropdown',
          name: "group_id",
          allowResizeWidth: true,
          minimumWidth: 120,
          label: "分组ID",
          optionsUrl: "/admin/system/group/listAll",
          optionsColName: "name",
          optionsColValue: "id",
          allowSearch: true,
          onDropdownWillAppear: (toolbarAction, options) {
            if (options.isEmpty || options.first["value"] != 0) {
              options.insert(0, {"name": "未分配", "value": 0});
            }
          },
          selectable: true,
          multipleSelect: false,
        ),
        BigDataColumn(
          dataType: 'int',
          ctrlType: 'dropdown',
          name: "channel_id",
          allowResizeWidth: true,
          minimumWidth: 120,
          label: "渠道ID",
          optionsUrl: "/admin/business/channel/listAll",
          optionsColName: "name",
          optionsColValue: "id",
          allowSearch: true,
          onDropdownWillAppear: (toolbarAction, options) {
            if (options.isEmpty || options.first["value"] != 0) {
              options.insert(0, {"name": "未分配", "value": 0});
            }
          },
          selectable: true,
          multipleSelect: false,
        ),
        BigDataColumn(
          dataType: 'string',
          name: "desc",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 120,
          label: "描述",
        ),
        BigDataColumn(
          dataType: 'string',
          name: "phone",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 200,
          label: "手机号",
        ),
        BigDataColumn(
          dataType: 'string',
          name: "email",
          allowEditing: true,
          allowResizeWidth: true,
          minimumWidth: 200,
          label: "邮箱",
        ),
        BigDataColumn(
          dataType: 'bool',
          ctrlType: 'dropdown',
          name: "disabled",
          minimumWidth: 80,
          label: "封禁",
          required: true,
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
