import 'dart:io';

import 'package:flutter/material.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;

  const FileIcon({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final f = File(file.path);
    final configuredExtension = extension(f.path).toLowerCase();
    final mimeType = mime(basename(file.path).toLowerCase());
    final type = mimeType == null ? "" : mimeType.split("/")[0];
    if (configuredExtension == ".apk") {
      return const Icon(
        Icons.android,
        color: Colors.green,
      );
    } else if (configuredExtension == ".crdownload") {
      return const Icon(
        FeatherIcons.download,
        color: Colors.lightBlue,
      );
    } else if (configuredExtension == ".zip" || configuredExtension.contains("tar")) {
      return const Icon(
        FeatherIcons.archive,
      );
    } else if (configuredExtension == ".epub" || configuredExtension == ".pdf" || configuredExtension == ".mobi") {
      return const Icon(
        FeatherIcons.fileText,
        color: Colors.orangeAccent,
      );
    } else {
      switch (type) {
        case "image":
          {
            return Image.file(
              file,
              height: 40,
              width: 40,
            );
          }
          break;
        case "audio":
          {
            return const Icon(
              FeatherIcons.music,
              color: Colors.blue,
            );
          }
          break;

        case "text":
          {
            return const Icon(
              FeatherIcons.fileText,
              color: Colors.orangeAccent,
            );
          }
          break;

        default:
          {
            return const Icon(
              FeatherIcons.file,
            );
          }
          break;
      }
    }
  }
}
