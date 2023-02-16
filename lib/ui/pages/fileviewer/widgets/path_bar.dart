import 'package:flutter/material.dart';

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  const PathBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
