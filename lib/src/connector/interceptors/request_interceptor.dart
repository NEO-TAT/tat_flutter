import 'dart:io';

import 'package:dio/dio.dart';

class RequestInterceptors extends InterceptorsWrapper {
  String referer = "https://nportal.ntut.edu.tw";

  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.headers.containsKey(HttpHeaders.refererHeader)) {
      options.headers[HttpHeaders.refererHeader] = referer;
    }
    referer = options.uri.toString();
    return super.onRequest(options, handler);
  }
}
