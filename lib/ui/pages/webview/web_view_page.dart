// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({Key key, this.title, this.url}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  InAppWebViewController webView;
  Uri url = Uri.parse('');
  double progress = 0;

  Future<bool> setCookies() async {
    final cookies = await cookieJar.loadForRequest(Uri.parse(widget.url));
    for (final cookie in cookies) {
      await cookieManager.setCookie(
        url: Uri.parse(widget.url),
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
              child: Column(
                children: <Widget>[
                  Container(
                    child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
                  ),
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webView = controller;
                      },
                      onLoadStart: (InAppWebViewController controller, Uri url) {
                        setState(() {
                          this.url = url;
                        });
                      },
                      onLoadStop: (InAppWebViewController controller, Uri url) async {
                        setState(
                          () {
                            this.url = url;
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
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back),
                        onPressed: () async {
                          if (webView != null) {
                            await webView.goBack();
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.arrow_forward),
                        onPressed: () async {
                          if (webView != null) {
                            await webView.goForward();
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.refresh),
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
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
