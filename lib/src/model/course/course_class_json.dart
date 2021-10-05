import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/util/language_utils.dart';

part 'course_class_json.g.dart';

@JsonSerializable()
class CourseMainJson {
  late final String name;
  late final String id;
  late final String href;
  late final String note;
  late final String stage;
  late final String credits;
  late final String hours;
  late final String scheduleHref;
  late final bool isSelect;
  Map<Day, String>? time = Map();

  CourseMainJson({
    this.name = "",
    this.href = "",
    this.id = "",
    this.credits = "",
    this.hours = "",
    this.stage = "",
    this.note = "",
    this.time,
    this.scheduleHref = "",
    this.isSelect = true,
  });

  bool get isEmpty {
    return name.isEmpty &&
        href.isEmpty &&
        note.isEmpty &&
        stage.isEmpty &&
        credits.isEmpty &&
        hours.isEmpty &&
        scheduleHref.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
      "name    :%s \n" +
          "id      :%s \n" +
          "href    :%s \n" +
          "stage   :%s \n" +
          "credits :%s \n" +
          "hours   :%s \n" +
          "scheduleHref   :%s \n" +
          "note    :%s \n",
      [
        name,
        id,
        href,
        stage,
        credits,
        hours,
        scheduleHref,
        note,
      ],
    );
  }

  factory CourseMainJson.fromJson(Map<String, dynamic> json) =>
      _$CourseMainJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseMainJsonToJson(this);
}

@JsonSerializable()
class CourseExtraJson {
  late final String name;
  late final String href;
  late final String category;
  late final String selectNumber;
  late final String withdrawNumber;
  late final String id;
  late final String openClass;

  CourseExtraJson({
    this.name = "",
    this.category = "",
    this.selectNumber = "",
    this.withdrawNumber = "",
    this.href = "",
    this.id = "",
    this.openClass = "",
  });

  bool get isEmpty {
    return id.isEmpty &&
        name.isEmpty &&
        category.isEmpty &&
        selectNumber.isEmpty &&
        withdrawNumber.isEmpty &&
        openClass.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
      "id             :%s \n" +
          "name           :%s \n" +
          "category       :%s \n" +
          "selectNumber   :%s \n" +
          "withdrawNumber :%s \n" +
          "openClass :%s \n",
      [
        id,
        name,
        category,
        selectNumber,
        withdrawNumber,
        openClass,
      ],
    );
  }

  factory CourseExtraJson.fromJson(Map<String, dynamic> json) =>
      _$CourseExtraJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseExtraJsonToJson(this);
}

@JsonSerializable()
class ClassJson {
  late final String name;
  late final String href;

  ClassJson({this.name = "", this.href = ""});

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name : %s \n" + "href : %s \n", [name, href]);
  }

  factory ClassJson.fromJson(Map<String, dynamic> json) =>
      _$ClassJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassJsonToJson(this);
}

@JsonSerializable()
class ClassroomJson {
  late final String name;
  late final String href;
  late final bool mainUse;

  ClassroomJson({this.name = "", this.href = "", this.mainUse = false});

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
      "name    : %s \n" + "href    : %s \n" + "mainUse : %s \n",
      [
        name,
        href,
        mainUse.toString(),
      ],
    );
  }

  factory ClassroomJson.fromJson(Map<String, dynamic> json) =>
      _$ClassroomJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomJsonToJson(this);
}

@JsonSerializable()
class TeacherJson {
  late final String name;
  late final String href;

  TeacherJson({this.name = "", this.href = ""});

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name : %s \n" + "href : %s \n", [name, href]);
  }

  factory TeacherJson.fromJson(Map<String, dynamic> json) =>
      _$TeacherJsonFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherJsonToJson(this);
}

@JsonSerializable()
class SemesterJson {
  late final String year;
  late final String semester;

  SemesterJson({this.year = "", this.semester = ""});

  factory SemesterJson.fromJson(Map<String, dynamic> json) =>
      _$SemesterJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterJsonToJson(this);

  bool get isEmpty {
    return year.isEmpty && semester.isEmpty;
  }

  @override
  String toString() {
    return sprintf("year     : %s \n" + "semester : %s \n", [year, semester]);
  }

  @override
  bool operator ==(dynamic o) {
    return (int.parse(o.semester) == int.parse(semester) &&
        int.parse(o.year) == int.parse(year) &&
        o is SemesterJson);
  }

  int get hashCode => Object.hash(semester.hashCode, year.hashCode);
}

@JsonSerializable()
class ClassmateJson {
  late final String className;
  late final String studentEnglishName;
  late final String studentName;
  late final String studentId;
  late final String href;
  late final bool isSelect;

  ClassmateJson({
    this.className = "",
    this.studentEnglishName = "",
    this.studentName = "",
    this.studentId = "",
    this.isSelect = false,
    this.href = "",
  });

  bool get isEmpty {
    return className.isEmpty &&
        studentEnglishName.isEmpty &&
        studentName.isEmpty &&
        studentId.isEmpty &&
        href.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
      "className           : %s \n" +
          "studentEnglishName  : %s \n" +
          "studentName         : %s \n" +
          "studentId           : %s \n" +
          "href                : %s \n" +
          "isSelect            : %s \n",
      [
        className,
        studentEnglishName,
        studentName,
        studentId,
        href,
        isSelect.toString(),
      ],
    );
  }

  String getName() {
    late final String? name;
    if (LanguageUtils.getLangIndex() == LangEnum.en) {
      name = studentEnglishName;
    }

    name ??= studentName;
    name = (name.contains(RegExp(r"\w"))) ? name : studentName;

    return name;
  }

  factory ClassmateJson.fromJson(Map<String, dynamic> json) =>
      _$ClassmateJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassmateJsonToJson(this);
}
