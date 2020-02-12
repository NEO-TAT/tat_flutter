//
//  Connector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:sprintf/sprintf.dart';

import 'ConnectorParameter.dart';
import 'DioConnector.dart';

class Connector {

  static Future<String> getDataByPost( ConnectorParameter parameter  ) async {
    try{
      String result = await DioConnector.instance.getDataByPost( parameter );
      return result;
    } catch(e){
      throw e;
    }
  }

  static Future<String> getDataByGet( ConnectorParameter parameter ) async{
    try{
      String result = await DioConnector.instance.getDataByGet( parameter );
      return result;
    } catch(e){
      throw e;
    }
  }

  static Future<Response> getDataByGetResponse( ConnectorParameter parameter ) async{
    Response result;
    try{
      result = await DioConnector.instance.getDataByGetResponse( parameter  );
      return result;
    } catch(e){
      throw e;
    }
  }


  static Future<Response> getDataByPostResponse( ConnectorParameter parameter ) async {
    Response result;
    try{
      result = await DioConnector.instance.getDataByPostResponse( parameter );
      return result;
    } catch(e){
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
    } catch(e){
      Log.d(e.toString());
      return Map();
    }
  }


  static Future<String> getFileName(String url) async{
    try{
      ConnectorParameter parameter = ConnectorParameter(url);
      Map<String, List<String>> headers = await DioConnector.instance.getHeadersByGet(parameter);
      List<String> name = headers[ "content-disposition"];
      Log.d( name[0]);
      return name[0].split('"')[1];
    } catch(e){
      Log.d(e.toString());
      return null;
    }
  }

  static void printHeader(Map<String ,String> headers){
    for(String key in headers.keys){
      Log.d( sprintf("%s : %s" , [ key , headers[key] ] ) );
    }
  }


}
