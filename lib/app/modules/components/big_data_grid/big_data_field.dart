import 'package:go_author_client/app/models/query_param.dart';

import 'big_grid_def.dart';

// 自定义列配置
class BigDataField {
  String label;
  String name;
  String? helperText; // 输入框描述
  String? errorText; // 错误提示
  String? Function(String?)? validator;

  String dataType;
  String ctrlType;
  double minimumWidth;

  // 下拉列表属性<name, value>
  List<Map<String, dynamic>> options;
  bool multipleSelect;
  bool selectable;
  List<Map<String, dynamic>> selectedOptions;
  // 从服务器列表的url
  String? optionsUrl;
  String? optionsColName;
  String? optionsColValue;
  // 查询逻辑操作符
  String? operator;
  SubQueryParam? subQueryParam;

  OnSearchSubmit? onSearchSubmit;
  OnSearchCompleted? onSearchCompeleted;
  OnDataLoadCompleted? onDataLoadCompleted;
  OnDropdownWillAppear? onDropdownWillAppear;

  BigDataField({
    required this.label,
    required this.name,
    this.minimumWidth = double.nan,
    this.ctrlType = BIGDATAGRID_CTRLTYPE_INPUT,
    this.dataType = BIGDATAGRID_DATATYPE_STRING,
    this.helperText,
    this.errorText,
    this.validator,
    this.options = const [],
    this.multipleSelect = false,
    this.selectable = false,
    this.selectedOptions = const [],
    this.optionsUrl,
    this.optionsColName,
    this.optionsColValue,
    this.operator = "eq",
    this.subQueryParam,
    this.onSearchSubmit,
    this.onSearchCompeleted,
    this.onDataLoadCompleted,
    this.onDropdownWillAppear,
  }) {
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
