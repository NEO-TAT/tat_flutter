import 'package:intl/intl.dart';

enum CourseFileType { PDF, Word, PowerPoint, Excel, Rar, Link, Unknown }

class CourseFileJson {
  String name;
  DateTime? time = DateTime.now();
  List<FileType>? fileType = [];

  CourseFileJson({
    this.name = '',
    this.fileType,
    this.time,
  });

  String get timeString => DateFormat.yMd().format(time!);
}

class FileType {
  late final CourseFileType type;
  final String href;
  dynamic postData;

  FileType({
    this.type = CourseFileType.Unknown,
    this.href = '',
  });

  String get fileUrl => href;
}
