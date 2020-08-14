import 'package:dio/dio.dart';

class ErrorInterceptors extends InterceptorsWrapper {
  final Dio dio;

  ErrorInterceptors(this.dio);

  @override
  onRequest(RequestOptions options) async {}

  @override
  onError(DioError err) async {}
}
