import 'dart:io';

import 'package:dio/dio.dart';

import '../../../debug/log/Log.dart';

class RequestInterceptors extends InterceptorsWrapper {
  String referer;
  @override
  onRequest(RequestOptions options) async {
    options.headers[HttpHeaders.refererHeader] = referer;
    referer = options.uri.toString();
    return options;
  }

  @override
  onResponse(Response response) async {}

  @override
  onError(DioError err) async {}
}
