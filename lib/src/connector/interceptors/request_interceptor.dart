import 'dart:io';

import 'package:dio/dio.dart';

import '../../../debug/log/Log.dart';

class RequestInterceptors extends InterceptorsWrapper {
  String referer;
  @override
  onRequest(RequestOptions options) async {
    options.headers[HttpHeaders.refererHeader] = referer;
    referer = options.uri.toString();
    if(options.uri.toString().contains("https://istudy.ntut.edu.tw/learn/path/launch.php")){
      options.headers.remove(HttpHeaders.contentTypeHeader);
      options.headers[HttpHeaders.refererHeader] = "https://istudy.ntut.edu.tw/learn/mooc_sysbar.php";
    }
    return options;
  }

  @override
  onResponse(Response response) async {}

  @override
  onError(DioError err) async {}
}
