// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/model/json_init.dart';
import 'package:intl/intl.dart';

enum CourseFileType { pdf, word, powerPoint, excel, rar, link, unknown }

class CourseFileJson {
  String name;
  DateTime time;
  List<FileType> fileType;

  CourseFileJson({this.name, this.fileType, this.time}) {
    name = JsonInit.stringInit(name);
    fileType = fileType ?? [];
    time = time ?? DateTime.now();
  }

  String get timeString {
    var formatter = DateFormat.yMd();
    String formatted = formatter.format(time);
    return formatted;
  }
}

class FileType {
  CourseFileType type;
  String href;
  dynamic postData; //ISchoolPlus取得真實連結會使用

  FileType({this.type, this.href}) {
    type = type ?? CourseFileType.unknown;
    href = JsonInit.stringInit(href);
  }

  String get fileUrl {
    return href;
  }
}