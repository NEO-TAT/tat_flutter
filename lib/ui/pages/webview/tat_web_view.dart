import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/webview/in_app_webview_callbacks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TATWebView extends StatelessWidget {
  const TATWebView({
    super.key,
    required Uri initialUrl,
    InAppWebViewCreatedCallback? onWebViewCreated,
  })  : _initialUrl = initialUrl,
        _onWebViewCreated = onWebViewCreated;

  final Uri _initialUrl;
  final InAppWebViewCreatedCallback? _onWebViewCreated;

  @override
  Widget build(BuildContext context) => InAppWebView(
        initialUrlRequest: URLRequest(url: _initialUrl),
        onWebViewCreated: _onWebViewCreated,
      );
}
