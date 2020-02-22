//
//  DioConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:convert';
import 'dart:io';
import 'package:big5/big5.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:requests/requests.dart';
import 'package:sprintf/sprintf.dart';
import 'ConnectorParameter.dart';


class RequestsConnector {
  static String _refererUrl = "https://nportal.ntut.edu.tw";
  static Map<String, String> _headers= {
    "User-Agent"       : presetComputerUserAgent,
    "Upgrade-Insecure-Requests":"1" ,
    "Referer": _refererUrl,
  };
  static final Exception connectorError = Exception("Connector statusCode is not 200");

  static Future<String> getDataByPost( ConnectorParameter parameter) async {
    try {
      Response response = await getDataByPostResponse( parameter );
      if(response.statusCode ==  HttpStatus.ok ){
        return response.content();
      }else{
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<String> getDataByGet( ConnectorParameter parameter  ) async{
    Response response;
    try {
      response = await getDataByGetResponse( parameter );
      if (response.statusCode == HttpStatus.ok ) {
        return response.content();
      } else {
        throw connectorError;
      }
    } catch(e){
      throw e;
    }
  }



  static Future<Response> getDataByGetResponse(  ConnectorParameter parameter ) async{
    Response response;
    try {
      String url = parameter.url;
      Map<String , String > data = parameter.data;
      _handleCharsetName( parameter.charsetName );
      _handleHeaders( parameter );
      Log.d( sprintf("Get : %s" , [ _putDataToUrl(url, data) ]  ));
      response = await Requests.get(url , headers: _headers );
      return response;
    } catch(e){
      throw e;
    }
  }


  static Future<Response> getDataByPostResponse( ConnectorParameter parameter  ) async {
    Response response;
    try {
      String url = parameter.url;
      Map<String , String > data = parameter.data;
      _handleCharsetName( parameter.charsetName );
      _handleHeaders( parameter );
      Log.d( sprintf("Post : %s" , [ _putDataToUrl(url, data) ]  ));
      response = await Requests.post( url , body: data , headers: _headers );
      return response;
    } catch (e) {
      throw e;
    }
  }

  static String _putDataToUrl(String url , Map<String, String> data){
    Uri newUrl = Uri.https( _getHost(url) , _getPath(url) ,  data);
    url = newUrl.toString();
    //Log.d( "put data $url");
    return url;
  }

  static void _handleHeaders( ConnectorParameter parameter){
  }

  static void _handleCharsetName(String charsetName){
  }

  static void _setReferer(String url){
    Log.d( "Referer : $_refererUrl");
    _headers["Referer"] = _refererUrl;
    _refererUrl = url;
  }

  static String _getHost(String url){
    String host = Uri.parse(url).host;
    return host;
  }

  static String _getPath(String url){
    String path = Uri.parse(url).path;
    return path;
  }

}
