import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternetScreen extends StatefulWidget {
  @override
  _InternetScreen createState( ) => _InternetScreen();
}

class _InternetScreen extends State<InternetScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String url = "https://nportal.ntut.edu.tw/myPortal.do";
  String title = 'apple';

  // 标记是否是加载中
  bool loading = true;
  bool isLoadingCallbackPage = false;
  StreamSubscription<String> onUrlChanged;
  StreamSubscription<WebViewStateChanged> onStateChanged;
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      _handleStateChange(state);
    });

    onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((url) {
      _handleUrlChanged(url);
    });

    url = "https://nportal.ntut.edu.tw/index.do";

    Future.delayed(Duration(seconds: 1)).then((_){
      flutterWebViewPlugin.reloadUrl(url);
    });


    Log.d( "reload" );
  }


  void _handleUrlChanged(String url) async {
    if( url == "https://nportal.ntut.edu.tw/index.do"){
      //flutterWebViewPlugin.cleanCookies();
      String account = Model.instance.userData.account;
      String password = Model.instance.userData.password;

      flutterWebViewPlugin.evalJavascript( 'document.login.muid.value="$account"');
      flutterWebViewPlugin.evalJavascript( 'document.login.mpassword.value="$password"');
      await Future.delayed(Duration(seconds: 10));
      flutterWebViewPlugin.evalJavascript( 'thisform.submit()');
    }
    Log.d( url );
  }

  void _handleStateChange(WebViewStateChanged state) async {
    switch (state.type) {
      case WebViewState.abortLoad:
        break;
      case WebViewState.shouldStart:
        setState(() {
          loading = true;
        });
        break;
      case WebViewState.startLoad:
        break;
      case WebViewState.finishLoad:
        setState(() {
          loading = false;
        });
        if (isLoadingCallbackPage) {
          parseResult();
        }
        break;
    }
  }

  void parseResult() {
//    flutterWebViewPlugin.evalJavascript("get();").then((result) {
//      // result json字符串，包含token信息
//
//    });
  }

  String _getCookies(String cookies, String key) {
    return cookies.split(key)[1].split(";")[0].replaceAll("=", "");
  }

  Map<String, String> getHeader() {
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

    Log.d(cookiesNew );
    return myHeader;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫
    List<Widget> titleContent = [];
    titleContent.add(
      Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
    if (loading) {
      titleContent.add(CupertinoActivityIndicator());
    }
    titleContent.add(Container(width: 50.0));

    return new WebviewScaffold(
      //url: url,
      userAgent: presetUserAgent,
      key: scaffoldKey,
      //clearCache: true,
      //clearCookies: true,
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: titleContent,
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
    );
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    super.dispose();
    onUrlChanged.cancel();
    onStateChanged.cancel();
    flutterWebViewPlugin.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
