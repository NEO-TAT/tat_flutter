import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children: const <Widget>[],
    this.trailing,
    this.initiallyExpanded: false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Widget? leading;
  final Widget title;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool? initiallyExpanded;

  @override
  AppExpansionTileState createState() => AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController? _controller;
  late final CurvedAnimation? _easeOutAnimation, _easeInAnimation;
  late final ColorTween _borderColor,
      _headerColor,
      _iconColor,
      _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeOut);
    _easeInAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _borderColor = ColorTween();
    _headerColor = ColorTween();
    _iconColor = ColorTween();
    _backgroundColor = ColorTween();

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller!.value = 1.0;
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded) {
          _controller!.forward();
        } else {
          _controller!.reverse().then<void>((_) {
            setState(() {});
          });
        }
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor =
        _borderColor.evaluate(_easeOutAnimation!) ?? Colors.transparent;
    final Color? titleColor = _headerColor.evaluate(_easeInAnimation!);

    return Container(
      decoration: BoxDecoration(
        color:
            _backgroundColor.evaluate(_easeOutAnimation!) ?? Colors.transparent,
        border: Border(
          top: BorderSide(color: borderSideColor),
          bottom: BorderSide(color: borderSideColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(
            data: IconThemeData(color: _iconColor.evaluate(_easeInAnimation!)),
            child: ListTile(
              onTap: toggle,
              leading: widget.leading,
              title: DefaultTextStyle(
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: titleColor,
                    ),
                child: widget.title,
              ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _easeInAnimation!.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.subtitle1!.color
      ..end = theme.colorScheme.secondary;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.colorScheme.secondary;
    _backgroundColor.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller!.isDismissed;
    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
