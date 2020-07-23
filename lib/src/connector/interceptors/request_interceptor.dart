import 'dart:io';
import 'package:dio/dio.dart';

class RequestInterceptors extends InterceptorsWrapper {
  String referer = "https://nportal.ntut.edu.tw";

  @override
  onRequest(RequestOptions options) async {
    if (!options.headers.containsKey(HttpHeaders.refererHeader)) {
      options.headers[HttpHeaders.refererHeader] = referer;
    }
    referer = options.uri.toString();
    return options;
  }

  @override
  onResponse(Response response) async {}

  @override
  onError(DioError err) async {}
}
