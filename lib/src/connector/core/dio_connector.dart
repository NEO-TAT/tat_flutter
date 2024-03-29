import 'dart:io';

import 'package:alice_lightweight/alice.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_big5/big5.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/adapters/early_interceptor_adapter.dart';
import 'package:get/get.dart' as k;
import 'package:get/get_core/get_core.dart';

import 'connector_parameter.dart';

typedef SavePathCallback = String Function(Headers responseHeaders);

class DioConnector {
  static final Map<String, String> _headers = {
    HttpHeaders.userAgentHeader: presetUserAgent,
    "Upgrade-Insecure-Requests": "1",
  };

  static final _alice = Alice();

  Alice getAlice({required GlobalKey<NavigatorState> navigatorKey}) => _alice..setNavigatorKey(navigatorKey);

  static final dioOptions = BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 10000,
    sendTimeout: 5000,
    headers: _headers,
    responseType: ResponseType.json,
    contentType: "application/x-www-form-urlencoded",
    validateStatus: (status) => status != null && status <= 500,
    responseDecoder: null,
  );

  static final headerDecorators = {
    // To force replace the strange header responded from the i-school APIs.
    // Please refer to https://github.com/NEO-TAT/tat_flutter/issues/63 for more details.
    HttpHeaders.contentTypeHeader: (List<String> headers) {
      headers.asMap().forEach((i, header) {
        if (header.contains('text/html;;')) {
          // Replace it to the standard header value.
          headers[i] = ContentType.html.toString();
        }
      });

      return headers;
    },
  };

  final dio = Dio(dioOptions)
    ..httpClientAdapter = EarlyInterceptorAdapter(
      headerDecorators: headerDecorators,
    );

  final CookieJar _cookieJar = k.Get.find<CookieJar>();

  static final connectorError = Exception("Connector statusCode is not 200");

  DioConnector._privateConstructor();

  static final instance = DioConnector._privateConstructor();

  static String _big5Decoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) =>
      big5.decode(responseBytes);

  Future<void> init({required List<Interceptor> interceptors}) async {
    dio.interceptors.addAll(interceptors);
    dio.interceptors.add(getAlice(navigatorKey: Get.key).getDioInterceptor());
  }

  void deleteCookies() {
    try {
      _cookieJar.deleteAll();
    } catch (_, stackTrace) {
      stackTrace.printError();
    }
  }

  Future<String> getDataByPost(ConnectorParameter parameter) async {
    final response = await getDataByPostResponse(parameter);

    if (response.statusCode == HttpStatus.ok) {
      return response.toString().trim();
    }

    throw connectorError;
  }

  Future<String> getDataByGet(ConnectorParameter parameter) async {
    final response = await getDataByGetResponse(parameter);

    if (response.statusCode == HttpStatus.ok) {
      return response.toString().trim();
    }

    throw connectorError;
  }

  Future<Map<String, List<String>>> getHeadersByGet(ConnectorParameter parameter) async {
    final response = await dio.get<ResponseBody>(
      parameter.url,
      options: Options(responseType: ResponseType.stream), // set responseType to `stream`
    );

    if (response.statusCode == HttpStatus.ok) {
      return response.headers.map;
    }

    throw connectorError;
  }

  Future<Response> getDataByGetResponse(ConnectorParameter parameter) async {
    final url = parameter.url;
    final data = parameter.data;
    _handleCharsetName(parameter.charsetName);
    _handleHeaders(parameter);
    return await dio.get(url, queryParameters: data);
  }

  Future<Response> getDataByPostResponse(ConnectorParameter parameter) async {
    final url = parameter.url;
    _handleCharsetName(parameter.charsetName);
    _handleHeaders(parameter);
    return await dio.post(url, data: parameter.data);
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
    required ProgressCallback progressCallback,
    required CancelToken cancelToken,
    required Map<String, dynamic> header,
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
        .catchError(
      (onError, stack) {
        Log.eWithStack(onError.toString(), stack);
        throw onError;
      },
    );
  }

  Map<String, String> get headers => _headers;

  CookieJar get cookiesManager => _cookieJar;
}
