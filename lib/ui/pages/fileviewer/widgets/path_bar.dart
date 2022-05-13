// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  const PathBar({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}