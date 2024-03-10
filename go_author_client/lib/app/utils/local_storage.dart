import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 封装SharedPreferences为单例模式
class LocalStorage {
  /// SharedPreferences对象
  static late SharedPreferences _storage;

  //到这里还没有完 有时候会遇到使用时提示 SharedPreferences 未初始化,所以还需要提供一个static 的方法
  static Future<void> initStore() async {
    //静态方法不能访问非静态变量所以需要创建变量再通过方法赋值回去
    _storage = await SharedPreferences.getInstance();
  }

  /// 设置存储
  static set(String key, dynamic value) {
    String type;
    // 监测value的类型 如果是Map和List,则转换成JSON，以字符串进行存储
    if (value is Map || value is List) {
      type = 'String';
      value = JsonEncoder().convert(value);
    }
    // 否则 获取value的类型的字符串形式
    else {
      type = value.runtimeType.toString();
    }
    // 根据value不同的类型 用不同的方法进行存储
    switch (type) {
      case 'String':
        _storage.setString(key, value);
        break;
      case 'int':
        _storage.setInt(key, value);
        break;
      case 'double':
        _storage.setDouble(key, value);
        break;
      case 'bool':
        _storage.setBool(key, value);
        break;
      case 'List<String>':
        _storage.setStringList(key, value);
        break;
    }
  }

  static saveMap(String key, Map<String, dynamic> map) {
    _storage.setString(key, jsonEncode(map));
  }

  static remove(String key) {
    _storage.remove(key);
  }

  static Map<String, dynamic> getMap(String key) {
    var jsonstr = _storage.getString(key);
    if (jsonstr == null || jsonstr == "") {
      return <String, dynamic>{};
    }
    return jsonDecode(jsonstr);
  }

  /// 获取存储 注意：返回的是一个Future对象 要么用await接收 要么在.then中接收
  static dynamic get(String key) {
    // 获取key对应的value
    dynamic value = _storage.get(key);
    // 判断value是不是一个json的字符串 是 则解码
    if (_isJson(value)) {
      return JsonDecoder().convert(value);
    } else {
      // 不是 则直接返回
      return value;
    }
  }

  /// 是否包含某个key
  static bool hasKey(String key) {
    return _storage.containsKey(key);
  }

  /// 删除key指向的存储 如果key存在则删除并返回true，否则返回false
  bool removeStorage(String key) {
    if (hasKey(key)) {
      _storage.remove(key);
      return true;
    } else {
      return false;
    }
    // return  _storage.remove(key);
  }

  /// 清空存储 并总是返回true
  static bool clear() {
    _storage.clear();
    return true;
  }

  /// 获取所有的key 类型为Set<String>
  static Set<String> getKeys() {
    return _storage.getKeys();
  }

  // 判断是否是JSON字符串
  static _isJson(dynamic value) {
    try {
      // 如果value是一个json的字符串 则不会报错 返回true
      JsonDecoder().convert(value);
      return true;
    } catch (e) {
      // 如果value不是json的字符串 则报错 进入catch 返回false
      return false;
    }
  }
}
