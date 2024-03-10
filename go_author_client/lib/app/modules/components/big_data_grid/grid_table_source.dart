import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/api/base_api.dart';
import 'package:go_author_client/app/consts/consts.dart';
import 'package:go_author_client/app/models/pager.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/utils/datetime_util.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../combobox/dropdown2.dart';
import 'big_data_column.dart';
import 'big_grid_def.dart';

class GridTableSource extends DataGridSource {
  String searchUrl;
  List<Map<String, dynamic>> data = [];
  final List<BigDataColumn> columns;
  final RxInt total = 0.obs;
  int pageSize = 50;
  int lastPageSize = 0;
  int pageNum = 1;
  // 计算属性
  final List<int> pageSizeList = [50, 100, 200, 300, 400, 500, 1000];
  List<DataGridRow> dataGridRows = [];
  final RxInt pageCount = 1.obs; // 页数最少为1页
  String sortColumn = "id"; // 排序字段
  bool ascending = false; // 默认倒序
  QueryParam queryParam = QueryParam.fromJson({}); // 搜索参数
  final RxBool isLoading = RxBool(true);

  TextEditingController? editingController;
  // 正在编辑的值Map<String, Obs类型>
  Map<String, dynamic> editingValues = <String, dynamic>{};
  late OnCellSubmited? onCellSubmited;
  late OnLoadCompleted? onLoadCompleted;

  TextStyle? style;

  GridTableSource({required this.searchUrl, required this.columns, this.style});

  void reset() {
    // 不能清空该数据，如果当前已设置了搜索条件，需要保留
    this.queryParam = QueryParam.fromJson({});
  }

  Future<Pager?> _fetchData() async {
    try {
      isLoading.value = true;
      Map<String, dynamic>? resp = await BaseApi().getPageList(
        searchUrl,
        pageNum,
        pageSize,
        sortColumn,
        ascending,
        queryParam,
      );
      if (resp == null) {
        BotToast.showText(text: "获取分页数据失败");
        return null;
      }
      if (resp["code"] != 200 && resp["message"] != null) {
        BotToast.showText(text: resp["message"]);
        return null;
      }

      if (onLoadCompleted != null) {
        onLoadCompleted!(resp["data"]);
      }

      Pager pager = Pager.fromJson(resp["data"]);
      pager.data = pager.data;
      buildDataGridRow(pager);
      // 模拟延迟
      await Future<void>.delayed(Duration(milliseconds: Consts.debug_delay), () {});
      isLoading.value = false;
      return pager;
    } catch (e) {
      BotToast.showText(text: "加载数据出错");
    }
    isLoading.value = false;
    return null;
  }

  void buildDataGridRow(Pager pager) {
    this.data = pager.data;
    this.total.value = pager.total;
    // 这里pageCount为0要报错，给一个默认值, 这个值改变就会触发handlePageChange()回调
    this.pageCount.value = pager.page_count <= 0 ? 1 : pager.page_count;
    this.pageNum = pager.page_num;
    dataGridRows = data.map<DataGridRow>((map) {
      return DataGridRow(
        cells: genRowCells(map),
      );
    }).toList();
  }

  DataGridCell genCell(BigDataColumn col, Map<String, dynamic> map) {
    // 获取联级属性
    dynamic value = map;
    if (!col.name.contains(".")) {
      value = map[col.name];
    } else {
      var arr = col.name.split(".");
      for (var name in arr) {
        value = value![name];
        if (value == null) {
          break;
        }
      }
    }
    if (col.ctrlType == BIGDATAGRID_CTRLTYPE_CTRL) {
      value = "";
    }
    // 下拉列表判断要放在最前，因为这里面包含了其他的数据类型
    else if (col.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN) {
      bool found = false;
      if (col.options.isNotEmpty && value != null) {
        for (var map in col.options) {
          if (map["value"] == value) {
            value = map["name"];
            found = true;
            break;
          }
        }
      }
      value = found ? value : "未知";
    } else if (col.dataType == BIGDATAGRID_DATATYPE_STRING) {
      value = value ?? "";
    } else if (col.dataType == BIGDATAGRID_DATATYPE_DATETIME || col.dataType == BIGDATAGRID_DATATYPE_DATE) {
      value = value == null ? "" : DateTime.parse(value).toLocal().toString();
      value = value.isEmpty ? value : value.substring(0, value.indexOf("."));
    } else if (col.dataType == BIGDATAGRID_DATATYPE_DATETIME) {
      if (value != null) {
        value = DateTimeUtil.format(DateTime.parse(value), format: "yyyy-MM-dd HH:mm:ss");
        value = value.isEmpty ? value : value.substring(0, value.indexOf("."));
      }
    }
    return DataGridCell<dynamic>(columnName: col.name, value: value);
  }

  List<DataGridCell<dynamic>> genRowCells(Map<String, dynamic> map) {
    return this.columns.map((col) {
      if (col.onBuildCell != null) {
        return col.onBuildCell!(col, map);
      }
      return genCell(col, map);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>(
        (dataGridCell) {
          if (dataGridCell.columnName == BIGDATAGRID_CTRLTYPE_CTRL) {
            BigDataColumn col = getColByName(dataGridCell.columnName)!;
            return Row(
              children: col.widgets.map((widget) {
                if (widget is BigButton) {
                  if (widget.text != null) {
                    return ElevatedButton(
                      onPressed: () {
                        // 获取行的索引
                        int rowIndex = rows.indexOf(row);
                        widget.onPressed(col, rowIndex, getIdByCell(row), data[rowIndex]);
                      },
                      style: widget.style,
                      child: Text(widget.text!),
                    );
                  } else if (widget.icon != null) {
                    return IconButton(
                      icon: widget.icon!,
                      onPressed: () {
                        // 获取行的索引
                        int rowIndex = rows.indexOf(row);
                        widget.onPressed(col, rowIndex, getIdByCell(row), data[rowIndex]);
                      },
                      style: widget.style,
                    );
                  }
                }
                return widget;
              }).toList(),
            );
          }
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              dataGridCell.value.toString(),
              overflow: TextOverflow.ellipsis,
              style: this.style,
            ),
          );
        },
      ).toList(),
    );
  }

  BigDataColumn? getColByName(String name) {
    for (var col in columns) {
      if (col.name == name) {
        return col;
      }
    }
    return null;
  }

  dynamic getCellValueByName(DataGridRow row, String name) {
    for (DataGridCell cell in row.getCells()) {
      if (cell.columnName == name) {
        return cell.value;
      }
    }
    return null;
  }

  // 根据SFDataGrid回调里的cell下标获取自定义Col对象，这里要减去第一列是复选框
  BigDataColumn getColByGridIndex(int datagridCellIndex) {
    return columns[datagridCellIndex - 1];
  }

  Map<String, dynamic>? getRowByDataGridRow(DataGridRow row) {
    for (var cell in row.getCells()) {
      if (cell.columnName == "id") {
        for (int i = 0; i < data.length; i++) {
          if (data[i]["id"] == cell.value) {
            return data[i];
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? getRowById(int id) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]["id"] == id) {
        return data[i];
      }
    }
    return null;
  }

  int getIdByCell(DataGridRow rows) {
    for (DataGridCell cell in rows.getCells()) {
      if (cell.columnName == "id") {
        return cell.value;
      }
    }
    return 0;
  }

  void updateDataSource(int id, String columnName, dynamic value) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]["id"] == id) {
        data[i][columnName] = value;
        break;
      }
    }
  }

  // 分页切换回调函数
  // 初始化时该函数在填充数据后分页总数就会被修改，所以会触发两次分页请求，
  // 解决办法可以将分页总数在初始化时提前获取交修改，从而触发填充数据的函数即可
  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    this.pageNum = newPageIndex + 1;
    if (oldPageIndex != newPageIndex || this.lastPageSize != this.pageSize) {
      await this._fetchData();
      this.lastPageSize = this.pageSize;
    }
    // notifyListeners();
    return Future<bool>.value(true);
  }

  // 下拉刷新
  @override
  Future<void> handleRefresh() async {
    this._fetchData();
  }

  // 分页数量改变回调事件
  void onRowsPerPageChanged(int pageSize) {
    this.pageSize = pageSize;
  }

  void updateDataGridDataSource() {
    notifyListeners();
  }

  @override
  bool shouldRecalculateColumnWidths() {
    // 数据重新加载时，重新计算列宽
    return true;
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // 获取显示的值, 但我们这里要获取真实的值
    // final String text = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value?.toString() ?? '';
    var row = getRowByDataGridRow(dataGridRow)!;
    Widget? widget;
    double paddingTop = 0;
    var col = getColByGridIndex(rowColumnIndex.columnIndex);
    if (col.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN) {
      // 清空文本类型的编辑控件控器制
      editingController = null;
      paddingTop = 0;
      // editingValues[col.name] = RxString(row[col.name].toString());
      // widget = Obx(() {
      //   return DropdownButton(
      //     value: editingValues[col.name].value, // 默认选项
      //     items: col.options.map((item) {
      //       return DropdownMenuItem(value: item["value"].toString(), child: Text(item["name"]));
      //     }).toList(),
      //     onChanged: (newValue) {
      //       editingValues[col.name].value = newValue.toString();
      //     },
      //     isExpanded: true, // 确保DropdownButton占满宽度
      //     isDense: true, // 减小内部padding
      //   );
      // });

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
      widget = Obx(() {
        return Dropdown2(
          hint: Text("请选择${col.label}"),
          selectedValues: list, // 默认选项
          items: col.options,
          selectable: col.selectable,
          multiSelectable: col.multipleSelect,
          textAlignmentStart: false,
          dropdownMaxHeight: 480,
          isExpanded: true, // 确保DropdownButton占满宽度
          isDense: true, // 减小内部padding
          menuItemStyleData: const MenuItemStyleData(
            height: 32,
          ),
          style: TextStyle(overflow: TextOverflow.ellipsis),
          alignment: AlignmentDirectional.topStart,
        );
      });
    } else {
      String? text;
      if (col.dataType == BIGDATAGRID_DATATYPE_DATETIME || col.dataType == BIGDATAGRID_DATATYPE_DATE) {
        if (row[column.columnName] != null) {
          text = DateTime.parse(row[column.columnName].toString()).toLocal().toString();
          if (text.isNotEmpty) {
            text = text.substring(0, text.indexOf("."));
          }
        }
      }
      text = text ?? row[column.columnName].toString();
      paddingTop = 8;
      // 清空观察模式的变量, 使用控制器
      editingValues.clear();
      editingController = TextEditingController();
      widget = TextField(
        autofocus: true,
        // 获取焦点时的文字大小
        style: TextStyle(fontSize: 14),
        controller: editingController!..text = text,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: TextInputType.text,
      );
    }

    return Container(
      // 这个设置会导致行高不够时控件被挤错位
      padding: EdgeInsets.fromLTRB(8, paddingTop, 8, 4),
      alignment: Alignment.centerLeft,
      child: widget,
    );
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    // 获取显示值
    // final dynamic oldValue = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value ?? '';
    // 然而我们需要获取真实的旧值，而不是格式化后的显示值
    final dynamic oldValue = data[rowColumnIndex.rowIndex][column.columnName];

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    // 我们添加了选择列，所以要减去1
    final int dataCellIndex = rowColumnIndex.columnIndex - 1;
    dynamic newCellValue = editingController != null ? editingController!.text : editingValues[column.columnName].value;

    if (oldValue == newCellValue) {
      return Future<void>.value();
    }

    // 判断是否修改id列
    if (column.columnName == 'id') {
      BotToast.showText(text: "该字段不可编辑");
      return Future<void>.value();
    }
    // 获取id
    int id = 0;
    for (var cell in dataGridRow.getCells()) {
      if (cell.columnName == 'id') {
        id = cell.value;
      }
    }

    if (onCellSubmited != null) {
      bool success = await onCellSubmited!(dataGridRow, column, id, dataRowIndex, dataCellIndex, oldValue, newCellValue);
      if (success) {}
    }
    return Future<void>.value();
  }

  void addRow(Map<String, dynamic> row) {
    try {
      // 更新ui
      // 倒序插入在第一行, 如果是升序则插入在最后一行
      if (!ascending) {
        dataGridRows.insert(0, DataGridRow(cells: genRowCells(row)));
        data.insert(0, row);
      } else {
        dataGridRows.add(DataGridRow(cells: genRowCells(row)));
        data.add(row);
      }
    } catch (e) {
      BotToast.showText(text: '更新ui出错');
    }
  }

  void removeRow(DataGridRow row) {
    dataGridRows.remove(row);
  }

  void removeRowByIndex(int index) {
    dataGridRows.removeAt(index);
  }

  void clear() {
    dataGridRows.clear();
  }

  void updateRow(DataGridRow dataGridRow, int id, int rowIndex, Map<String, dynamic> map) {
    try {
      // 更新ui, 遍历单无格，跳过第一列复选框
      for (int i = 0; i < dataGridRow.getCells().length; i++) {
        DataGridCell cell = dataGridRow.getCells()[i];
        if (map.containsKey(cell.columnName) && map[cell.columnName] != data[rowIndex][cell.columnName]) {
          updateCell(dataGridRow, cell.columnName, id, rowIndex, i, map[cell.columnName]);
        }
      }
    } catch (e) {
      BotToast.showText(text: '更新ui出错');
    }
  }

  void updateCell(
    DataGridRow dataGridRow,
    String columnName,
    int id,
    int dataRowIndex,
    int dataCellIndex,
    dynamic newValue,
  ) {
    try {
      // 更新数据源
      updateDataSource(id, columnName, newValue);
      // 更新ui, 并转换为显示值
      dataGridRow.getCells()[dataCellIndex] = genCell(columns[dataCellIndex], getRowById(id)!);
    } catch (e) {
      BotToast.showText(text: '更新ui出错');
    }
  }
}
