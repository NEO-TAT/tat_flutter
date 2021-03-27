import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/util/open_utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final Uri url;
  final String title;
  final bool openWithExternalWebView;

  WebViewPage({this.title, this.url, this.openWithExternalWebView});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  InAppWebViewController webView;
  Uri url = Uri();
  double progress = 0;

  Future<bool> setCookies() async {
    final cookies = await cookieJar.loadForRequest(widget.url);
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
        actions: <Widget>[
          Container(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView.goBack();
                }
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Container(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView.goForward();
                }
              },
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
          Container(
            width: 50,
            child: InkWell(
              onTap: () async {
                if (webView != null) {
                  await webView.reload();
                }
              },
              child: Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          if (widget.openWithExternalWebView)
            Container(
              width: 50,
              child: InkWell(
                onTap: () async {
                  OpenUtils.launchURL(widget.url.toString());
                },
                child: Icon(Icons.open_in_new, color: Colors.white),
              ),
            ),
        ],
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
                          initialUrlRequest: URLRequest(url: widget.url),
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(),
                          ),
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            webView = controller;
                          },
                          onLoadStart:
                              (InAppWebViewController controller, Uri url) {
                            setState(() {
                              this.url = url;
                            });
                          },
                          onLoadStop: (InAppWebViewController controller,
                              Uri url) async {
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
