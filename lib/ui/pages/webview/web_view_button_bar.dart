import 'package:flutter/material.dart';

/// A simple button action bar for the WebView use.
///
/// When any of onPressed callback is `null`, that button will be disabled.
class WebViewButtonBar extends StatelessWidget {
  const WebViewButtonBar({
    super.key,
    VoidCallback? onBackPressed,
    VoidCallback? onForwardPressed,
    VoidCallback? onRefreshPressed,
  })  : _onBackPressed = onBackPressed,
        _onForwardPressed = onForwardPressed,
        _onRefreshPressed = onRefreshPressed;

  final VoidCallback? _onBackPressed;
  final VoidCallback? _onForwardPressed;
  final VoidCallback? _onRefreshPressed;

  @override
  Widget build(BuildContext context) => ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          _ControlButton(icon: const Icon(Icons.arrow_back), onPressed: _onBackPressed),
          _ControlButton(icon: const Icon(Icons.arrow_forward), onPressed: _onForwardPressed),
          _ControlButton(icon: const Icon(Icons.refresh), onPressed: _onRefreshPressed),
        ],
      );
}

/// A rounded rectangle button for the [WebViewButtonBar] used.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required Icon icon,
    VoidCallback? onPressed,
  })  : _icon = icon,
        _onPressed = onPressed;

  final Icon _icon;
  final VoidCallback? _onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        onPressed: _onPressed,
        child: _icon,
      );
}
