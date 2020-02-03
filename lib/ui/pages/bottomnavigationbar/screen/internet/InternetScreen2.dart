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
  String url = "https://nportal.ntut.edu.tw/myPortal.do";
  WebViewController _controller ;
  // 标记是否是加载中
  bool loading = true;
  bool isLoadingCallbackPage = false;

  @override
  void initState() {
    super.initState();

    url = "https://nportal.ntut.edu.tw/index.do";

  }


  void _handleUrlChanged(String url) async {
    if( url == "https://nportal.ntut.edu.tw/index.do"){
      //flutterWebViewPlugin.cleanCookies();
      String account = Model.instance.userData.account;
      String password = Model.instance.userData.password;

      _controller.evaluateJavascript( 'document.login.muid.value="$account"');
      _controller.evaluateJavascript( 'document.login.mpassword.value="$password"');
      await Future.delayed(Duration(seconds: 10));
      _controller.evaluateJavascript( 'thisform.submit()');
    }
    Log.d( url );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫

    return Scaffold(
      appBar: AppBar(
        title: Text("internet")
      ),
      body: WebView(
        javascriptMode : JavascriptMode.unrestricted,
        onWebViewCreated : (WebViewController controller) {
          _controller = controller;
          _controller.loadUrl(url);
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
