import 'package:dio/dio.dart';

class HttpUtil {
  /// get请求
  /// @param url
  /// @param params
  /// @param headers
  static Future<Response> get(
    String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  ) async {
    params ??= {};
    headers ??= {};

    ///发起get请求
    var dio = Dio();
    Response response = await dio.get(url, queryParameters: params, options: Options(headers: headers));
    return response;
  }

  static Future<Response> post(
    String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  ) async {
    params ??= {};
    headers ??= {};

    ///发起get请求
    var dio = Dio();
    Response response = await dio.post(
      url,
      data: params,
      options: Options(headers: headers),
    );
    return response;
  }
}
