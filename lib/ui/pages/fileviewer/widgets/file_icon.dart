import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
    final _extension = extension(f.path).toLowerCase();
    final mimeType = mime(basename(file.path).toLowerCase());
    final type = mimeType == null ? "" : mimeType.split("/")[0];
    if (_extension == ".apk") {
      return Icon(
        Icons.android,
        color: Colors.green,
      );
    } else if (_extension == ".crdownload") {
      return Icon(
        Feather.download,
        color: Colors.lightBlue,
      );
    } else if (_extension == ".zip" || _extension.contains("tar")) {
      return Icon(
        Feather.archive,
      );
    } else if (_extension == ".epub" || _extension == ".pdf" || _extension == ".mobi") {
      return Icon(
        Feather.file_text,
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
            return Icon(
              Feather.music,
              color: Colors.blue,
            );
          }
          break;

        case "text":
          {
            return Icon(
              Feather.file_text,
              color: Colors.orangeAccent,
            );
          }
          break;

        default:
          {
            return Icon(
              Feather.file,
            );
          }
          break;
      }
    }
  }
}
