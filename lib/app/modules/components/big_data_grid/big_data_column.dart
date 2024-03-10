import 'package:flutter/material.dart';
import 'package:go_author_client/app/modules/components/big_data_grid/big_data_field.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'big_grid_def.dart';

typedef OnBuildCell = DataGridCell Function(BigDataColumn col, Map<String, dynamic> map);

class BigButton extends StatelessWidget {
  String? text;
  Widget? icon;
  ButtonStyle? style;

  Function(BigDataColumn col, int rowIndex, int id, Map<String, dynamic> row) onPressed;
  BigButton({
    super.key,
    this.icon,
    this.text,
    this.style,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 自定义列配置
class BigDataColumn extends BigDataField {
  bool required = false;
  OnBuildCell? onBuildCell; //

  bool allowResizeWidth;
  bool allowSearch;
  ColumnWidthMode columnWidthMode;
  bool visible;
  bool allowSorting;
  ColumnHeaderIconPosition sortIconPosition;
  ColumnHeaderIconPosition filterIconPosition;
  EdgeInsets autoFitPadding;
  double maximumWidth;
  // 取消此属性，使用minimumWidth代替
  // double width;
  bool allowEditing;
  bool allowFiltering;
  FilterPopupMenuOptions? filterPopupMenuOptions;
  EdgeInsetsGeometry filterIconPadding;
  OnUploadFile? onUploadFile;
  List<String>? allowedExtensions;
  List<Widget> widgets;

  BigDataColumn({
    String dataType = BIGDATAGRID_DATATYPE_STRING,
    String ctrlType = BIGDATAGRID_CTRLTYPE_INPUT,
    required String label,
    required String name,
    String? helperText,
    String? errorText,
    this.allowResizeWidth = false,
    this.allowSearch = false,
    this.required = false,
    String? Function(String?)? validator,
    this.onBuildCell,
    super.operator,
    // 系统属性
    this.columnWidthMode = ColumnWidthMode.none,
    this.visible = true,
    this.allowSorting = true,
    this.sortIconPosition = ColumnHeaderIconPosition.end,
    this.filterIconPosition = ColumnHeaderIconPosition.end,
    this.autoFitPadding = const EdgeInsets.all(16.0),
    double minimumWidth = double.nan,
    this.maximumWidth = double.nan,
    this.allowEditing = true,
    this.allowFiltering = true,
    this.filterPopupMenuOptions,
    this.filterIconPadding = const EdgeInsets.symmetric(horizontal: 8.0),
    List<Map<String, dynamic>> options = const [],
    bool multipleSelect = false,
    bool selectable = false,
    List<Map<String, dynamic>> selectedOptions = const [],
    String? optionsUrl,
    String? optionsColName,
    String? optionsColValue,
    OnSearchSubmit? onSearchSubmit,
    OnSearchCompleted? onSearchCompeleted,
    OnDataLoadCompleted? onDataLoadCompleted,
    OnDropdownWillAppear? onDropdownWillAppear,
    this.onUploadFile,
    this.allowedExtensions,
    this.widgets = const [],
  }) : super(
          label: label,
          name: name,
          dataType: dataType,
          ctrlType: ctrlType,
          validator: validator,
          helperText: helperText,
          errorText: errorText,
          minimumWidth: minimumWidth,
          options: options,
          multipleSelect: multipleSelect,
          selectable: selectable,
          selectedOptions: selectedOptions,
          optionsUrl: optionsUrl,
          optionsColName: optionsColName,
          optionsColValue: optionsColValue,
          onSearchSubmit: onSearchSubmit,
          onSearchCompeleted: onSearchCompeleted,
          onDataLoadCompleted: onDataLoadCompleted,
          onDropdownWillAppear: onDropdownWillAppear,
        ) {
    // 如果外部没有指定选项列表，我们这里以一个默认值
    if (this.options.isEmpty || this.ctrlType == BIGDATAGRID_CTRLTYPE_DROPDOWN) {
      if (this.dataType == BIGDATAGRID_DATATYPE_BOOL) {
        this.options = [
          {"name": "是", "value": true},
          {"name": "否", "value": false},
        ];
      }
    }
  }
}
