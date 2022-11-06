import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/util/file_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';

import 'file_icon.dart';
import 'file_popup.dart';

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final void Function(int) popTap;

  const FileItem({
    super.key,
    required this.file,
    required this.popTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => OpenFilex.open(file.path),
        contentPadding: const EdgeInsets.all(0),
        leading: FileIcon(
          file: file,
        ),
        title: Text(
          basename(file.path),
          style: const TextStyle(
            fontSize: 14,
          ),
          maxLines: 2,
        ),
        subtitle: Text(
          "${FileUtils.formatBytes(File(file.path).lengthSync(), 2)},"
          "${FileUtils.formatTime(File(file.path).lastModifiedSync().toIso8601String())}",
        ),
        trailing: FilePopup(
          path: file.path,
          popTap: popTap,
        ),
      );
}
