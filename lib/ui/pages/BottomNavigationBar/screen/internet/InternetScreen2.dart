import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/Connector.dart';
import 'package:flutter_app/src/connector/ConnectorParameter.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:webview_flutter/webview_flutter.dart';


class InternetScreen2 extends StatefulWidget {
  @override
  _InternetScreen createState( ) => _InternetScreen();
}

class _InternetScreen extends State<InternetScreen2> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String initUrl = "https://nportal.ntut.edu.tw/myPortal.do";
  WebViewController _controller ;
  // 标记是否是加载中
  bool loading = true;
  bool isLoadingCallbackPage = false;

  @override
  void initState() {
    super.initState();
    //initUrl = "https://nportal.ntut.edu.tw/index.do";
  }

  void _handleUrlChanged(String url) async {
    if( url == initUrl ) {
      //flutterWebViewPlugin.cleanCookies();
      String account = Model.instance.userData.account;
      String password = Model.instance.userData.password;
      //_controller.clearCache();
      _controller.evaluateJavascript( 'document.login.muid.value="$account"');
      _controller.evaluateJavascript( 'document.login.mpassword.value="$password"');
      //await Future.delayed(Duration(seconds: 10));
      _controller.evaluateJavascript( 'thisform.submit()');
    }
    Log.d( url );
  }

  String _getCookies(String cookies, String key) {
    return cookies.split(key)[1].split(";")[0].replaceAll("=", "");
  }

  Map<String, String> getHeader(String url) {
    Map<String, String> myHeader = Connector.getLoginHeaders(url);
    String key;
    String cookies = myHeader["Cookie"];
    myHeader = Map();
    String cookiesNew = "";
    key = "JSESSIONID";
    cookiesNew += key + "=" + _getCookies(cookies, key) + "; ";
    key = "cookiesession1";
    cookiesNew += key + "=" + _getCookies(cookies, key) + "; ";

    myHeader["Cookie"] = cookiesNew;
    myHeader["Referer"] = "https://nportal.ntut.edu.tw/login.do";
    myHeader["content-type"] = "application/x-www-form-urlencoded";
    Log.d(cookiesNew );
    return myHeader;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("internet")
      ),
      body: WebView(
        userAgent: presetUserAgent,
        javascriptMode : JavascriptMode.unrestricted,
        onWebViewCreated : (WebViewController controller) {
          _controller = controller;
          _controller.loadUrl( initUrl );
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('js://webview')) {
            Log.d('JS调用了Flutter By navigationDelegate');
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onPageFinished: (url ){
          _handleUrlChanged( url );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
