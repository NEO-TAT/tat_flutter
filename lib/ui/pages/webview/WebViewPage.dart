import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPage({this.title, this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  Future<bool> setCookies() async {
    final cookies = cookieJar.loadForRequest(Uri.parse(widget.url));
    for (var cookie in cookies) {
      await cookieManager.setCookie(
        url: widget.url,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path,
        maxAge: cookie.maxAge,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<bool>(
        future: setCookies(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ),
                    Expanded(
                      child: Container(
                        child: InAppWebView(
                          initialUrl: widget.url,
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              debuggingEnabled: true,
                            ),
                          ),
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            webView = controller;
                          },
                          onLoadStart:
                              (InAppWebViewController controller, String url) {
                            setState(() {
                              this.url = url;
                            });
                          },
                          onLoadStop: (InAppWebViewController controller,
                              String url) async {
                            setState(
                              () {
                                this.url = url;
                              },
                            );
                          },
                          onProgressChanged: (InAppWebViewController controller,
                              int progress) {
                            setState(
                              () {
                                this.progress = progress / 100;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Icon(Icons.arrow_back),
                          onPressed: () async {
                            if (webView != null) {
                              await webView.goBack();
                            }
                          },
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Icon(Icons.arrow_forward),
                          onPressed: () async {
                            if (webView != null) {
                              await webView.goForward();
                            }
                          },
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Icon(Icons.refresh),
                          onPressed: () async {
                            if (webView != null) {
                              await webView.reload();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
