import 'base_model.dart';

class Pager extends BaseModel {
  List<Map<String, dynamic>> data;
  int page_num;
  int page_size;
  int page_count;
  int total;

  Pager({
    required this.data,
    required this.page_num,
    required this.page_size,
    required this.page_count,
    required this.total,
  });

  @override
  factory Pager.fromJson(Map<String, dynamic> json) {
    return Pager(
      data: json['data'] == null ? [] : List<Map<String, dynamic>>.from(json['data'] as List),
      page_num: json['page_num'] as int,
      page_size: json['page_size'] as int,
      page_count: json['page_count'] as int,
      total: json['total'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'data': this.data,
      'page_num': page_num,
      'page_size': page_size,
      'page_count': page_count,
      'total': total,
    };
    return data;
  }
}
