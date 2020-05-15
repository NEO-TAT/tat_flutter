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
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'ConnectorParameter.dart';

typedef SavePathCallback = String Function(Headers responseHeaders);

class DioConnector {
  static String _refererUrl = "https://nportal.ntut.edu.tw";
  static Map<String, String> _headers = {
    "User-Agent": presetUserAgent,
    "Upgrade-Insecure-Requests": "1",
    "Referer": _refererUrl,
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
    } catch (e) {
      Log.e(e.toString());
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
      Log.d("getHeaderByGet " + parameter.url);
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
      Log.d(sprintf("Get : %s", [_putDataToUrl(url, data)]));
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
      Map<String, String> data =
          (parameter.data is Map) ? parameter.data : Map();
      _handleCharsetName(parameter.charsetName);
      _handleHeaders(parameter);
      Log.d(sprintf("Post : %s", [_putDataToUrl(url, data)]));
      response = await dio.post(url, data: parameter.data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  static String _putDataToUrl(String url, Map<String, String> data) {
    Uri newUrl = Uri.https(_getHost(url), _getPath(url), data);
    url = newUrl.toString();
    //Log.d( "put data $url");
    return url;
  }

  void _handleHeaders(ConnectorParameter parameter) {
    //_setReferer( _putDataToUrl(url, data) );
    //dio.options.headers = headers;
    //Log.d( cookieJar.loadForRequest( Uri.parse(url) ).toString() );
    //Log.d( dio.options.headers.toString() );
    dio.options.headers["user-agent"] = parameter.userAgent;
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
        .catchError((onError) {
      Log.e(onError.toString());
      throw onError;
    });
  }

  Map<String, String> get headers {
    return _headers;
  }

  static void _setReferer(String url) {
    Log.d("Referer : $_refererUrl");
    _headers["Referer"] = _refererUrl;
    _refererUrl = url;
  }

  static String _getHost(String url) {
    String host = Uri.parse(url).host;
    return host;
  }

  static String _getPath(String url) {
    String path = Uri.parse(url).path;
    return path;
  }

  PersistCookieJar get cookiesManager {
    return _cookieJar;
  }
}
