import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  WebViewScreen(this.title , this.url);

  @override
  _WebViewScreen createState( ) => _WebViewScreen();
}

class _WebViewScreen extends State<WebViewScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String initUrl;
  WebViewController _controller ;
  // 標記是否是加載中
  bool loading = true;
  bool isLoadingCallbackPage = false;

  @override
  void initState() {
    super.initState();
    initUrl = widget.url;
  }

  void _handleUrlChanged(String url) async {
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          title: Text(widget.title)
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
            Log.d('JS調用了Flutter By navigationDelegate');
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
