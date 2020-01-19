import 'dart:core';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:sprintf/sprintf.dart';

class MyCookieManager {

  MyCookieManager._privateConstructor();
  static final MyCookieManager instance = MyCookieManager._privateConstructor();
  Map<String, List<String>> cookiesMap = Map();

  void setCookies(String host , String cookies){
    List<String> cookiesList = List();
    for ( String cookiesItem in cookies.split(",")){
      String realCookies = cookiesItem.split(";")[0];
      cookiesList.add(realCookies);
      Log.d( sprintf( "Host: %s , Cookies: %s" , [host , realCookies] ) );
    }
    _addCookies(host , cookiesList);
  }

  String _getCookiesKey(String cookies){
    return cookies.split("=")[0];
  }

  void clearCookies(){
    cookiesMap = Map();
  }

  String getCookies(String host){
    String result = '';
    if ( cookiesMap.containsKey(host) ){
      for ( String item in  cookiesMap[host] ){
        if ( result.isNotEmpty ){
          result += '; ';
        }
        result += item;
      }
      Log.d( sprintf("Host : %s , GetCookies : %s" , [host , result ]));
      return result;
    }else{
      Log.d( sprintf("Host : %s , NoCookies" , [host]));
      return null;
    }
  }


  void _addCookies(String host , List<String> cookies){
    if(cookiesMap.containsKey(host)){
      for ( String cookiesItem in cookiesMap[host] ){
        Log.d( sprintf( "Host: %s , Replace Cookies: %s" , [host , cookiesItem] ) );
      }
    }
    cookiesMap[host] = cookies;
  }


}
