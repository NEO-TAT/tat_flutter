import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'course_class_json.g.dart';

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
      {this.name, this.href, this.id, this.credits, this.hours, this.stage, this.note, this.time, this.scheduleHref}) {
    name = JsonInit.stringInit(name);
    id = JsonInit.stringInit(id);
    href = JsonInit.stringInit(href);
    note = JsonInit.stringInit(note);
    stage = JsonInit.stringInit(stage);
    credits = JsonInit.stringInit(credits);
    hours = JsonInit.stringInit(hours);
    scheduleHref = JsonInit.stringInit(scheduleHref);
    time = time ?? {};
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
        "name    :%s \nid      :%s \nhref    :%s \nstage   :%s \ncredits :%s \nhours   :%s \nscheduleHref   :%s \nnote    :%s \n",
        [name, id, href, stage, credits, hours, scheduleHref, note]);
  }

  factory CourseMainJson.fromJson(Map<String, dynamic> json) => _$CourseMainJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseMainJsonToJson(this);
}

@JsonSerializable()
class CourseExtraJson {
  String id;
  String name;
  String href; //課程名稱用於取得英文
  String category; //類別 (必修...)
  String selectNumber; //選課人數
  String withdrawNumber; //徹選人數
  String openClass; //開課班級(計算學分用)

  CourseExtraJson({this.name, this.category, this.selectNumber, this.withdrawNumber, this.href}) {
    id = JsonInit.stringInit(id);
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
    category = JsonInit.stringInit(category);
    selectNumber = JsonInit.stringInit(selectNumber);
    withdrawNumber = JsonInit.stringInit(withdrawNumber);
    openClass = JsonInit.stringInit(openClass);
  }

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
        "id             :%s \nname           :%s \ncategory       :%s \nselectNumber   :%s \nwithdrawNumber :%s \nopenClass :%s \n",
        [id, name, category, selectNumber, withdrawNumber, openClass]);
  }

  factory CourseExtraJson.fromJson(Map<String, dynamic> json) => _$CourseExtraJsonFromJson(json);

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
    return sprintf("name : %s \n" "href : %s \n", [name, href]);
  }

  factory ClassJson.fromJson(Map<String, dynamic> json) => _$ClassJsonFromJson(json);

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
    return sprintf("name    : %s \nhref    : %s \nmainUse : %s \n", [name, href, mainUse.toString()]);
  }

  factory ClassroomJson.fromJson(Map<String, dynamic> json) => _$ClassroomJsonFromJson(json);

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
    return sprintf("name : %s \n" "href : %s \n", [name, href]);
  }

  factory TeacherJson.fromJson(Map<String, dynamic> json) => _$TeacherJsonFromJson(json);

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

  factory SemesterJson.fromJson(Map<String, dynamic> json) => _$SemesterJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterJsonToJson(this);

  bool get isEmpty {
    return year.isEmpty && semester.isEmpty;
  }

  @override
  String toString() {
    return sprintf("year     : %s \n" "semester : %s \n", [year, semester]);
  }

  @override
  bool operator ==(dynamic other) {
    return (int.parse(other.semester) == int.parse(semester) &&
        int.parse(other.year) == int.parse(year) &&
        other is SemesterJson);
  }

  @override
  int get hashCode => Object.hashAll([semester.hashCode, year.hashCode]);
}

@JsonSerializable()
class ClassmateJson {
  String className; //電子一甲
  String studentEnglishName;
  String studentName;
  String studentId;
  String href;
  bool isSelect; //是否撤選

  ClassmateJson({this.className, this.studentEnglishName, this.studentName, this.studentId, this.isSelect, this.href}) {
    className = JsonInit.stringInit(className);
    studentEnglishName = JsonInit.stringInit(studentEnglishName);
    studentName = JsonInit.stringInit(studentName);
    studentId = JsonInit.stringInit(studentId);
    href = JsonInit.stringInit(href);
    isSelect = isSelect ?? false;
  }

  bool get isEmpty {
    return className.isEmpty && studentEnglishName.isEmpty && studentName.isEmpty && studentId.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "className           : %s \nstudentEnglishName  : %s \nstudentName         : %s \nstudentId           : %s \nhref                : %s \nisSelect            : %s \n",
        [className, studentEnglishName, studentName, studentId, href, isSelect.toString()]);
  }

  String getName() {
    String name;
    if (LanguageUtil.getLangIndex() == LangEnum.en) {
      name = studentEnglishName;
    }
    name = name ?? studentName;
    name = (name.contains(RegExp(r"\w"))) ? name : studentName;
    return name;
  }

  factory ClassmateJson.fromJson(Map<String, dynamic> json) => _$ClassmateJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassmateJsonToJson(this);
}
