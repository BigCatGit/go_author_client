import 'package:syncfusion_flutter_datagrid/datagrid.dart';

typedef OnCellSubmited = Future<bool> Function(DataGridRow dataGridRow, GridColumn column, int id, int dataRowIndex, int dataCellIndex, dynamic oldValue, dynamic newValue);
typedef OnFormSubmited = Future<bool> Function(bool isEdit, Map<String, dynamic> params);
typedef OnSearchSubmit = bool Function(Map<String, dynamic> params);
typedef OnSearchCompleted = bool Function(List<Map<String, dynamic>>? params);
typedef OnLoadCompleted = bool Function(Map<String, dynamic> data);
typedef OnDataLoadCompleted = void Function(List<Map<String, dynamic>>? data);
typedef OnDropdownWillAppear = void Function(int toolbarAction, List<Map<String, dynamic>> options);

typedef OnRefresh = Future<void> Function();
typedef OnDeleteCompleted = Future<void> Function(List<int> ids);
// 上传文件，返回服务器url
typedef OnUploadFile = Future<String?> Function(Map<String, dynamic> row, String path);

const String BIGDATAGRID_DATATYPE_STRING = "string";
const String BIGDATAGRID_DATATYPE_INT = "int";
const String BIGDATAGRID_DATATYPE_DOUBLE = "double";
const String BIGDATAGRID_DATATYPE_BOOL = "bool";
const String BIGDATAGRID_DATATYPE_DATETIME = "datetime";
const String BIGDATAGRID_DATATYPE_DATE = "date";
const String BIGDATAGRID_DATATYPE_TIME = "time";
const String BIGDATAGRID_DATATYPE_LIST = "list";

const String BIGDATAGRID_CTRLTYPE_INPUT = "input";
const String BIGDATAGRID_CTRLTYPE_CHECKBOX = "checkbox"; // 未实现
const String BIGDATAGRID_CTRLTYPE_DROPDOWN = "dropdown";
const String BIGDATAGRID_CTRLTYPE_IMAGE = "image";
const String BIGDATAGRID_CTRLTYPE_FILE = "file";
const String BIGDATAGRID_CTRLTYPE_VIDEO = "video"; // 未实现
const String BIGDATAGRID_CTRLTYPE_BUTTON = "button";
const String BIGDATAGRID_CTRLTYPE_CTRL = "control";
