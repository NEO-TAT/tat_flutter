// TODO: Remove language version selector after migrated to null safety.
// @dart=2.17

// 🎯 Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// A function that may do somethings for the [originValues].
typedef HeaderDecorator = List<String> Function(List<String> originValues);

/// An adapter which lets you do something before the Dio interceptor executes.
/// Especially for changing the header of response.
///
/// Inherited from the `DefaultHttpClientAdapter` of Dio v4.0.6,
/// please refer to https://pub.dev/packages/dio for more details.
@immutable
@protected
@sealed
class EarlyInterceptorAdapter implements HttpClientAdapter {
  /// Initialize [EarlyInterceptorAdapter].
  ///
  /// [headerDecorators] is a [Map], each value of which is a Header modifier,
  /// and key is the target header name, suggest using the standard [HttpHeaders] library.
  /// Before outputting the final response, if a header provides a corresponding modifier,
  /// it will use the modifier to modify the header, so , the final output header value will be the modified version.
  EarlyInterceptorAdapter({
    Map<String, HeaderDecorator>? headerDecorators,
  })  : _headerDecorators = headerDecorators,
        _defaultHttpClient = HttpClient();

  final HttpClient _defaultHttpClient;
  final Completer _adapterLife = Completer();
  final Map<String, HeaderDecorator>? _headerDecorators;

  @override
  void close({bool force = false}) {
    _adapterLife.complete();
    _defaultHttpClient.close(force: force);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    if (_adapterLife.isCompleted) {
      const msg = "Can't establish connection after [HttpClientAdapter] closed!";
      log(msg);
      throw Exception(msg);
    }

    final httpClient = _configHttpClient(cancelFuture, options.connectTimeout);
    final reqFuture = httpClient.openUrl(options.method, options.uri);

    void _throwConnectingTimeout() => throw DioError(
          requestOptions: options,
          error: 'Connecting timed out [${options.connectTimeout}ms]',
          type: DioErrorType.connectTimeout,
        );

    late final HttpClientRequest request;
    try {
      request = options.connectTimeout > 0
          ? await reqFuture.timeout(Duration(milliseconds: options.connectTimeout))
          : await reqFuture;

      options.headers.forEach((k, v) {
        if (v != null) request.headers.set(k, '$v');
      });
    } on SocketException catch (e) {
      if (e.message.contains('timed out')) {
        _throwConnectingTimeout();
      }
      rethrow;
    } on TimeoutException {
      _throwConnectingTimeout();
    }

    request
      ..followRedirects = options.followRedirects
      ..maxRedirects = options.maxRedirects;

    if (requestStream != null) {
      // Transform the request data
      var future = request.addStream(requestStream);
      if (options.sendTimeout > 0) {
        future = future.timeout(Duration(milliseconds: options.sendTimeout));
      }
      try {
        await future;
      } on TimeoutException {
        request.abort();
        throw DioError(
          requestOptions: options,
          error: 'Sending timeout[${options.sendTimeout}ms]',
          type: DioErrorType.sendTimeout,
        );
      }
    }

    // [receiveTimeout] represents a timeout during data transfer! That is to say the
    // client has connected to the server.
    final receiveStart = DateTime.now().millisecondsSinceEpoch;

    var future = request.close();
    if (options.receiveTimeout > 0) {
      future = future.timeout(Duration(milliseconds: options.receiveTimeout));
    }

    late HttpClientResponse responseStream;
    try {
      responseStream = await future;
    } on TimeoutException {
      throw DioError(
        requestOptions: options,
        error: 'Receiving data timeout[${options.receiveTimeout}ms]',
        type: DioErrorType.receiveTimeout,
      );
    }

    final stream = responseStream.transform<Uint8List>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          if (options.receiveTimeout > 0 &&
              DateTime.now().millisecondsSinceEpoch - receiveStart > options.receiveTimeout) {
            sink.addError(
              DioError(
                requestOptions: options,
                error: 'Receiving data timeout[${options.receiveTimeout}ms]',
                type: DioErrorType.receiveTimeout,
              ),
            );
            responseStream.detachSocket().then((socket) => socket.destroy());
          } else {
            sink.add(Uint8List.fromList(data));
          }
        },
      ),
    );

    final headers = <String, List<String>>{};
    responseStream.headers.forEach((key, values) {
      final hasDecorator = _headerDecorators?.containsKey(key) ?? false;
      final decorator = hasDecorator ? _headerDecorators![key] : null;
      headers[key] = decorator != null ? decorator(values) : values;
    });

    return ResponseBody(
      stream,
      responseStream.statusCode,
      headers: headers,
      isRedirect: responseStream.isRedirect || responseStream.redirects.isNotEmpty,
      redirects: responseStream.redirects
          .map(
            (e) => RedirectRecord(
              e.statusCode,
              e.method,
              e.location,
            ),
          )
          .toList(),
      statusMessage: responseStream.reasonPhrase,
    );
  }

  HttpClient _configHttpClient(Future? cancelFuture, int connectionTimeout) {
    final configuredConnectionTimeout = connectionTimeout > 0 ? Duration(milliseconds: connectionTimeout) : null;

    if (cancelFuture != null) {
      final httpClient = HttpClient()
        ..userAgent = null
        ..idleTimeout = Duration.zero;

      cancelFuture.whenComplete(() {
        Future.delayed(Duration.zero).then((_) {
          try {
            httpClient.close(force: true);
          } catch (e) {
            log(e.toString());
          }
        });
      });
      return httpClient..connectionTimeout = configuredConnectionTimeout;
    }

    _defaultHttpClient
      ..idleTimeout = const Duration(seconds: 3)
      ..connectionTimeout = configuredConnectionTimeout;

    return _defaultHttpClient;
  }
}
