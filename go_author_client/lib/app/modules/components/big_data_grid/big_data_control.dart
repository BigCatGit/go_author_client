import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/api/base_api.dart';
import 'package:go_author_client/app/consts/consts.dart';
import 'package:go_author_client/app/consts/global.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_grid.dart';
import 'package:go_author_client/app/modules/components/combobox/dropdown2.dart';
import 'package:go_author_client/app/modules/components/dialog/big_alert.dart';
import 'package:go_author_client/app/utils/datatype_util.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'big_data_column.dart';
import 'big_data_field.dart';
import 'big_grid_def.dart';

// 数据表格控件，包含: 表格、分页控件、增删改查控件、搜索控件
// 注意必须为当前控件指定高度，否则放到Column等容器将报错
class BigDataControl<T> extends StatelessWidget {
  String? title;
  double width;
  double height;
  String searchUrl;
  String insertUrl;
  String updateUrl;
  String deleteUrl;
  String cleanUrl;
  double rowHeight;
  List<BigDataColumn> columns;
  // 自定义搜索字段, 不在列内的
  List<BigDataField>? searchFields;
  // 自定义搜索控件，例如按钮等
  List<Widget>? searchWidgets;

  // 计算属性
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  static const int TOOLBAR_ACTION_ADD = 0;
  static const int TOOLBAR_ACTION_EDIT = 1;
  static const int TOOLBAR_ACTION_DEL = 2;
  static const int TOOLBAR_ACTION_CLEAN = 3;
  static const int TOOLBAR_ACTION_REFRESH = 4;
  static const int TOOLBAR_ACTION_RESTART = 5;
  static const int TOOLBAR_ACTION_DOWNLOAD = 6;
  static const int TOOLBAR_ACTION_SEARCH = 7;
  static const int TOOLBAR_ACTION_SORT = 8;
  // 记录被点击的工具栏按钮, 0: 添加, 1: 编辑, 2: 删除, 3:清空 4: 刷新, 5: 搜索
  int toolbarAction = TOOLBAR_ACTION_ADD;

  RxString endDrawerTitle = "添加".obs;
  Rx<List<Widget>> endDrawerForms = Rx([]);

  late BuildContext context;
  late BigDataGrid datagrid;

  // 正在编辑的值Map<String, Obs类型>
  Map<String, dynamic> editingValues = <String, dynamic>{};
  // 正在编辑的值Map<String, 控制器>
  Map<String, dynamic> editingCtrl = <String, dynamic>{};
  // 当前已编辑的值缓存
  Map<String, dynamic> editingMap = <String, dynamic>{};
  // 查询条件
  QueryParam queryParam;

  // 当前是否是编辑模式, false为添加模式
  bool isEditMode = false;
  bool isSearchMode = false;
  double? formWidth;

  OnCellSubmited? onCellSubmit;
  OnFormSubmited? onFormSubmit;
  OnLoadCompleted? onLoadCompleted;
  OnRefresh? onRefresh;
  OnDeleteCompleted? onDeleteCompleted;

  TextStyle? cellTextStyle;

  // 是否显示遮盖层
  RxBool coverVisible = false.obs;
  Widget? coverWidget;

  // 排序缓存
  RxString sortFieldName = "id".obs;
  RxBool isSortAsc = false.obs;

  // 系统参数
  bool showCheckboxColumn;
  bool allowPullToRefresh;
  bool allowEditing;
  bool allowFiltering;
  bool allowSorting;

  BigDataControl({
    super.key,
    required this.searchUrl,
    required this.insertUrl,
    required this.updateUrl,
    required this.deleteUrl,
    required this.cleanUrl,
    required this.queryParam,
    required this.columns,
    // 不设置标题，则不会显示编辑添加等工具按钮
    this.title,
    this.height = double.infinity,
    // 最小300, 再小就不能显示分页控件
    this.width = double.infinity,
    this.rowHeight = 49,
    this.searchFields,
    this.searchWidgets,
    this.onLoadCompleted,
    this.onDeleteCompleted,
    this.onCellSubmit,
    this.onFormSubmit,
    this.cellTextStyle,
    this.formWidth,
    this.coverWidget,
    this.showCheckboxColumn = true,
    this.allowPullToRefresh = true,
    this.allowEditing = true,
    this.allowFiltering = true,
    this.allowSorting = true,
  });

  setFormWidth(double? width) {
    this.formWidth = width;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    this.datagrid = BigDataGrid(
      searchUrl: this.searchUrl,
      updateUrl: this.updateUrl,
      deleteUrl: this.deleteUrl,
      queryParam: this.queryParam,
      columns: this.columns,
      rowHeight: this.rowHeight,
      onLoadCompleted: this.onLoadCompleted,
      onCellSubmit: this.onCellSubmit,
      cellTextStyle: this.cellTextStyle,
      coverWidget: this.coverWidget,
      onRefresh: this.onRefresh,
      showCheckboxColumn: showCheckboxColumn,
      allowPullToRefresh: allowPullToRefresh,
      allowEditing: allowEditing,
      allowFiltering: allowFiltering,
      allowSorting: allowSorting,
      width: this.width,
      height: this.height,
    );
    return Obx(() {
      return Scaffold(
        key: scaffoldKey,
        appBar: this.title != null
            ? AppBar(
                title: Text(this.title!),
                centerTitle: true,
                // 右侧控件
                actions: [
                  if (Global.permissions.contains(this.insertUrl))
                    IconButton(
                      icon: Icon(Icons.add),
                      tooltip: "添加记录",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () {
                              // 添加
                              toolbarAction = TOOLBAR_ACTION_ADD;
                              endDrawerTitle.value = "添加";
                              isSearchMode = false;
                              isEditMode = false;
                              genFormList();
                              scaffoldKey.currentState?.openEndDrawer();
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.updateUrl))
                    IconButton(
                      icon: Icon(Icons.edit),
                      tooltip: "编辑记录",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () {
                              // 编辑
                              toolbarAction = TOOLBAR_ACTION_EDIT;
                              endDrawerTitle.value = "编辑";
                              isSearchMode = false;
                              isEditMode = true;
                              List<DataGridRow> rows = this.datagrid.dataGridController.selectedRows;
                              if (rows.isEmpty) {
                                BotToast.showText(text: "请选择需要编辑的行");
                                return;
                              }
                              // print(dataGridController.selectedIndex);
                              // Iterator<DataGridCell<dynamic>> iter = rows.last.getCells().iterator;
                              // while (iter.moveNext()) {
                              //   DataGridCell<dynamic> cell = iter.current;
                              //   // 获取列名
                              //   String columnName = cell.columnName;
                              //   // 获取值
                              //   dynamic value = cell.value;
                              //   // 打印信息（你可以根据需要进行其他操作）
                              //   print('Column Name: $columnName, Value: $value');
                              // }
                              genFormList();
                              scaffoldKey.currentState?.openEndDrawer();
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.deleteUrl))
                    IconButton(
                      icon: Icon(Icons.delete),
                      tooltip: "删除记录",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () async {
                              // 删除
                              toolbarAction = TOOLBAR_ACTION_DEL;
                              if (!await BigAlert.showConfirm(context: context, title: "警告", content: "确定要删除选择的数据吗?")) {
                                return;
                              }
                              if (this.datagrid.dataGridController.selectedRows.isEmpty) {
                                BotToast.showText(text: "请选择要删除的记录");
                                return;
                              }
                              var rows = this.datagrid.dataGridController.selectedRows;
                              var ids = <int>[];
                              for (int i = 0; i < rows.length; i++) {
                                int id = this.datagrid.dataSource.getCellValueByName(rows[i], "id");
                                ids.add(id);
                                var resp = await BaseApi().get(this.deleteUrl, {"id": id}, {});
                                if (resp != null && resp["code"] == 200) {
                                  // 这里不能一边遍历一边删除
                                } else {
                                  BotToast.showText(text: resp != null && resp["message"] != null ? resp['message'] : '请求失败');
                                }
                              }
                              // 统一删除
                              for (int i = 0; i < rows.length; i++) {
                                this.datagrid.dataSource.removeRow(rows[i]);
                              }
                              // 统一通知改变
                              this.datagrid.dataSource.notifyListeners();
                              if (onDeleteCompleted != null) {
                                onDeleteCompleted!(ids);
                              }
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.cleanUrl))
                    IconButton(
                      icon: Icon(Icons.clear),
                      tooltip: "清空数据",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () async {
                              // 清空
                              toolbarAction = TOOLBAR_ACTION_CLEAN;
                              if (!await BigAlert.showConfirm(context: context, title: "警告", content: "确定要清空所有数据吗?")) {
                                return;
                              }
                              var resp = await BaseApi().get(this.cleanUrl, {}, {});
                              if (resp != null && resp["code"] == 200) {
                                this.datagrid.dataSource.clear();
                                this.datagrid.dataSource.notifyListeners();
                              } else {
                                BotToast.showText(text: resp != null && resp["message"] != null ? resp['message'] : '请求失败');
                              }
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.searchUrl))
                    IconButton(
                      icon: Icon(Icons.refresh),
                      tooltip: "刷新",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () {
                              // 刷新
                              toolbarAction = TOOLBAR_ACTION_REFRESH;
                              this.datagrid.refresh(false);
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.searchUrl))
                    IconButton(
                      icon: Icon(Icons.restart_alt),
                      tooltip: "重新加载页面",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () {
                              // 重新加载页面
                              toolbarAction = TOOLBAR_ACTION_RESTART;
                              editingMap.clear();
                              this.datagrid.refresh(true);
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.searchUrl))
                    IconButton(
                      icon: Icon(Icons.download),
                      tooltip: "下载数据",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () {
                              toolbarAction = TOOLBAR_ACTION_DOWNLOAD;
                              saveToExcel();
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.searchUrl))
                    IconButton(
                      icon: Icon(Icons.search), // 使用搜索图标
                      tooltip: "搜索",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () async {
                              toolbarAction = TOOLBAR_ACTION_SEARCH;
                              isSearchMode = true;
                              isEditMode = false;
                              endDrawerTitle.value = "搜索";
                              await genSearchForm();
                              scaffoldKey.currentState?.openEndDrawer();
                            }
                          : null,
                    ),
                  if (Global.permissions.contains(this.searchUrl))
                    IconButton(
                      icon: Icon(Icons.sort), // 使用搜索图标
                      tooltip: "排序",
                      onPressed: !datagrid.dataSource.isLoading.value
                          ? () async {
                              toolbarAction = TOOLBAR_ACTION_SORT;
                              isSearchMode = false;
                              isEditMode = false;
                              endDrawerTitle.value = "排序";
                              await genSortForm();
                              scaffoldKey.currentState?.openEndDrawer();
                            }
                          : null,
                    ),
                ],
              )
            : null,
        endDrawer: this.title != null
            ? Drawer(
                width: formWidth ?? 480,
                child: Obx(
                  () => Form(
                    key: formKey,
                    child: ListView(
                      padding: EdgeInsets.all(32),
                      // 根据列配置动态显示控件
                      children: [
                        Text(
                          endDrawerTitle.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          // 标题居中
                          // textAlign: TextAlign.center,
                        ),
                        // 动态生成控件
                        ...endDrawerForms.value,
                        SizedBox(height: 16),
                        SizedBox(
                          height: 40.0, // 设置整体高度
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.close),
                                  // 这里使用column是为了让按钮占满父控件高度
                                  label: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("取消"),
                                    ],
                                  ),
                                  onPressed: () {
                                    scaffoldKey.currentState?.closeEndDrawer();
                                  },
                                ),
                              ),
                              SizedBox(width: 16.0), // 可选的间距，根据需要调整
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.done),
                                  // 这里使用column是为了让按钮占满父控件高度
                                  label: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("确定"),
                                    ],
                                  ),
                                  onPressed: () async {
                                    if (toolbarAction == BigDataControl.TOOLBAR_ACTION_SEARCH) {
                                      search();
                                      scaffoldKey.currentState?.closeEndDrawer();
                                      return;
                                    }
                                    if (toolbarAction == BigDataControl.TOOLBAR_ACTION_SORT) {
                                      // 排序模式
                                      try {
                                        this.datagrid.dataSource.sortColumn = this.sortFieldName.value;
                                        this.datagrid.dataSource.ascending = this.isSortAsc.value;
                                        this.datagrid.refresh(false);
                                        scaffoldKey.currentState?.closeEndDrawer();
                                      } catch (e) {
                                        BotToast.showText(text: '排序出错');
                                        return;
                                      }
                                    }
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    if (toolbarAction == BigDataControl.TOOLBAR_ACTION_ADD) {
                                      // 添加模式
                                      Map<String, dynamic> params = getEditingMap();
                                      if (this.onFormSubmit != null) {
                                        if (!await this.onFormSubmit!(false, params)) {
                                          return;
                                        }
                                      }
                                      var resp = await BaseApi().post(this.insertUrl, params, {});
                                      if (resp != null && resp["code"] == 200) {
                                        scaffoldKey.currentState?.closeEndDrawer();
                                        this.datagrid.dataSource.addRow(resp["data"]);
                                        this.datagrid.dataSource.notifyListeners();
                                      } else {
                                        BotToast.showText(text: resp != null && resp["message"] != null ? resp['message'] : '请求失败');
                                      }
                                    } else if (toolbarAction == BigDataControl.TOOLBAR_ACTION_EDIT) {
                                      // 编辑模式
                                      try {
                                        // 获取选择的项
                                        DataGridRow? dataGridRow = this.datagrid.dataGridController.selectedRow;
                                        if (dataGridRow != null) {
                                          int id = this.datagrid.dataSource.getCellValueByName(dataGridRow, "id");
                                          Map<String, dynamic> params = getEditingMap();
                                          params["id"] = id;
                                          if (this.onFormSubmit != null) {
                                            if (!await this.onFormSubmit!(true, params)) {
                                              return;
                                            }
                                          }
                                          var resp = await BaseApi().post(this.updateUrl, params, {});
                                          if (resp != null && resp["code"] == 200) {
                                            scaffoldKey.currentState?.closeEndDrawer();
                                            this.datagrid.dataSource.updateRow(dataGridRow, id, this.datagrid.dataGridController.selectedIndex, params);
                                            this.datagrid.dataSource.notifyListeners();
                                          } else {
                                            BotToast.showText(text: resp != null && resp["message"] != null ? resp['message'] : '请求失败');
                                          }
                                        }
                                      } catch (e) {
                                        BotToast.showText(text: '提交数据出错');
                                        return;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : null,
        onEndDrawerChanged: (isOpened) {
          // 保存编辑的数据到map
          if (!isOpened) {
            this.editingMap = getEditingMap();
          }
        },
        body: this.datagrid,
      );
    });
  }

  Widget genLabel(BigDataField col) {
    bool isColField = col is BigDataColumn;
    return Row(
      children: [
        Text(col.label, style: TextStyle(color: Colors.blue)),
        if (!isSearchMode) SizedBox(width: 4),
        if (!isSearchMode)
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Text((isColField && col.required) ? "✱" : "", style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
          ),
      ],
    );
  }

  void genFormList() {
    // 清空缓存
    isEditMode = toolbarAction == TOOLBAR_ACTION_EDIT;
    endDrawerForms.value.clear();
    if (toolbarAction == TOOLBAR_ACTION_ADD || toolbarAction == TOOLBAR_ACTION_EDIT) {
      // DataGridRow row = dataGridController.selectedRow!;
      int selectIndex = toolbarAction == TOOLBAR_ACTION_ADD ? -1 : this.datagrid.dataGridController.selectedIndex;
      if (selectIndex > 0 && selectIndex >= this.datagrid.dataSource.data.length) {
        return;
      }
      Map<String, dynamic>? row = selectIndex >= 0 ? this.datagrid.dataSource.data[selectIndex] : {};
      for (BigDataColumn col in columns) {
        if (!col.allowEditing || col.name == "id" || col.name == "delete_time" || col.name == BIGDATAGRID_CTRLTYPE_CTRL) {
          continue;
        }
        if (!isEditMode && (col.name == "create_time" || col.name == "update_time")) {
          continue;
        }
        if (isSearchMode && !col.allowSearch) {
          continue;
        }
        Widget? widget = genFieldWidget(col, isEditMode, row);
        if (widget == null) {
          continue;
        }
        endDrawerForms.value.add(Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.centerLeft,
          child: widget,
        ));
      }
    }
  }

  Future<void> genSortForm() async {
    endDrawerForms.value.clear();

    List<Map<String, dynamic>> items = this.datagrid.columns.map((col) {
      return {"name": col.label, "value": col.name};
    }).toList();

    List<Widget> widgets = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          genLabel(BigDataColumn(label: "字段名", name: "sortFieldName")),
          Obx(() {
            return Dropdown2(
              hint: Text("请选择排序字段名"),
              selectedValues: [sortFieldName.value], // 默认选项
              items: items,
              selectable: false,
              multiSelectable: false,
              textAlignmentStart: true,
              isExpanded: true, // 确保DropdownButton占满宽度
              isDense: true, // 减小内部padding
              style: TextStyle(overflow: TextOverflow.ellipsis),
              onChanged: (selectedKeys, selectedValues) {
                sortFieldName.value = selectedValues.first;
              },
            );
          }),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          genLabel(BigDataColumn(label: "排序方向", name: "sortDirection")),
          Obx(() {
            return Dropdown2(
              hint: Text("请选择排序方向"),
              selectedValues: [isSortAsc.value], // 默认选项
              items: [
                {"name": "倒序", "value": false},
                {"name": "顺序", "value": true},
              ],
              selectable: false,
              multiSelectable: false,
              textAlignmentStart: true,
              isExpanded: true, // 确保DropdownButton占满宽度
              isDense: true, // 减小内部padding
              style: TextStyle(overflow: TextOverflow.ellipsis),
              onChanged: (selectedKeys, selectedValues) {
                isSortAsc.value = selectedValues.first;
              },
            );
          }),
        ],
      ),
    ];

    for (var widget in widgets) {
      endDrawerForms.value.add(Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.centerLeft,
        child: widget,
      ));
    }
  }

  // 生成编辑控件
  Widget? genFieldWidget(BigDataField col, bool isEditMode, Map<String, dynamic> row) {
    Widget? widget;
    bool isColField = col is BigDataColumn;
    if (col.ctrlType == BIGDATAGRID_CTRLTYPE_INPUT) {
      if (col.dataType == BIGDATAGRID_DATATYPE_STRING) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            // 始终显示标题
            floatingLabelBehavior: FloatingLabelBehavior.always,
            label: genLabel(col),
            labelStyle: TextStyle(fontSize: 20.0),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      } else if (col.dataType == BIGDATAGRID_DATATYPE_INT) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            label: genLabel(col),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      } else if (col.ctrlType == BIGDATAGRID_DATATYPE_DOUBLE) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          controller: controller,
          decoration: InputDecoration(
            label: genLabel(col),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      } else if (col.dataType == BIGDATAGRID_DATATYPE_DATETIME) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        if (controller.text.isNotEmpty) {
          controller.text = DateTime.parse(controller.text).toLocal().toString();
        }
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          readOnly: false, //是否只读
          controller: controller,
          decoration: InputDecoration(
            label: genLabel(col),
            suffixIcon: IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () async {
                var dt = await _showDatePicker(
                  initialDate: controller.text.isEmpty ? DateTime.now() : DateTime.parse(controller.text).toLocal(),
                  firstDate: DateTime(0),
                  lastDate: DateTime(9999),
                  helpText: "请选择日期",
                  cancelText: "取消",
                  confirmText: "确认",
                  initialDatePickerMode: DatePickerMode.day,
                );
                if (dt != null) {
                  var t = await _showTimePicker(
                    helpText: "请选择时间",
                    initialTime: TimeOfDay.fromDateTime(DateTime.parse(controller.text.isNotEmpty ? controller.text : "2000-01-01 00:00:00").toLocal()),
                    builder: (context, child) {
                      return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child ?? const Text(""));
                    },
                  );
                  dt = DateTime(dt.year, dt.month, dt.day, t != null ? t.hour : 0, t != null ? t.minute : 0);
                  controller.text = dt.toLocal().toString();
                }
              },
            ),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      } else if (col.dataType == BIGDATAGRID_DATATYPE_DATE) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        if (controller.text.isNotEmpty) {
          controller.text = DateTime.parse(controller.text).toLocal().toString();
        }
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          readOnly: false, //是否只读
          controller: controller,
          decoration: InputDecoration(
            label: genLabel(col),
            suffixIcon: IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () async {
                var dt = await _showDatePicker(
                  initialDate: controller.text.isEmpty ? DateTime.now() : DateTime.parse(controller.text).toLocal(),
                  firstDate: DateTime(0),
                  lastDate: DateTime(9999),
                  helpText: "请选择日期",
                  cancelText: "取消",
                  confirmText: "确认",
                  initialDatePickerMode: DatePickerMode.day,
                );
                if (dt != null) {
                  controller.text = dt.toLocal().toString();
                }
              },
            ),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      } else if (col.dataType == BIGDATAGRID_DATATYPE_TIME) {
        var controller = TextEditingController();
        controller.text = row[col.name] != null ? row[col.name].toString() : "";
        if (controller.text.isNotEmpty) {
          controller.text = DateTime.parse(controller.text).toLocal().toString();
        }
        editingCtrl[col.name] = controller;
        widget = TextFormField(
          readOnly: false, //是否只读
          controller: controller,
          decoration: InputDecoration(
            label: genLabel(col),
            suffixIcon: IconButton(
              icon: Icon(Icons.timer),
              onPressed: () async {
                var t = await _showTimePicker(
                  helpText: "请选择时间",
                  initialTime: controller.text.isEmpty ? TimeOfDay.now() : TimeOfDay.fromDateTime(DateTime.parse(controller.text).toLocal()),
                  builder: (context, child) {
                    return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child ?? const Text(""));
                  },
                );
                controller.text = t.toString();
              },
            ),
          ),
          validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
        );
      }
    } else if (col.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN) {
      var controller = TextEditingController();
      controller.text = row[col.name] != null ? row[col.name].toString() : "";
      RxList list = RxList();
      if (row[col.name] != null) {
        try {
          if (row[col.name] is List) {
            list.addAll(row[col.name]);
          } else if (row[col.name] is! String) {
            list.add(row[col.name]);
          } else {
            list.addAll(json.decode(row[col.name]));
          }
        } catch (e) {
          list.add(row[col.name].toString());
        }
      }
      editingValues[col.name] = list;
      if (col.onDropdownWillAppear != null) {
        col.onDropdownWillAppear!(this.toolbarAction, col.options);
      }

      widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          genLabel(col),
          Obx(() {
            return Dropdown2(
              hint: Text("请选择${col.label}"),
              selectedValues: list, // 默认选项
              items: col.options,
              selectable: col.selectable,
              multiSelectable: col.multipleSelect,
              textAlignmentStart: true,
              isExpanded: true, // 确保DropdownButton占满宽度
              isDense: true, // 减小内部padding
              style: TextStyle(overflow: TextOverflow.ellipsis),
              validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
            );
          }),
        ],
      );
    } else if (col.ctrlType == BIGDATAGRID_CTRLTYPE_IMAGE) {
      // 如果是编辑，则此时的url是远程地址
      var path = isEditMode && row[col.name] != null ? row[col.name].toString() : "";
      var url = isEditMode && !path.startsWith("http") ? "${Consts.server_host}$path" : path;
      // 这里不能将域名保存到服务器
      editingValues[col.name] = RxString(path);
      widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          genLabel(col),
          Obx(() {
            return GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  allowedExtensions: (col as BigDataColumn).allowedExtensions,
                  type: FileType.custom,
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  editingValues[col.name].value = file.path;
                  // 除了上传到本地，上传到阿里云oss更方便
                  if (col.onUploadFile != null) {
                    var returl = await (col).onUploadFile!(row, file.path);
                    if (returl != null) {
                      editingValues[col.name].value = returl;
                    }
                  }
                }
              },
              child: editingValues[col.name].value != null && url.startsWith('http')
                  ? Image.network(
                      url, // 图片url
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Image.asset('assets/images/404.png', width: 200.0, height: 200.0);
                      },
                    )
                  : Image.file(
                      File(editingValues[col.name].value), // 图片路径
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Image.asset('assets/images/404.png', width: 200.0, height: 200.0);
                      },
                    ),
            );
          }),
        ],
      );
    } else if (col.ctrlType == BIGDATAGRID_CTRLTYPE_FILE) {
      var controller = TextEditingController();
      controller.text = row[col.name] != null ? row[col.name].toString() : "";
      editingCtrl[col.name] = controller;
      widget = TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          // 始终显示标题
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: genLabel(col),
          labelStyle: TextStyle(fontSize: 20.0),
          suffixIcon: IconButton(
            icon: Icon(Icons.keyboard_control),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: (col as BigDataColumn).allowedExtensions,
                type: FileType.custom,
              );
              if (result != null) {
                File file = File(result.files.single.path!);
                controller.text = file.path;
                // 除了上传到本地，上传到阿里云oss更方便
                if (col.onUploadFile != null) {
                  var returl = await (col).onUploadFile!(row, file.path);
                  if (returl != null) {
                    editingValues[col.name].value = returl;
                  }
                }
              }
            },
          ),
        ),
        validator: col.validator ?? (value) => (isColField && col.required) && (value == null || value.isEmpty) ? "此项不能为空" : null,
      );
    }
    return widget;
  }

  bool isSelected(BigDataField field, String value) {
    if (field.selectedOptions.isEmpty) {
      return false;
    } else {
      for (var item in field.selectedOptions) {
        if (item["value"] == value) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> genSearchForm() async {
    // 清空缓存
    isEditMode = false;
    endDrawerForms.value.clear();
    if (this.datagrid.columns.isNotEmpty) {
      for (BigDataColumn col in this.datagrid.columns) {
        if (!col.allowSearch) {
          continue;
        }
        Widget? widget = genFieldWidget(col, isEditMode, this.editingMap);
        if (widget == null) {
          continue;
        }
        endDrawerForms.value.add(Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.centerLeft,
          child: widget,
        ));
      }
    }
    if (searchFields != null && searchFields!.isNotEmpty) {
      // 遍历列里面的搜索配置
      for (BigDataField col in searchFields!) {
        // 加载列表项
        if (col.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN && col.optionsUrl != null) {
          var resp = await BaseApi().getAllList(col.optionsUrl!, QueryParam());
          if (resp == null) {
            BotToast.showText(text: "获取${col.name}列表失败");
            return;
          }
          if (resp["code"] != 200 && resp["message"] != null) {
            BotToast.showText(text: resp["message"]);
            return;
          }
          col.options = [];
          for (var item in resp["data"]) {
            col.options.add({
              "name": item[col.optionsColName].toString(),
              "value": item[col.optionsColValue].toString(),
            });
          }
        }
        Widget? widget = genFieldWidget(col, isEditMode, this.editingMap);
        if (widget == null) {
          continue;
        }
        endDrawerForms.value.add(Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.centerLeft,
          child: widget,
        ));
      }

      // 再生成搜索控件, 包括按钮等控件
      if (searchWidgets != null && searchWidgets!.isNotEmpty) {
        for (Widget widget in searchWidgets!) {
          endDrawerForms.value.add(widget);
        }
      }
    }
  }

  Future<DateTime?> _showDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    bool Function(DateTime)? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    Widget Function(BuildContext, Widget?)? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextInputType? keyboardType,
    Offset? anchorPoint,
    void Function(DatePickerEntryMode)? onDatePickerModeChange,
    Icon? switchToInputEntryModeIcon,
    Icon? switchToCalendarEntryModeIcon,
  }) async {
    return await showDatePicker(
      context: this.context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      locale: locale,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      textDirection: textDirection,
      builder: builder,
      initialDatePickerMode: initialDatePickerMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      keyboardType: keyboardType,
      anchorPoint: anchorPoint,
      onDatePickerModeChange: onDatePickerModeChange,
      switchToInputEntryModeIcon: switchToInputEntryModeIcon,
      switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    );
  }

  Future<TimeOfDay?> _showTimePicker({
    required TimeOfDay initialTime,
    bool useRootNavigator = true,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String? cancelText,
    String? confirmText,
    String? helpText,
    String? errorInvalidText,
    String? hourLabelText,
    String? minuteLabelText,
    RouteSettings? routeSettings,
    void Function(TimePickerEntryMode)? onEntryModeChanged,
    Offset? anchorPoint,
    Orientation? orientation,
    TransitionBuilder? builder,
  }) async {
    return await showTimePicker(
      context: this.context,
      initialTime: initialTime,
      useRootNavigator: useRootNavigator,
      initialEntryMode: initialEntryMode,
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
      errorInvalidText: errorInvalidText,
      hourLabelText: hourLabelText,
      minuteLabelText: minuteLabelText,
      routeSettings: routeSettings,
      onEntryModeChanged: onEntryModeChanged,
      anchorPoint: anchorPoint,
      orientation: orientation,
      builder: builder,
    );
  }

  // 将正在编辑的值转换为map
  Map<String, dynamic> getEditingMap() {
    Map<String, dynamic> map = {};
    String where = "";
    List<dynamic> args = [];
    List<SubQueryParam> subQuerys = [];

    Map<String, dynamic> ctrls = {
      ...editingCtrl,
      ...editingValues,
    };

    for (var ctrl in ctrls.entries) {
      BigDataField? col = this.datagrid.dataSource.getColByName(ctrl.key);
      if (col == null) {
        if (this.searchFields != null && this.searchFields!.isNotEmpty) {
          for (var field in this.searchFields!) {
            if (field.name == ctrl.key) {
              col = field;
              break;
            }
          }
        }
        if (col == null) {
          continue;
        }
      }
      try {
        dynamic newValue;
        if (ctrl.value is TextEditingController) {
          newValue = (ctrl.value as TextEditingController).text;
          if (col.dataType != BIGDATAGRID_DATATYPE_STRING || newValue == "") {
            continue;
          }
        } else {
          if (!col.multipleSelect && ctrl.value is List) {
            if (ctrl.value.isEmpty) {
              continue;
            }
            newValue = ctrl.value.value.first;
          } else {
            newValue = ctrl.value.value;
          }
        }
        map[ctrl.key] = newValue;
        newValue = DataTypeUtil.convertDataType(newValue, col.dataType);
        if (col.subQueryParam != null) {
          col.subQueryParam!.sub_args = [newValue];
          subQuerys.add(col.subQueryParam!);
          continue;
        }
        // 组装查询参数
        if (where == "") {
          if (col.operator == "like") {
            where += "${ctrl.key} like ?";
            newValue = "%$newValue%";
          } else if (col.operator == "in") {
            where += "${ctrl.key} in ?";
          } else {
            where += "${ctrl.key} = ?";
          }
        } else {
          if (col.operator == "like") {
            where += " and ${ctrl.key} like ?";
            newValue = "%$newValue%";
          } else if (col.operator == "in") {
            where += " and ${ctrl.key} in ?";
          } else {
            where += " and ${ctrl.key} = ?";
          }
        }
        args.add(newValue);
      } catch (e) {
        BotToast.showText(text: '数据类型转换出错');
        return map;
      }
    }
    this.queryParam.where = where;
    this.queryParam.args = args;
    this.queryParam.sub_querys = subQuerys;
    return map;
  }

  void search() {
    this.editingMap = getEditingMap();
    this.datagrid.dataSource.queryParam = this.queryParam;
    this.datagrid.refresh(false);
  }

  Future<void> saveToExcel() async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('您需要保存原始数据还是显示数据?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('原始数据'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('显示数据'),
            ),
          ],
        );
      },
    );

    String? savePath = await FilePicker.platform.saveFile(
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
      fileName: "exports.xlsx",
      dialogTitle: '保存Excel文件',
    );
    if (savePath == null || savePath.isEmpty) {
      return;
    }

    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    // 添加标题
    sheet.appendRow(this.datagrid.columns.map((col) {
      return TextCellValue(col.label);
    }).toList());
    // 添加数据
    if (result) {
      for (var row in this.datagrid.dataSource.data) {
        List<TextCellValue> values = [];
        for (var col in this.datagrid.columns) {
          values.add(TextCellValue(row[col.name] != null ? row[col.name].toString() : ""));
        }
        sheet.appendRow(values);
      }
    } else {
      for (var row in this.datagrid.dataSource.rows) {
        sheet.appendRow(row.getCells().map((cell) {
          return TextCellValue(cell.value.toString());
        }).toList());
      }
    }
    // 删除无用页, 注意删除和重命名都不支持操作Sheet1默认页，只能用于其他页
    // excel.delete("Sheet1");
    // 保存到文件
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(savePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      BotToast.showText(text: "下载成功");
    } else {
      BotToast.showText(text: "下载失败");
    }
  }
}
