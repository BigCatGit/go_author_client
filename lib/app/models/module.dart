// ignore_for_file: file_names

import 'base_model.dart';

class Module extends BaseModel {
  late int id;
  String? create_time;
  String? icon;
  String? update_time;
  dynamic delete_time;
  String? note;
  String path = "";
  String? method = "";
  late String name;
  int? parent_id = 0;
  late bool hidden;
  List<Module>? childs;

  Module({
    required this.id,
    required this.name,
    this.parent_id,
    this.icon,
    required this.hidden,
    required this.path,
    this.method,
    this.create_time,
    this.update_time,
    this.delete_time,
    this.note,
    this.childs,
  });

  @override
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json["id"],
      name: json["name"],
      path: json["path"],
      icon: json["icon"],
      method: json["method"],
      hidden: json["hidden"],
      parent_id: json["parent_id"],
      create_time: json["create_time"],
      update_time: json["update_time"],
      note: json["note"],
      childs: json["childs"] == null ? null : (json["childs"] as List).map((e) => Module.fromJson(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["icon"] = icon;
    data["method"] = method;
    data["create_time"] = create_time;
    data["update_time"] = update_time;
    data["delete_time"] = delete_time;
    data["note"] = note;
    data["path"] = path;
    data["name"] = name;
    data["parent_id"] = parent_id;
    data["hidden"] = hidden;
    if (childs != null) {
      data["childs"] = childs?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
