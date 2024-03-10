import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/api/base_api.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/utils/datatype_util.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'big_data_column.dart';
import 'big_grid_def.dart';
import 'grid_table_source.dart';

// 数据表格控件，包含: 表格、分页控件
// 注意必须为当前控件指定高度，否则放到Column等容器将报错
class BigDataGrid<T> extends StatelessWidget {
  String searchUrl;
  String updateUrl;
  String deleteUrl;
  double rowHeight;
  List<BigDataColumn> columns;
  double? width;
  double? height;

  // 计算属性
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  late GridTableSource dataSource;
  final DataGridController dataGridController = DataGridController();
  RxMap<String, double> columnWidths = RxMap({});

  late BuildContext context;
  // 查询条件
  QueryParam queryParam;

  OnCellSubmited? onCellSubmit;
  OnLoadCompleted? onLoadCompleted;
  OnRefresh? onRefresh;

  TextStyle? cellTextStyle;

  // 是否显示遮盖层
  RxBool coverVisible = false.obs;
  Widget? coverWidget;
  bool pagerVisable = false;

  // 系统参数
  bool showCheckboxColumn;
  bool allowPullToRefresh;
  bool allowEditing;
  bool allowFiltering;
  bool allowSorting;

  BigDataGrid({
    super.key,
    required this.searchUrl,
    required this.updateUrl,
    required this.deleteUrl,
    required this.queryParam,
    required this.columns,
    // 最小300, 再小就不能显示分页控件
    this.width = 300,
    required this.height,
    this.rowHeight = 49,
    this.onLoadCompleted,
    this.onCellSubmit,
    this.cellTextStyle,
    this.coverWidget,
    this.onRefresh,
    this.pagerVisable = true,
    this.showCheckboxColumn = true,
    this.allowPullToRefresh = true,
    this.allowEditing = true,
    this.allowFiltering = true,
    this.allowSorting = true,
  }) {
    // 初始化列宽列表
    for (var col in this.columns) {
      this.columnWidths[col.name] = col.minimumWidth;
    }
    dataSource = GridTableSource(searchUrl: searchUrl, columns: this.columns, style: cellTextStyle);
    dataSource.onLoadCompleted = this.onLoadCompleted;
    dataSource.onCellSubmited = (
      DataGridRow dataGridRow,
      GridColumn column,
      int id,
      int dataRowIndex,
      int dataCellIndex,
      dynamic oldValue,
      dynamic newValue,
    ) async {
      // 数据类型转换
      BigDataColumn? col = this.getColumn(column.columnName);
      if (col == null) {
        BotToast.showText(text: '当前是未知列');
        return false;
      }
      try {
        // 如果是多选列需要进行转换
        if (!col.multipleSelect) {
          if (newValue is List) {
            newValue = newValue.isNotEmpty ? newValue.first : null;
          }
        }

        newValue = DataTypeUtil.convertDataType(newValue, col.dataType);
      } catch (e) {
        BotToast.showText(text: '数据类型转换出错');
        return false;
      }
      if (oldValue == newValue) {
        return false;
      }
      try {
        if (this.onCellSubmit != null) {
          if (!await this.onCellSubmit!(dataGridRow, column, id, dataRowIndex, dataCellIndex, oldValue, newValue)) {
            return false;
          }
        }
        var resp = await BaseApi().post(this.updateUrl, {"id": id, column.columnName: newValue}, {});
        if (resp != null && resp["code"] == 200) {
          dataSource.updateCell(dataGridRow, column.columnName, id, dataRowIndex, dataCellIndex, newValue);
          BotToast.showText(text: "保存成功");
        } else {
          BotToast.showText(text: resp != null && resp["message"] != null ? resp['message'] : '请求失败');
        }
      } catch (e) {
        BotToast.showText(text: '提交数据出错');
        return false;
      }
      return false;
    };
  }

  void openCover() {
    this.coverVisible.value = true;
  }

  void closeCover() {
    this.coverVisible.value = false;
  }

  BigDataColumn? getColumn(String name) {
    for (BigDataColumn col in this.columns) {
      if (col.name == name) {
        return col;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    LayoutBuilder(
      builder: (context, constraints) {
        if (this.pagerVisable && constraints.biggest.width < 300) {
          throw Exception(["显示页脚的情况下，宽度不能小于300"]);
        }
        return Container();
      },
    );
    return Obx(() {
      return SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            // 数据表格
            getDataGrid(),
            // 加载条
            // if (dataSource.isLoading.value)
            // 第一种方式实现进度条，并可自定义的遮盖层
            Visibility(
              visible: coverVisible.value || this.dataSource.isLoading.value,
              // 控件容器
              child: Positioned(
                child: Container(
                  color: Colors.black26.withOpacity(0.5), // 半透明
                  child: Center(
                    // 放进度条或者自定义控件
                    child: this.dataSource.isLoading.value
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(value: 80),
                              SizedBox(height: 8),
                              TextButton(
                                  onPressed: () {
                                    this.dataSource.isLoading.value = false;
                                  },
                                  child: Text("取消", style: TextStyle(fontSize: 16))),
                            ],
                          )
                        : this.coverWidget,
                  ),
                ),
              ),
            ),
            // 第二种方式实现进度条
            // Positioned.fill(
            //   child: AbsorbPointer(
            //     absorbing: true, // Disable mouse interaction
            //     child: Container(
            //       color: Colors.black26, // Background color
            //       child: Center(
            //         child: CircularProgressIndicator(value: 80),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget getDataGrid() {
    return Column(
      children: [
        Expanded(
          child: SfDataGrid(
            controller: dataGridController,
            source: dataSource,
            selectionMode: SelectionMode.multiple,
            showCheckboxColumn: showCheckboxColumn,
            allowPullToRefresh: allowPullToRefresh,
            allowEditing: allowEditing,
            allowFiltering: allowFiltering,
            allowSorting: allowSorting,
            rowHeight: rowHeight,
            navigationMode: GridNavigationMode.cell,
            // 鼠标悬念时才显示过滤按钮和排序按钮
            showColumnHeaderIconOnHover: true,
            // 冻结左侧列数
            frozenColumnsCount: 2,
            // 显示网格线
            // gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            // 列宽模式: 默认内容不折叠
            columnWidthMode: ColumnWidthMode.fitByCellValue,
            allowColumnsResizing: true,
            onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
              this.columnWidths[details.column.columnName] = details.width;
              return true;
            },
            allowSwiping: true,
            swipeMaxOffset: 100.0,
            startSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.greenAccent,
                  child: Center(
                    child: Icon(Icons.add),
                  ),
                ),
              );
            },
            endSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.redAccent,
                  child: Center(
                    child: Icon(Icons.delete),
                  ),
                ),
              );
            },
            columns: this.columns.map((col) {
              try {
                // 加载列表项
                if (col.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN && col.optionsUrl != null) {
                  BaseApi().getAllList(col.optionsUrl!, QueryParam()).then((resp) {
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
                        "value": item[col.optionsColValue],
                      });
                    }
                    // if (col.options.isEmpty) {
                    //   col.options.add({"name": "无数据", "value": 0});
                    // }
                    // var list = resp["data"].map<String, dynamic>((item) {
                    //   return {"name": item[col.optionsColName].toString(), "value": item[col.optionsColValue].toString()};
                    // }).toList() as List<Map<String, dynamic>>;
                    // col.options = list;
                  });
                  if (col.onDataLoadCompleted != null) {
                    col.onDataLoadCompleted!(col.options);
                  }
                }
              } catch (e) {
                BotToast.showText(text: "加载${col.name}列表失败");
              }

              return GridColumn(
                columnName: col.name,
                label: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(col.label, overflow: TextOverflow.ellipsis),
                ),
                width: col.allowResizeWidth ? columnWidths[col.name]! : double.nan,
                columnWidthMode: col.columnWidthMode,
                visible: col.visible,
                allowSorting: col.allowSorting,
                sortIconPosition: col.sortIconPosition,
                filterIconPosition: col.filterIconPosition,
                autoFitPadding: col.autoFitPadding,
                minimumWidth: col.minimumWidth,
                maximumWidth: col.maximumWidth,
                allowEditing: col.allowEditing,
                allowFiltering: col.allowFiltering,
                filterPopupMenuOptions: col.filterPopupMenuOptions,
                filterIconPadding: col.filterIconPadding,
              );
            }).toList(),
          ),
        ),
        if (this.pagerVisable)
          SfDataPager(
            pageCount: dataSource.pageCount.value.toDouble(),
            availableRowsPerPage: dataSource.pageSizeList,
            direction: Axis.horizontal,
            onPageNavigationStart: (int pageIndex) {},
            delegate: dataSource,
            onPageNavigationEnd: (int pageIndex) {
              // 分页切换时滚动到顶部
              if (pageIndex >= 1) {
                dataGridController.scrollToRow(0);
              }
            },
            onRowsPerPageChanged: (int? rowsPerPage) async {
              // 分页数量改变回调事件
              dataSource.onRowsPerPageChanged(rowsPerPage!);
              dataSource.updateDataGridDataSource();
            },
          ),
      ],
    );
  }

  void refresh(bool reset) {
    // 刷新
    dataSource.isLoading.value = true;
    dataGridController.selectedRows.clear();
    // 不能清空该数据，如果当前已设置了搜索条件，需要保留
    if (reset) {
      dataSource.reset();
    }
    dataSource.handleRefresh();
    if (onRefresh != null) {
      onRefresh!();
    }
  }
}
