import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tat/src/connector/core/dio_connector.dart';

class WebViewPage extends StatefulWidget {
  final Uri url;
  final String title;

  const WebViewPage({required this.title, required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.dioInstance.cookiesManager;
  late InAppWebViewController? webView;
  late Uri url = Uri();
  double progress = 0;

  Future<bool> setCookies() async {
    final cookies = cookieJar.loadForRequest(widget.url);
    for (final cookie in await cookies) {
      await cookieManager.setCookie(
        url: widget.url,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path ?? '',
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
                  children: [
                    Container(
                      child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
                    ),
                    Expanded(
                      child: Container(
                        child: InAppWebView(
                          initialUrlRequest: URLRequest(url: widget.url),
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(),
                          ),
                          onWebViewCreated: (InAppWebViewController controller) {
                            webView = controller;
                          },
                          onLoadStart: (InAppWebViewController controller, Uri? url) {
                            setState(() {
                              this.url = url ?? Uri();
                            });
                          },
                          onLoadStop: (InAppWebViewController controller, Uri? url) async {
                            setState(
                              () {
                                this.url = url ?? Uri();
                              },
                            );
                          },
                          onProgressChanged: (InAppWebViewController controller, int progress) {
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Icon(Icons.arrow_back),
                          onPressed: () async {
                            if (webView != null) {
                              await webView!.goBack();
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Icon(Icons.arrow_forward),
                          onPressed: () async {
                            if (webView != null) {
                              await webView!.goForward();
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Icon(Icons.refresh),
                          onPressed: () async {
                            if (webView != null) {
                              await webView!.reload();
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
