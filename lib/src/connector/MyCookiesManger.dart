import 'dart:core';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:sprintf/sprintf.dart';

class MyCookieManager {

  MyCookieManager._privateConstructor();
  static final MyCookieManager instance = MyCookieManager._privateConstructor();
  Map<String, Map<String,String> > cookiesMap = Map();

  void setCookies(String host , String cookies){
    //37ff5364b2b59a19c61eebceb233268b=0b417nttrt68cp91u5609jjh05; path=/; HttpOnly,cookie_login=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT
    List<String> cookiesList = List();
    for ( String cookiesItem in cookies.split(",")){
      List<String> cookiesSplit = cookiesItem.split(";");
      String realCookies = cookiesSplit[0];
      if ( realCookies.contains("=") && cookiesSplit.length > 1){
        if( cookiesSplit[1].toLowerCase().contains("path")){
          cookiesList.add(realCookies);
        }
        //Log.d( sprintf( "Host: %s , Cookies: %s" , [host , realCookies] ) );
      }
    }
    _addCookies(host , cookiesList);
  }

  String _getCookiesKey(String cookies){
    return cookies.split("=")[0];
  }

  String _getCookiesValue(String cookies){
    return cookies.split("=")[1];
  }

  void clearCookies(){
    cookiesMap = Map();
  }

  String getCookies(String host){
    String result = '';
    if ( cookiesMap.containsKey(host) ){
      Map<String,String> cookiesList = cookiesMap[host];
      for ( String item in cookiesList.keys ){
        if ( result.isNotEmpty ){
          result += '; ';
        }
        result += sprintf( "%s=%s" , [ item , cookiesList[item] ]);
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
      Map<String,String> cookiesList = cookiesMap[host];
      for ( String cookiesItem in cookies ){
        String key = _getCookiesKey(cookiesItem);
        String value = _getCookiesValue(cookiesItem);
        if ( cookiesList.containsKey( key ) ){
          Log.d( sprintf( "Host: %s , Replace Cookies: %s=%s" , [host , key , value] ) );
        }else{
          Log.d( sprintf( "Host: %s , Add Cookies: %s=%s" , [host , key , value] ) );
        }
        cookiesList[key] = value;
      }
      cookiesMap[host] = cookiesList;
    }
    else{
      Map<String,String> cookiesList = Map();
      for (  String cookiesItem  in cookies){
        String key = _getCookiesKey(cookiesItem);
        String value = _getCookiesValue(cookiesItem);
        Log.d( sprintf( "Host: %s , Add Cookies: %s=%s" , [host , key , value] ) );
        cookiesList[ key ] = value;
      }
      cookiesMap[host] = cookiesList;
    }

  }


}
