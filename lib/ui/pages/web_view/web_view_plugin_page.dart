import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/connector/core/connector_parameter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPluginPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPluginPage({required this.title, required this.url});

  @override
  _WebViewPluginPageState createState() => _WebViewPluginPageState();
}

class _WebViewPluginPageState extends State<WebViewPluginPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late String initUrl;
  bool loading = true;
  late StreamSubscription<String> onUrlChanged;
  late StreamSubscription<WebViewStateChanged> onStateChanged;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    onStateChanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
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
    return Center(
      child: Container(
        width: 200.0,
        height: 200.0,
        padding: EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
            Container(width: 10.0),
            Container(
              child: Text(R.current.loading),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<Widget> titleContent = [];
    titleContent.add(
      Expanded(
        child: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    if (loading) {
      titleContent.add(CupertinoActivityIndicator());
    }
    titleContent.add(Container(width: 50.0));

    return WebviewScaffold(
      url: initUrl,
      userAgent: presetUserAgent,
      key: scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: titleContent,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            width: 50,
            child: InkWell(
              onTap: () async {
                final url = widget.url;
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
