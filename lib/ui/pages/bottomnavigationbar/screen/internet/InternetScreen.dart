import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/Connector.dart';
import 'package:flutter_app/src/connector/DioConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class InternetScreen extends StatefulWidget {
  @override
  _InternetScreen createState() => _InternetScreen();
}

class _InternetScreen extends State<InternetScreen> {
  String url = "https://nportal.ntut.edu.tw/myPortal.do" ;
  String title = 'apple';

  // 标记是否是加载中
  bool loading = true;
  bool isLoadingCallbackPage = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  StreamSubscription<String> onUrlChanged;
  StreamSubscription<WebViewStateChanged> onStateChanged;
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
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
    });
  }

  void parseResult() {
//    flutterWebViewPlugin.evalJavascript("get();").then((result) {
//      // result json字符串，包含token信息
//
//    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> myHeader = Connector.getLoginHeaders(url);
    myHeader.remove("Referer");
    myHeader["Sec-Fetch-User"] = ':1';
    myHeader["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9";
    myHeader["Accept-Encoding"] = "gzip, deflate, br";
    myHeader["Accept-Language"] = "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6";
    Log.d(myHeader.toString());
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
      //headers: myHeader,
      //key: scaffoldKey,
      url: url,
      // 登录的URL
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
    onUrlChanged.cancel();
    onStateChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }
}
