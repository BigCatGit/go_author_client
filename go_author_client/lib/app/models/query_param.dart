// 查询参数
import 'base_model.dart';

class SubQueryParam extends BaseModel {
  String table;
  String where;
  String sub_column;
  String sub_where;
  List<dynamic>? sub_args;
  List<SubQueryParam>? sub_querys;

  SubQueryParam({
    required this.table,
    required this.where,
    required this.sub_column,
    required this.sub_where,
    this.sub_args,
    this.sub_querys,
  });

  // 反序列化
  factory SubQueryParam.fromJson(Map<String, dynamic> json) {
    return SubQueryParam(
      table: json['table'] as String,
      where: json['where'] as String,
      sub_column: json['sub_column'] as String,
      sub_where: json['sub_where'] as String,
      sub_args: json['sub_args'] as List<dynamic>?,
      sub_querys: (json['sub_querys'] as List<dynamic>?)?.map((e) => SubQueryParam.fromJson(e)).toList(),
    );
  }

  // 序列化
  @override
  Map<String, dynamic> toJson() {
    return {
      'table': table,
      'where': where,
      'sub_column': sub_column,
      'sub_where': sub_where,
      'sub_args': sub_args,
      'sub_querys': sub_querys?.map((e) => e.toJson()).toList(),
    };
  }
}

class QueryParam extends BaseModel {
  String? where;
  List<dynamic>? args;
  List<SubQueryParam>? sub_querys;

  QueryParam({
    this.where,
    this.args,
    this.sub_querys,
  });

  // 反序列化
  factory QueryParam.fromJson(Map<String, dynamic> json) {
    return QueryParam(
      where: json['where'] as String?,
      args: json['args'] as List<dynamic>?,
      sub_querys: (json['sub_querys'] as List<dynamic>?)?.map((e) => SubQueryParam.fromJson(e)).toList(),
    );
  }

  // 序列化
  @override
  Map<String, dynamic> toJson() {
    return {
      'where': where,
      'args': args,
      'sub_querys': sub_querys?.map((e) => e.toJson()).toList(),
    };
  }
}
