class UrlUtil {
  static String getHostAndSchema(String url) {
    if (!url.contains("?")) {
      return url;
    }
    return url.split("?")[0];
  }

  static String getQueryString(String url) {
    if (!url.contains("?")) {
      return '';
    }
    return url.split("?")[1];
  }

  static Map<String, dynamic> urlToMap(String url) {
    if (!url.contains("?")) {
      return {};
    }
    var query = url.split("?")[1];
    return Uri.splitQueryString(query);
  }

  static String mapToQuery(Map<String, dynamic> params) {
    // 这种方法只支持值为String的情况
    // var uri = Uri(queryParameters: params);
    // return uri.query;
    // 手动实现
    var queryString = "";
    var split = "";
    for (var key in params.keys) {
      queryString += "$split$key=${params[key]}";
      split = "&";
    }
    return queryString;
  }

  static String mapToUrl(String host, Map<String, dynamic> params) {
    return "$host?${mapToQuery(params)}";
  }

  static addUrlParams(String url, Map<String, dynamic> params) {
    var map = urlToMap(url);
    if (map.isEmpty) map = {};
    map.addAll(params);
    return mapToUrl(getHostAndSchema(url), map);
  }
}

// void main() {
//   var map = UrlUtil.urlToMap("https://www.baidu.com?name=1&age=2");
//   print(UrlUtil.mapToUrlQuery("https://www.baidu.com", map).toString());
//   print(UrlUtil.addUrlParams("https://www.baidu.com?name1=1&age1=2", map).toString());
// }
