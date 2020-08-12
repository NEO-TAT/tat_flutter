//
//  DioConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:convert';
import 'dart:io';
import 'package:big5/big5.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/interceptors/error_interceptor.dart';
import 'package:flutter_app/src/connector/interceptors/log_interceptor.dart';
import 'package:flutter_app/src/connector/interceptors/request_interceptor.dart';
import 'package:path_provider/path_provider.dart';
import 'ConnectorParameter.dart';

typedef SavePathCallback = String Function(Headers responseHeaders);

class DioConnector {
  static Map<String, String> _headers = {
    HttpHeaders.userAgentHeader: presetUserAgent,
    "Upgrade-Insecure-Requests": "1",
  };
  static final BaseOptions dioOptions = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 10000,
      sendTimeout: 5000,
      headers: _headers,
      responseType: ResponseType.json,
      contentType: "application/x-www-form-urlencoded",
      validateStatus: (status) {
        // 關閉狀態檢測
        return status <= 500;
      },
      responseDecoder: null);
  Dio dio = Dio(dioOptions);
  PersistCookieJar _cookieJar;
  static final Exception connectorError =
      Exception("Connector statusCode is not 200");

  DioConnector._privateConstructor();

  static final DioConnector instance = DioConnector._privateConstructor();

  static String _big5Decoder(List<int> responseBytes, RequestOptions options,
      ResponseBody responseBody) {
    String result = big5.decode(responseBytes);
    return result;
  }

  static String _utf8Decoder(List<int> responseBytes, RequestOptions options,
      ResponseBody responseBody) {
    String result = Utf8Codec().decode(responseBytes);
    return result;
  }

  Future<void> init() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      dio.interceptors.add(CookieManager(_cookieJar));
      dio.interceptors.add(RequestInterceptors());
      dio.interceptors.add(ErrorInterceptors(dio));
      dio.interceptors.add(LogsInterceptors());
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
    }
  }

  void deleteCookies() {
    _cookieJar.deleteAll();
  }

  Future<String> getDataByPost(ConnectorParameter parameter) async {
    try {
      Response response = await getDataByPostResponse(parameter);
      if (response.statusCode == HttpStatus.ok) {
        return response.toString();
      } else {
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<String> getDataByGet(ConnectorParameter parameter) async {
    Response response;
    try {
      response = await getDataByGetResponse(parameter);
      if (response.statusCode == HttpStatus.ok) {
        return response.toString();
      } else {
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, List<String>>> getHeadersByGet(
      ConnectorParameter parameter) async {
    Response<ResponseBody> response;
    try {
      response = await dio.get<ResponseBody>(
        parameter.url,
        options: Options(
            responseType: ResponseType.stream), // set responseType to `stream`
      ); //使速度更快
      if (response.statusCode == HttpStatus.ok) {
        return response.headers.map;
      } else {
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<Response> getDataByGetResponse(ConnectorParameter parameter) async {
    Response response;
    try {
      String url = parameter.url;
      Map<String, String> data = parameter.data;
      _handleCharsetName(parameter.charsetName);
      _handleHeaders(parameter);
      response = await dio.get(url, queryParameters: data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> getDataByPostResponse(ConnectorParameter parameter) async {
    Response response;
    try {
      String url = parameter.url;
      _handleCharsetName(parameter.charsetName);
      _handleHeaders(parameter);
      response = await dio.post(url, data: parameter.data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  void _handleHeaders(ConnectorParameter parameter) {
    dio.options.headers[HttpHeaders.userAgentHeader] = parameter.userAgent;
    if (parameter.referer != null) {
      dio.options.headers[HttpHeaders.refererHeader] = parameter.referer;
    }
  }

  void _handleCharsetName(String charsetName) {
    if (charsetName == presetCharsetName) {
      dio.options.responseDecoder = null;
    } else if (charsetName == 'big5') {
      dio.options.responseDecoder = _big5Decoder;
    } else {
      dio.options.responseDecoder = null;
    }
  }

  Future<void> download(String url, SavePathCallback savePath,
      {ProgressCallback progressCallback,
      CancelToken cancelToken,
      Map<String, dynamic> header}) async {
    await dio
        .downloadUri(Uri.parse(url), savePath,
            onReceiveProgress: progressCallback,
            cancelToken: cancelToken,
            options: Options(receiveTimeout: 0, headers: header)) //設置不超時
        .catchError((onError, stack) {
      Log.eWithStack(onError.toString(), stack);
      throw onError;
    });
  }

  Map<String, String> get headers {
    return _headers;
  }

  PersistCookieJar get cookiesManager {
    return _cookieJar;
  }
}
