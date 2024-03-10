import 'dart:convert';

import 'package:dio/dio.dart' as dio;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/consts/consts.dart';
import 'package:go_author_client/app/models/query_param.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/app/utils/http_util.dart';
import 'package:go_author_client/app/utils/local_storage.dart';

class BaseApi {
  String getToken() {
    if (LocalStorage.get("x-token") != null) {
      return LocalStorage.get("x-token").toString();
    }
    return "";
  }

  /// get请求, 添加公共请求头和统一跳转处理
  /// @param url
  /// @param params
  /// @param headers
  Future<Map<String, dynamic>?> get(String url, Map<String, dynamic>? params, Map<String, dynamic>? headers) async {
    params ??= {};
    headers ??= {};
    if (headers["x-token"] == null) {
      // 获取x-token
      headers["x-token"] = getToken();
    }
    var resp = await HttpUtil.get(Consts.server_host + url, params, headers);
    if (resp.statusCode == 401) {
      BotToast.showText(text: "授权已过期");
      // 如果已经是登录页面，则不再跳转
      if (!url.contains("/login")) {
        Get.offAllNamed(Routes.LOGIN);
      }
      // 主动抛出异常
      throw Exception("授权已过期");
      // return null;
    }
    if (resp.statusCode != 200) {
      return null;
    }
    return resp.data;
  }

  /// post请求, 添加公共请求头和统一跳转处理
  /// @param url
  /// @param params
  /// @param headers
  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  ) async {
    params ??= {};
    headers ??= {};
    if (headers["x-token"] == null) {
      // 获取x-token
      headers["x-token"] = getToken();
    }

    var resp = await HttpUtil.post(Consts.server_host + url, params, headers);
    if (resp.statusCode == 401 || (resp.data != null && resp.data["code"] == 401)) {
      LocalStorage.remove("x-token");
      BotToast.showText(text: "授权已过期");
      // 如果已经是登录页面，则不再跳转
      if (!url.contains("/login")) {
        Get.offAllNamed(Routes.LOGIN);
      }
      // 主动抛出异常
      throw Exception("授权已过期");
      // return null;
    }
    if (resp.statusCode != 200) {
      return null;
    }
    return resp.data;
  }

  Future<Map<String, dynamic>?> upload(
    String url,
    String filepath,
    String fileParamName,
    // 注意参数中不可再有fileParamName值, 否则会被覆盖
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  ) async {
    params ??= {};
    headers ??= {};
    if (headers["x-token"] == null) {
      // 获取x-token
      headers["x-token"] = getToken();
    }

    dio.Dio dioInst = dio.Dio();
    var formData = dio.FormData.fromMap({
      fileParamName: await dio.MultipartFile.fromFile(
        filepath,
        filename: path.basename(filepath),
      ),
      ...params,
    });
    var resp = await dioInst.post(
      Consts.server_host + url,
      data: formData,
      options: Options(headers: headers),
    );
    if (resp.statusCode != 200) {
      return null;
    }
    return resp.data;
  }

  /// 获取分页列表
  Future<Map<String, dynamic>?> getPageList(String path, int pageNum, int pageSize, String sortColumn, bool ascending, QueryParam queryParam) async {
    // token在父类会自动上传
    return await get(
        path,
        {
          "pageNum": pageNum,
          "pageSize": pageSize,
          "sortColumn": sortColumn,
          "ascending": ascending,
          "queryParam": json.encode(queryParam.toJson()),
        },
        null);
  }

  /// 获取所有列表
  Future<Map<String, dynamic>?> getAllList(String path, QueryParam? queryParam) async {
    // token在父类会自动上传
    return await get(
        path,
        {
          "queryParam": queryParam ?? json.encode(queryParam!.toJson()),
        },
        null);
  }
}
