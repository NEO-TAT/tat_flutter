import 'package:flutter_app/debug/log/Log.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:sprintf/sprintf.dart';

class Connector {
  static final _className = "Connector";
  static Map<String, String> headers= {
    "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36",
    "Upgrade-Insecure-Requests":"1"
  };
  static Future<String> getDataByPost(String url, Map<String, String> data) async{
    var response = await http.post(url , body: data , headers:headers);
    handleCookies(url);
    return response.body;
  }

  static Future<String> getDataByGet(String url) async{
    var response = await http.get(url , headers:headers);
    return response.body;
  }

  static handleCookies(String url) async {
    String hostname = Requests.getHostname(url);
    Map<String, String> cookies = await Requests.getStoredCookies(hostname);
    for ( String key in cookies.keys ){
      Log.e(_className , sprintf("key: %s , %s" , [key , cookies[key] ] ));
    }
  }


}
