import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import '../../../ui/other/MyToast.dart';
import '../../R.dart';

class ErrorInterceptors extends InterceptorsWrapper {
  final Dio dio;

  ErrorInterceptors(this.dio);

  @override
  onRequest(RequestOptions options) async {}

  @override
  onError(DioError err) async {}
}
