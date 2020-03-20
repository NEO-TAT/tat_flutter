//
//  DioConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/connector/requests/requests.dart';
import 'package:sprintf/sprintf.dart';

import 'ConnectorParameter.dart';

class RequestsConnector {
  static String _refererUrl = "https://istudy.ntut.edu.tw";
  static Map<String, String> _headers = {
    "User-Agent": presetComputerUserAgent,
    "Upgrade-Insecure-Requests": "1",
    "Referer": _refererUrl,
  };
  static final Exception connectorError =
      Exception("Connector statusCode is not 200");

  static Future<String> getDataByPost(ConnectorParameter parameter) async {
    try {
      Response response = await getDataByPostResponse(parameter);
      if (response.statusCode == HttpStatus.ok) {
        return response.content();
      } else {
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<String> getDataByGet(ConnectorParameter parameter) async {
    Response response;
    try {
      response = await getDataByGetResponse(parameter);
      if (response.statusCode == HttpStatus.ok) {
        return response.content();
      } else {
        throw connectorError;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<Response> getDataByGetResponse(
      ConnectorParameter parameter) async {
    Response response;
    try {
      String url = parameter.url;
      Map<String, String> data = parameter.data;
      _handleCharsetName(parameter.charsetName);
      _handleHeaders(parameter);
      await _handleCookiesBefore(url);
      Log.d(sprintf("Get : %s", [_putDataToUrl(url, data)]));
      response = await Requests.get(url, headers: _headers);
      await _handleCookiesAfter(parameter.url,
          response.rawResponse.headers[HttpHeaders.setCookieHeader]);
      return response;
    } catch (e) {
      throw e;
    }
  }

  static Future<Response> getDataByPostResponse(
      ConnectorParameter parameter) async {
    Response response;
    try {
      String url = parameter.url;
      Map<String, String> data = parameter.data;
      _handleCharsetName(parameter.charsetName);
      _handleHeaders(parameter);
      await _handleCookiesBefore(url);
      Log.d(sprintf("Post : %s", [_putDataToUrl(url, data)]));
      response = await Requests.post(url, body: data , headers: _headers);
      await _handleCookiesAfter(parameter.url,
          response.rawResponse.headers[HttpHeaders.setCookieHeader]);
      return response;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> deleteCookies(String url) async {
    Log.d("deleteCookies");
    String hostName = Requests.getHostname(url);
    await Requests.clearStoredCookies(hostName);
    DioConnector.instance.cookiesManager.delete(Uri.parse(url));
  }

  static String _putDataToUrl(String url, Map<String, String> data) {
    Uri newUrl = Uri.https(_getHost(url), _getPath(url), data);
    url = newUrl.toString();
    //Log.d( "put data $url");
    return url;
  }

  static void _handleHeaders(ConnectorParameter parameter) {
    _setReferer(parameter.url);
  }

  static void _handleCharsetName(String charsetName) {}

  static void _setReferer(String url) {
    //Log.d("Referer : $_refererUrl");
    _headers["Referer"] = _refererUrl;
    _refererUrl = url;
  }

  static String _getHost(String url) {
    String host = Uri.parse(url).host;
    return host;
  }

  static Future<void> _handleCookiesAfter(String url, String setCookies) async {
    Uri uri = Uri.parse(url).normalizePath();
    CookieJar cookieJar = DioConnector.instance.cookiesManager;
    if (setCookies == null) return;
    if (setCookies.contains(",") == false) return;
    List<String> cookiesSplit = setCookies.split(",");
    List<int> removeIndex = List();
    List<Cookie> cookiesList = List();
    for (int i = 0; i < cookiesSplit.length; i++) {
      String cookiesItem = cookiesSplit[i];
      if (cookiesItem[0].contains(" ")) {
        cookiesSplit[i - 1] += cookiesItem;
        removeIndex.add(i);
      }
    }
    for (int index in removeIndex.reversed.toList()) {
      cookiesSplit.removeAt(index);
    }
    if (cookiesSplit != null) {
      cookieJar.saveFromResponse(
        uri,
        cookiesSplit.map((str) => Cookie.fromSetCookieValue(str)).toList(),
      );
    }
  }

  static Future<void> _handleCookiesBefore(String url) async {
    Uri uri = Uri.parse(url).normalizePath(); //須加上normalizePath
    CookieJar cookieJar = DioConnector.instance.cookiesManager;
    var cookies = cookieJar.loadForRequest(uri);
    cookies.removeWhere((cookie) {
      if (cookie.expires != null) {
        return cookie.expires.isBefore(DateTime.now());
      }
      return false;
    });
    String cookie = getCookies(cookies);
    _headers[HttpHeaders.cookieHeader] = cookie;
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => "${cookie.name}=${cookie.value}").join('; ');
  }

  static String _getPath(String url) {
    String path = Uri.parse(url).path;
    return path;
  }
}
