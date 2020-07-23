import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import '../../../ui/other/MyToast.dart';
import '../../R.dart';

class ErrorInterceptors extends InterceptorsWrapper {
  @override
  onError(DioError err) async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      MyToast.show(R.current.pleaseConnectToNetwork);
    }
  }
}
