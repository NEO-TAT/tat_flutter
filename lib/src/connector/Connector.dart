import 'dart:io';

import 'package:flutter_app/debug/log/Log.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'MyCookiesManger.dart';

const String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36";

class Connector {
  static final MyCookieManager cookieManager = MyCookieManager.instance;
  static final String _getCookiesKey = 'set-cookie';
  static final String _setCookiesKey = 'Cookie';
  static final String _userAgent = userAgent;
  static final Duration _timeOut = Duration(seconds:15);
  static bool _setCookies  = true;
  static String _refererUrl = "https://nportal.ntut.edu.tw";
  static Map<String, String> headers= {
  "User-Agent"       : _userAgent,
  "Upgrade-Insecure-Requests":"1" ,
  "Referer": _refererUrl,
  };
  static final Exception connectorError = Exception("Connector statusCode is not 200");


  static Future<String> getDataByPost(String url, Map<String, String> data , { String userAgent : userAgent } ) async {
    headers["User-Agent"] =  userAgent;
    try {
      http.Response response = await getDataByPostResponse(url , data );
      if(response.statusCode == 200 ){
        return response.body;
      }else{
        throw connectorError;
      }
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<String> getDataByGet(String url , [Map<String, String> data]) async{
    headers["User-Agent"] =  _userAgent;
    try {
      http.Response response = await getDataByGetResponse(url , data);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw connectorError;
      }
    } on Exception catch(e){
      throw e;
    }
  }


  static Future<http.Response> getDataByGetResponse(String url , [Map<String, String> data]) async{
    try {
      if( data != null ){
        url = _putDataToUrl(url , data);
      }
      _setReferer(url);
      _setHeadersCookies(url);
      Log.d( "Get $url");
      http.Response response = await http.get(url,headers: headers ).timeout(_timeOut);
      _handleCookies(url, response.headers[_getCookiesKey]);
      //Log.d( response.request.headers.toString() );
      return response;
    } on Exception catch(e){
      throw e;
    }
  }


  static Future<http.Response> getDataByPostResponse(String url, Map<String, String> data ) async {
    try {
      _setReferer( _putDataToUrl(url, data) );
      Log.d( sprintf("Post %s , Data : %s" , [url , data.toString() ]) );
      http.Response response = await http.post(url, body: data, headers: headers).timeout(_timeOut);
      _handleCookies(url, response.headers[_getCookiesKey]);
      //Log.d( response.request.headers.toString() );
      return response;
    } on Exception catch (e) {
      throw e;
    }
  }

  static _handleCookies(String url , String cookies ) async {
    String host = _getHost(url);
    if (cookies != null && _setCookies){
      Log.d( sprintf("Host : %s , Cookies : %s" , [host , cookies] ));
      cookieManager.setCookies(host, cookies);
    }
    _setCookies  = true;
  }

  static String _putDataToUrl(String url , Map<String, String> data){
    Uri newUrl = Uri.https( _getHost(url) , _getPath(url) ,  data);
    url = newUrl.toString();
    Log.d( "put data $url");
    return url;
  }

  static _setHeadersCookies(String url){
    String cookies = _getCookies(url);
    if ( cookies != null ){
      headers[_setCookiesKey] = cookies;
    }else{
      headers.remove(_setCookiesKey);
    }
  }

  static _setReferer(String url){
    Log.d( "Referer : $_refererUrl");
    headers["Referer"] = _refererUrl;
    _refererUrl = url;
  }

  static String _getCookies(String url){
    String host = _getHost(url);
    return cookieManager.getCookies(host);
  }

  static String _getHost(String url){
    String host = Uri.parse(url).host;
    return host;
  }
  static String _getPath(String url){
    String path = Uri.parse(url).path;
    return path;
  }


  static Map<String,String> getLoginHeaders(String url){
    _setHeadersCookies(url);
    return headers;
  }

  static void printHeader(Map<String ,String> headers){
    for(String key in headers.keys){
      Log.d( sprintf("%s : %s" , [ key , headers[key] ] ) );
    }
  }
  static set setStoreCookies(bool value){  //只會關閉一次
    _setCookies = value;
  }




}
