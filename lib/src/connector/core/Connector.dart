//  北科課程助手
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:tat/debug/log/Log.dart';
import 'package:sprintf/sprintf.dart';

import 'connector_parameter.dart';
import 'dio_connector.dart';

class Connector {
  static Future<String> getDataByPost(ConnectorParameter parameter) async {
    try {
      String result = await DioConnector.instance.getDataByPost(parameter);
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> getDataByGet(ConnectorParameter parameter) async {
    try {
      String result = await DioConnector.instance.getDataByGet(parameter);
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<Response> getDataByGetResponse(
      ConnectorParameter parameter) async {
    Response result;
    try {
      result = await DioConnector.instance.getDataByGetResponse(parameter);
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<Response> getDataByPostResponse(
      ConnectorParameter parameter) async {
    Response result;
    try {
      result = await DioConnector.instance.getDataByPostResponse(parameter);
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Map<String, String> getLoginHeaders(String url) {
    try {
      PersistCookieJar cookieJar = DioConnector.instance.cookiesManager;
      Map<String, String> headers = Map.from(DioConnector.instance.headers);
      headers["Cookie"] = cookieJar
          .loadForRequest(Uri.parse(url))
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "");
      headers.remove("content-type");
      //Log.d(headers.toString());
      return headers;
    } catch (e) {
      Log.d(e.toString());
      return Map();
    }
  }

  static Future<String?> getFileName(String url) async {
    String? fileName;
    try {
      ConnectorParameter parameter = ConnectorParameter(url);
      Map<String, List<String>> headers =
          await DioConnector.instance.getHeadersByGet(parameter);
      if (headers.containsKey("content-disposition")) {
        // means name is exist.
        final name = headers["content-disposition"]!;
        final exp = RegExp("['|\"](?<name>.+)['|\"]");
        final matches = exp.firstMatch(name[0])!;
        fileName = matches.group(1);
      } else if (headers.containsKey("content-type")) {
        final name = headers["content-type"]!;
        if (name[0].toLowerCase().contains("pdf")) {
          // request type is application/pdf
          fileName = '.pdf';
        }
      }
      if (headers.containsKey("content-length")) {
        final size = headers["content-length"]![0];
        Log.d("file size = $size");
      }
      Log.d("getFileName $fileName");
      return fileName;
    } catch (e) {
      Log.d(e.toString());
      return null;
    }
  }

  static void printHeader(Map<String, String> headers) {
    for (String key in headers.keys) {
      Log.d(sprintf("%s : %s", [key, headers[key]]));
    }
  }
}
