class BaseModel {
  BaseModel();

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    return BaseModel();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }
}
