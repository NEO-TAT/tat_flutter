import 'package:dio/dio.dart';

/**
 * header攔截器
 * Created by guoshuyu
 * on 2019/3/23.
 */
class HeaderInterceptors extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async {
    ///超時
    options.connectTimeout = 10000;
    options.receiveTimeout = 10000;

    return options;
  }
}
