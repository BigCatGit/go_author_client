// import 'dart:convert';
import 'package:validators/validators.dart';

class JsonUtil {
  bool isJson(String jsonStr) {
    try {
      // 使用原生包
      // json.decode(jsonStr) as Map<String, dynamic>;
      // return true;
      return isJSON(jsonStr);
    } catch (e) {
      return false;
    }
  }
}
