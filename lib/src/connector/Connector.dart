import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/DioConnector.dart';
import 'package:sprintf/sprintf.dart';

import 'ConnectorParameter.dart';

class Connector {

  static Future<String> getDataByPost( ConnectorParameter parameter  ) async {
    try{
      String result = await DioConnector.instance.getDataByPost( parameter );
      return result;
    } on Exception catch(e){
      throw e;
    }
  }

  static Future<String> getDataByGet( ConnectorParameter parameter ) async{
    try{
      String result = await DioConnector.instance.getDataByGet( parameter );
      return result;
    } on Exception catch(e){
      throw e;
    }
  }

  static Future<Response> getDataByGetResponse( ConnectorParameter parameter ) async{
    Response result;
    try{
      result = await DioConnector.instance.getDataByGetResponse( parameter  );
      return result;
    } on Exception catch(e){
      throw e;
    }
  }


  static Future<Response> getDataByPostResponse( ConnectorParameter parameter ) async {
    Response result;
    try{
      result = await DioConnector.instance.getDataByPostResponse( parameter );
      return result;
    } on Exception catch(e){
      throw e;
    }
  }

  static Map<String,String> getLoginHeaders(String url){
    try{
      PersistCookieJar cookieJar = DioConnector.instance.cookiesManager;
      Map<String,String> headers = DioConnector.instance.headers;
      headers["Cookie"] = cookieJar.loadForRequest( Uri.parse(url) ).toString().replaceAll("[", "").replaceAll("]", "");
      headers.remove("content-type");
      Log.d( headers.toString() );
      return headers;
    }on Exception catch(e){
      Log.d(e.toString());
      return Map();
    }
  }

  static void printHeader(Map<String ,String> headers){
    for(String key in headers.keys){
      Log.d( sprintf("%s : %s" , [ key , headers[key] ] ) );
    }
  }


}
