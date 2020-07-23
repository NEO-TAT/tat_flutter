import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPluginPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPluginPage(this.title, this.url);

  @override
  _WebViewPluginPageState createState() => _WebViewPluginPageState();
}

class _WebViewPluginPageState extends State<WebViewPluginPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String initUrl;

  // 標記是否是加載中
  bool loading = true;
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
    initUrl = widget.url;
  }

  void _handleUrlChanged(String url) async {}

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
        break;
    }
  }

  renderLoading() {
    return new Center(
      child: new Container(
        width: 200.0,
        height: 200.0,
        padding: new EdgeInsets.all(4.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
            new Container(width: 10.0),
            new Container(
              child: new Text(R.current.loading),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    List<Widget> titleContent = [];
    titleContent.add(
      Text(
        widget.title,
        style: TextStyle(color: Colors.white),
      ),
    );
    if (loading) {
      titleContent.add(CupertinoActivityIndicator());
    }
    titleContent.add(Container(width: 50.0));

    return new WebviewScaffold(
      url: initUrl,
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
        actions: <Widget>[
          Container(
            width: 50,
            child: InkWell(
              onTap: () async {
                String url = widget.url;
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
              child: Icon(Icons.open_in_new, color: Colors.white),
            ),
          ),
        ],
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
      initialChild: renderLoading(),
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
