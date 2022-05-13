// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:sprintf/sprintf.dart';

import 'connector_parameter.dart';
import 'dio_connector.dart';

class Connector {
  static Future<String> getDataByPost(ConnectorParameter parameter) async {
    try {
      String result = await DioConnector.instance.getDataByPost(parameter);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getDataByGet(ConnectorParameter parameter) async {
    try {
      String result = await DioConnector.instance.getDataByGet(parameter);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> getDataByGetResponse(ConnectorParameter parameter) async {
    Response result;
    try {
      result = await DioConnector.instance.getDataByGetResponse(parameter);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> getDataByPostResponse(ConnectorParameter parameter) async {
    Response result;
    try {
      result = await DioConnector.instance.getDataByPostResponse(parameter);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, String>> getLoginHeaders(String url) async {
    try {
      final cookieJar = DioConnector.instance.cookiesManager;
      final headers = Map<String, String>.from(DioConnector.instance.headers);
      final cookies = await cookieJar.loadForRequest(Uri.parse(url));

      headers[HttpHeaders.cookieHeader] = cookies.first.toString();
      headers.remove(HttpHeaders.contentTypeHeader);

      return headers;
    } catch (e) {
      Log.d(e.toString());
      return null;
    }
  }

  static Future<String> getFileName(String url) async {
    String fileName;
    try {
      ConnectorParameter parameter = ConnectorParameter(url);
      Map<String, List<String>> headers = await DioConnector.instance.getHeadersByGet(parameter);
      if (headers.containsKey("content-disposition")) {
        //代表有名字
        List<String> name = headers["content-disposition"];
        RegExp exp = RegExp("['|\"](?<name>.+)['|\"]");
        RegExpMatch matches = exp.firstMatch(name[0]);
        fileName = matches.group(1);
      } else if (headers.containsKey("content-type")) {
        List<String> name = headers["content-type"];
        if (name[0].toLowerCase().contains("pdf")) {
          //是application/pdf
          fileName = '.pdf';
        }
      }
      if (headers.containsKey("content-length")) {
        String size = headers["content-length"][0];
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