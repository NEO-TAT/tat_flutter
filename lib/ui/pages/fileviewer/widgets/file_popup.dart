import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';

class FilePopup extends StatelessWidget {
  final String path;
  final void Function(int) popTap;

  const FilePopup({
    super.key,
    required this.path,
    required this.popTap,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
        onSelected: popTap,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 0,
            child: Text(
              R.current.rename,
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Text(
              R.current.delete,
            ),
          ),
        ],
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).textTheme.headline6?.color,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        offset: const Offset(0, 30),
      );
}
