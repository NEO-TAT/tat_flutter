import 'package:flutter_app/connector/MyCookiesManger.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:sprintf/sprintf.dart';

class Connector {
  static final MyCookieManager cookieManager = MyCookieManager.instance;
  static final String _getCookiesKey = 'set-cookie';
  static final String _setCookiesKey = 'Cookie';
  static final String _userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36";
  static final Duration _timeOut = Duration(seconds:15);
  static Map<String, String> headers= {
    "User-Agent": _userAgent,
    "Upgrade-Insecure-Requests":"1" ,
    "Referer": "https://nportal.ntut.edu.tw"
  };
  static Future<String> getDataByPost(String url, Map<String, String> data) async {
    headers["User-Agent"] =  "Direk Android App";
    try {
      var response = await http.post(url, body: data, headers: headers).timeout(_timeOut);
      _handleCookies(url, response.headers[_getCookiesKey]);
      return response.body;
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<String> getDataByGet(String url) async{
    headers["User-Agent"] =  _userAgent;
    _setHeadersCookies(url);
    try {
      var response = await http.get(url, headers: headers).timeout(_timeOut);
      if (response.statusCode == 200) {
        _handleCookies(url, response.headers[_getCookiesKey]);
        return response.body;
      } else {
        return "";
      }
    } on Exception catch(e){
      throw e;
    }
  }

  static _handleCookies(String url , String cookies ) async {
    String host = _getHost(url);
    if (cookies != null){
      cookieManager.setCookies(host, cookies);
    }
  }

  static _setHeadersCookies(String url){
    String cookies = _getCookies(url);
    if ( cookies != null ){
      headers[_setCookiesKey] = cookies;
    }else{
      headers.remove(_setCookiesKey);
    }
  }

  static String _getCookies(String url){
    String host = _getHost(url);
    return cookieManager.getCookies(host);
  }

  static String _getHost(String url){
    String host = Requests.getHostname(url);
    host = host.split(":")[0];
    return host;
  }


  static Map<String,String> getLoginHeaders(String url){
    _setHeadersCookies(url);
    return headers;
  }



}
