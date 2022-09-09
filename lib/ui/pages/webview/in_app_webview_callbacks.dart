import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef OnProgressChanged = void Function(InAppWebViewController controller, int progress);
typedef OnTitleChanged = void Function(InAppWebViewController controller, String title);

/// Signature for when deciding whether the current page is allowed to be overridden to load with a given request URL.
///
/// Returns [NavigationActionPolicy.ALLOW] if the given request URL is allowed to load.
/// Returns [NavigationActionPolicy.CANCEL] if the given request URL is NOT allowed to load
/// Returns `null` if this method doesn't want to involve a policy decision and leaves the decision for others to make.
typedef OnShouldOverrideUrlLoading = Future<NavigationActionPolicy> Function(
  InAppWebViewController controller,
  NavigationAction action,
);
typedef OnShouldOverrideUrlLoadingExternalUrlHandler = Future<NavigationActionPolicy> Function(
  InAppWebViewController controller,
  NavigationAction navigationAction,
);
typedef OnUrlLoadingOverriddenByExternalUrl = void Function(String url);
typedef OnUpdateVisitedHistory = void Function(InAppWebViewController controller, Uri url, bool androidIsReload);

/// A callback which is called when [OnUpdateVisitedHistory] is called.
typedef ShouldGoBackOnUpdateVisitedHistoryAndDispatchUrl = Function(Uri url);
typedef DidUpdateVisitedHistory = void Function(InAppWebViewController controller, Uri url);
typedef OnLoadStart = void Function(InAppWebViewController controller, Uri url);
typedef OnLoadStop = void Function(InAppWebViewController controller, Uri url);
typedef OnLoadError = void Function(InAppWebViewController controller, Uri url, int code, String message);
typedef OnPageCommitVisible = void Function(InAppWebViewController controller, Uri url);
typedef HandleExternalMerchantPage = Future<NavigationActionPolicy> Function(Uri url);
typedef OnNavigateToUrl = void Function(String);

/// Signature for callbacks that report that an [InAppWebView] is created.
typedef InAppWebViewCreatedCallback = void Function(InAppWebViewController controller);
