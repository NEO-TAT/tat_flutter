import 'package:flutter/material.dart';

class HorizontalSideContainer extends StatelessWidget {
  const HorizontalSideContainer({
    super.key,
    required Size size,
    required double ratio,
    required Color color,
    Radius leftRadius = Radius.zero,
    Radius rightRadius = Radius.zero,
    EdgeInsetsGeometry? padding,
    Widget? content,
  })  : _size = size,
        _ratio = ratio,
        _color = color,
        _leftRadius = leftRadius,
        _rightRadius = rightRadius,
        _padding = padding,
        _child = content;

  final Size _size;
  final double _ratio;
  final Color _color;
  final Radius _leftRadius;
  final Radius _rightRadius;
  final EdgeInsetsGeometry? _padding;
  final Widget? _child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.horizontal(
      left: _leftRadius,
      right: _rightRadius,
    );
    return Material(
      borderRadius: borderRadius,
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        width: _size.width * _ratio,
        padding: _padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: _color,
        ),
        child: RepaintBoundary(
          child: _child,
        ),
      ),
    );
  }
}
