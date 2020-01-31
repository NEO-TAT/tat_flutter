import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:json_annotation/json_annotation.dart';

part 'CourseInfoJson.g.dart';

@JsonSerializable()
class CourseInfoJson {  //點入課程使用
  SemesterJson courseSemester;
  CourseDetailJson courseDetail;
  List<ClassmateJson> classmate;
  List<TeacherJson> teacher;
  List<ClassroomJson> classroom;
  List<CourseJson> openClass; //開課班級

  CourseInfoJson({this.courseSemester ,  this.courseDetail  , this.classmate , this.teacher , this.classroom , this.openClass }){
    courseSemester = (  courseSemester != null )? courseSemester : SemesterJson();
    courseDetail   = (  courseDetail   != null )? courseDetail   : CourseDetailJson();
    classmate      = (  classmate      != null )? classmate      : List();
    teacher        = (  teacher        != null )? teacher        : List();
    classroom      = (  classroom      != null )? classroom      : List();
    openClass      = ( openClass       != null )? openClass      : List();
  }

  factory CourseInfoJson.fromJson(Map<String, dynamic> json) => _$CourseInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseInfoJsonToJson(this);

}

@JsonSerializable()
class CourseDetailJson {
  CourseJson course;
  String stage ;     //階段
  String credits;    //學分
  String hours;      //時數
  String category;   //類別 (必修...)
  String selectNumber;    //選課人數
  String withdrawNumber;  //徹選人數


  CourseDetailJson({this.course ,  this.stage  , this.credits , this.hours , this.category  , this.selectNumber , this.withdrawNumber  }){
    course         = ( course     != null ) ? course    : CourseJson();

    stage          = JsonInit.stringInit(stage);
    credits        = JsonInit.stringInit(credits);
    hours          = JsonInit.stringInit(hours);
    category       = JsonInit.stringInit(category);
    selectNumber   = JsonInit.stringInit(selectNumber);
    withdrawNumber = JsonInit.stringInit(withdrawNumber);
  }

  factory CourseDetailJson.fromJson(Map<String, dynamic> json) => _$CourseDetailJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseDetailJsonToJson(this);

}


@JsonSerializable()
class ClassmateJson {
  String className;  //電子一甲
  String studentEnglishName;
  String studentName;
  String studentId;
  bool isSelect;     //是否撤選

  ClassmateJson({this.className , this.studentEnglishName , this.studentName , this.studentId , this.isSelect }){
    className          = JsonInit.stringInit(className);
    studentEnglishName = JsonInit.stringInit(studentEnglishName);
    studentName        = JsonInit.stringInit(studentName);
    studentId          = JsonInit.stringInit(studentId);
    isSelect           = ( isSelect != null ) ? isSelect : false;
  }

  factory ClassmateJson.fromJson(Map<String, dynamic> json) => _$ClassmateJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ClassmateJsonToJson(this);

}