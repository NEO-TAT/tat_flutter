// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/ui/pages/webview/tat_web_view.dart';
import 'package:flutter_app/ui/pages/webview/web_view_button_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required Uri initialUrl,
    String? title,
  })  : _initialUrl = initialUrl,
        _title = title;

  final Uri _initialUrl;
  final String? _title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  late final InAppWebViewController _controller;

  // A value shows the progress of page loading. Range from 0.0 to 1.0.
  double progress = 0;

  Future<void> setInitialCookies() async {
    final cookies = await cookieJar.loadForRequest(widget._initialUrl);

    for (final cookie in cookies) {
      await cookieManager.setCookie(
        url: widget._initialUrl,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path ?? '/',
        maxAge: cookie.maxAge,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
      );
    }
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
  }

  Widget _buildTATWebView() => TATWebView(
        initialUrl: widget._initialUrl,
        onWebViewCreated: _onWebViewCreated,
      );

  Widget _buildButtonBar() => WebViewButtonBar(
        onBackPressed: () => _controller.goBack(),
        onForwardPressed: () => _controller.goForward(),
        onRefreshPressed: () => _controller.reload(),
      );

  Widget _buildProgressBar() => SizedBox(
        child: progress < 1.0
            ? LinearProgressIndicator(
                value: progress,
                color: Colors.greenAccent,
              )
            : const SizedBox.shrink(),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget._title ?? ''),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: FutureBuilder(
                  future: setInitialCookies(),
                  builder: (context, snapshot) => _buildTATWebView(),
                ),
              ),
              _buildButtonBar(),
            ],
          ),
        ),
      );
}
