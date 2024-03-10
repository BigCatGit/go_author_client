import 'package:flutter/material.dart';
import 'package:get/get.dart';

const BIGTREE_STATUS_CHECKED_NONE = 0;
const BIGTREE_STATUS_CHECKED_HALF = 1;
const BIGTREE_STATUS_CHECKED_FULL = 2;

class BigNode {
  int id;
  String title;
  int parentId;
  Icon? icon;
  RxInt? checked = 0.obs;
  RxBool? expanded = false.obs;
  bool alone;
  List<BigNode> childs;

  BigNode({
    required this.id,
    required this.title,
    this.parentId = 0,
    this.expanded,
    this.checked,
    this.alone = true,
    this.childs = const [],
  }) {
    checked = checked ?? BIGTREE_STATUS_CHECKED_NONE.obs;
    expanded = expanded ?? false.obs;
  }

  factory BigNode.fromJson(Map<String, dynamic> json) {
    return BigNode(
      id: json['id'],
      title: json['title'],
      parentId: json['parentId'],
      checked: json['checked'].obs,
      expanded: json['expanded'].obs,
      childs: json['childs'] != null ? List<BigNode>.from(json['childs'].map((child) => BigNode.fromJson(child))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': this.id,
      'title': this.title,
      'parentId': this.parentId,
      'checked': this.checked!.value,
      'expanded': this.expanded!.value,
      'childs': this.childs.map((child) => child.toJson()).toList(),
    };
    return data;
  }
}
