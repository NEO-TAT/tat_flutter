// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/src/util/custom_cookie_manager.dart';
import 'package:html/parser.dart';

import 'package:flutter_app/src/store/local_storage.dart';


class NTPU_Connector{
  static const String host = "https://my.ntpu.edu.tw/";
  static const String LoginURL = "${host}login";

  static Future<bool> Login(String str_Account, String str_Password) async {
    // Enter login page to get login token and cookie.
    Dio NetworkConnector = LocalStorage.NetworkConnector;
    if(NetworkConnector.interceptors.isNotEmpty) {
      for(Interceptor Run in NetworkConnector.interceptors) {
        NetworkConnector.interceptors.remove(Run);
        if(NetworkConnector.interceptors.isEmpty) {
          break;
        }
      }
    }
    final CookieJar _Cookie = CookieJar();
    NetworkConnector.interceptors.add(CustomCookieManager(_Cookie));
    Response LoginResponse = await NetworkConnector.get(LoginURL);

    String _token = parse(LoginResponse.toString()).getElementsByClassName("login-form")[0].getElementsByTagName("input")[0].attributes["value"].toString();


    // NTPU SSO Login.
    Map<String, String> LoginPayload = {"_token": _token, "username": str_Account, "password": str_Password};
    LoginResponse = await NetworkConnector.post(LoginURL, data: LoginPayload);
    String RedirectURL = "";
    do {
      RedirectURL = LoginResponse.headers.value("location").toString();
      LoginResponse = await NetworkConnector.get(RedirectURL);
    }
    while(LoginResponse.headers.value("location") != null);

    if(RedirectURL == "https://my.ntpu.edu.tw/login") {
      return false;
    }

    // Save sessions cookies.
    return true;
  }
}

