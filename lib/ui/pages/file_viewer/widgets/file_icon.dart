import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;

  const FileIcon({
    Key? key,
    required this.file,
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
        Icons.insert_drive_file,
        color: Colors.lightBlue,
      );
    } else if (_extension == ".zip" || _extension.contains("tar")) {
      return Icon(
        Icons.archive,
      );
    } else if (_extension == ".epub" || _extension == ".pdf" || _extension == ".mobi") {
      return Icon(
        Icons.file_present,
        color: Colors.orangeAccent,
      );
    } else {
      switch (type) {
        case "image":
          return Image.file(
            File.fromRawPath(Uint8List.fromList(file.path.codeUnits)),
            height: 40,
            width: 40,
          );
        case "audio":
          return Icon(
            Icons.music_note,
            color: Colors.blue,
          );
        case "text":
          return Icon(
            Icons.insert_drive_file,
            color: Colors.orangeAccent,
          );
        default:
          return Icon(
            Icons.insert_drive_file,
          );
      }
    }
  }
}
