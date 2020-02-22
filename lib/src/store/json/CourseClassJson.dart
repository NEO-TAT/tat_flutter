import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';
import '../JsonInit.dart';
import 'CourseTableJson.dart';

part 'CourseClassJson.g.dart';

@JsonSerializable()
class CourseMainJson {
  String name;
  String id;
  String href;
  String note; //備註
  String stage; //階段
  String credits; //學分
  String hours; //時數
  String scheduleHref; // 教學進度大綱
  Map<Day, String> time; //時間

  CourseMainJson(
      {this.name,
      this.href,
      this.id,
      this.credits,
      this.hours,
      this.stage,
      this.note,
      this.time,
      this.scheduleHref}) {
    name = JsonInit.stringInit(name);
    id = JsonInit.stringInit(id);
    href = JsonInit.stringInit(href);
    note = JsonInit.stringInit(note);
    stage = JsonInit.stringInit(stage);
    credits = JsonInit.stringInit(credits);
    hours = JsonInit.stringInit(hours);
    scheduleHref = JsonInit.stringInit(scheduleHref);
    time = time ?? Map();
  }

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
        [name, id, href, stage, credits, hours, scheduleHref, note]);
  }

  factory CourseMainJson.fromJson(Map<String, dynamic> json) =>
      _$CourseMainJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseMainJsonToJson(this);
}

@JsonSerializable()
class CourseExtraJson {
  String id;
  String name;
  String category; //類別 (必修...)
  String selectNumber; //選課人數
  String withdrawNumber; //徹選人數

  CourseExtraJson(
      {this.name, this.category, this.selectNumber, this.withdrawNumber}) {
    id = JsonInit.stringInit(id);
    name = JsonInit.stringInit(name);
    category = JsonInit.stringInit(category);
    selectNumber = JsonInit.stringInit(selectNumber);
    withdrawNumber = JsonInit.stringInit(withdrawNumber);
  }

  bool get isEmpty {
    return id.isEmpty &&
        name.isEmpty &&
        category.isEmpty &&
        selectNumber.isEmpty &&
        withdrawNumber.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "id             :%s \n" +
            "name           :%s \n" +
            "category       :%s \n" +
            "selectNumber   :%s \n" +
            "withdrawNumber :%s \n",
        [id, name, category, selectNumber, withdrawNumber]);
  }

  factory CourseExtraJson.fromJson(Map<String, dynamic> json) =>
      _$CourseExtraJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseExtraJsonToJson(this);
}

@JsonSerializable()
class ClassJson {
  String name;
  String href;

  ClassJson({this.name, this.href}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }

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
  String name;
  String href;
  bool mainUse;

  ClassroomJson({this.name, this.href, this.mainUse}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
    mainUse = mainUse ?? false;
  }

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name    : %s \n" + "href    : %s \n" + "mainUse : %s \n",
        [name, href, mainUse.toString()]);
  }

  factory ClassroomJson.fromJson(Map<String, dynamic> json) =>
      _$ClassroomJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ClassroomJsonToJson(this);
}

@JsonSerializable()
class TeacherJson {
  String name;
  String href;

  TeacherJson({this.name, this.href}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }

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
  String year;
  String semester;
  SemesterJson({this.year, this.semester}) {
    year = JsonInit.stringInit(year);
    semester = JsonInit.stringInit(semester);
  }

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

  int get hashCode => hash2(semester.hashCode, year.hashCode);
}

@JsonSerializable()
class ClassmateJson {
  String className; //電子一甲
  String studentEnglishName;
  String studentName;
  String studentId;
  String href;
  bool isSelect; //是否撤選

  ClassmateJson(
      {this.className,
      this.studentEnglishName,
      this.studentName,
      this.studentId,
      this.isSelect,
      this.href}) {
    className = JsonInit.stringInit(className);
    studentEnglishName = JsonInit.stringInit(studentEnglishName);
    studentName = JsonInit.stringInit(studentName);
    studentId = JsonInit.stringInit(studentId);
    href = JsonInit.stringInit(href);
    isSelect = isSelect ?? false;
  }

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
          isSelect.toString()
        ]);
  }

  factory ClassmateJson.fromJson(Map<String, dynamic> json) =>
      _$ClassmateJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ClassmateJsonToJson(this);
}
