import 'package:go_author_client/app/api/base_api.dart';

class UserApi extends BaseApi {
  /// 登录
  /// @param username
  /// @param password
  Future<Map<String, dynamic>?> login(String username, String password) async {
    var params = {"username": username, "password": password};
    // token在父类会自动上传
    return await super.post("/login", params, null);
  }

  /// 登出
  Future<Map<String, dynamic>?> logout() async {
    // token在父类会自动上传
    return await super.post("/logout", null, null);
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getProfile() async {
    // token在父类会自动上传
    return await super.get("/admin/system/member/getProfile", null, null);
  }

  /// 获取用户权限模块树
  Future<Map<String, dynamic>?> getModuleTree() async {
    // token在父类会自动上传
    return await super.get("/admin/system/member/getModuleTree", null, null);
  }
}
