import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;

  FileIcon({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    File f = File(file.path);
    String _extension = extension(f.path).toLowerCase();
    String mimeType = mime(basename(file.path).toLowerCase());
    String type = mimeType == null ? "" : mimeType.split("/")[0];
    if (_extension == ".apk") {
      return Icon(
        Icons.android,
        color: Colors.green,
      );
    } else if (_extension == ".crdownload") {
      return Icon(
        Icons.file_download,
        color: Colors.lightBlue,
      );
    } else if (_extension == ".zip" || _extension.contains("tar")) {
      return Icon(
        FontAwesome5.file_archive,
      );
    } else if (_extension == ".epub" ||
        _extension == ".pdf" ||
        _extension == ".mobi") {
      return Icon(
        FontAwesome5.file_alt,
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
/*
        case "video":
          {
//            return Image.file(
//              File(),
//              height: 40,
//              width: 40,
//            );
            return Container(
              height: 40,
              width: 40,
              child: VideoThumbnail(
                path: file.path,
              ),
            );
          }
          break;
 */

        case "audio":
          {
            return Icon(
              FontAwesome5.file_audio,
              color: Colors.blue,
            );
          }
          break;

        case "text":
          {
            return Icon(
              FontAwesome5.file_alt,
              color: Colors.orangeAccent,
            );
          }
          break;

        default:
          {
            return Icon(
              FontAwesome5.file,
            );
          }
          break;
      }
    }
  }
}
