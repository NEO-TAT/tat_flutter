//  北科課程助手

import 'dart:io';
import 'dart:typed_data';
import 'package:alice/alice.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tat/debug/log/Log.dart';
import 'package:tat/src/connector/interceptors/request_interceptor.dart';
import 'package:get/get.dart' as getUtils;
import 'package:path_provider/path_provider.dart';

import 'connector_parameter.dart';

typedef SavePathCallback = String Function(Headers responseHeaders);

class DioConnector {
  DioConnector._privateConstructor();

  static final DioConnector dioInstance = DioConnector._privateConstructor();
  late PersistCookieJar _cookieJar;

  final dio = Dio(dioOptions);

  final alice = Alice(
    darkTheme: true,
    showNotification: false,
  );

  static final _headers = {
    HttpHeaders.userAgentHeader: presetUserAgent,
    "Upgrade-Insecure-Requests": "1",
  };

  static final dioOptions = BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 10000,
    sendTimeout: 5000,
    headers: _headers,
    responseType: ResponseType.json,
    contentType: "application/x-www-form-urlencoded",
    validateStatus: (status) {
      // disable status detection.
      if (status != null) {
        return status <= 500;
      }

      // enable status detection if status is null.
      return true;
    },
    responseDecoder: null,
  );

  static final Exception connectorError =
      Exception("Connector statusCode is not 200");

  // FIXME change return type to `Future<String?>`
  static String _big5Decoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    String? decodedBig5Result;
    CharsetConverter.decode(
      'big5',
      Uint8List.fromList(responseBytes),
    ).then((value) => decodedBig5Result = value);
    return decodedBig5Result.toString();
  }

  Future<void> init() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(storage: FileStorage(appDocPath + "/.cookies/"));
      alice.setNavigatorKey(getUtils.Get.key);
      dio.interceptors.add(CookieManager(_cookieJar));
      dio.interceptors.add(RequestInterceptors());
      dio.interceptors.add(alice.getDioInterceptor());
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
    ConnectorParameter parameter,
  ) async {
    Response<ResponseBody> response;
    try {
      response = await dio.get<ResponseBody>(
        parameter.url,
        options: Options(
          responseType: ResponseType.stream,
        ), // set responseType to `stream`
      ); // make the speed faster.
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

  Future<void> download(
    String url,
    SavePathCallback savePath, {
    ProgressCallback? progressCallback,
    CancelToken? cancelToken,
    Map<String, dynamic>? header,
  }) async {
    await dio
        .downloadUri(
      Uri.parse(url),
      savePath,
      onReceiveProgress: progressCallback,
      cancelToken: cancelToken,
      options: Options(
        receiveTimeout: 0,
        headers: header,
      ),
    )
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
