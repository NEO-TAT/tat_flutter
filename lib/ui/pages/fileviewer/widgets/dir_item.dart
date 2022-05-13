// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:io';

import 'package:flutter/material.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:path/path.dart';

import 'dir_popup.dart';

class DirectoryItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function tap;
  final Function popTap;

  const DirectoryItem({
    Key key,
    @required this.file,
    @required this.tap,
    @required this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: tap,
        contentPadding: const EdgeInsets.all(0),
        leading: const SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: Icon(
              FeatherIcons.folder,
            ),
          ),
        ),
        title: Text(
          basename(file.path),
          style: const TextStyle(
            fontSize: 14,
          ),
          maxLines: 2,
        ),
        trailing: popTap == null ? null : DirPopup(path: file.path, popTap: popTap),
      );
}
