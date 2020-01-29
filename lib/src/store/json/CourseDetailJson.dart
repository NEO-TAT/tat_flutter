import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';

import 'StringInit.dart';
import 'UserDataJson.dart';
part 'CourseDetailJson.g.dart';


@JsonSerializable()
class CourseTableJsonList {
  List<CourseTableJson> courseTableList;

  CourseTableJsonList({this.courseTableList});

  factory CourseTableJsonList.fromJson(Map<String, dynamic> json) => _$CourseTableJsonListFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableJsonListToJson(this);

}

@JsonSerializable()
class CourseSemesterJsonList {
  List<CourseSemesterJson> courseSemesterList;

  CourseSemesterJsonList({this.courseSemesterList});

  factory CourseSemesterJsonList.fromJson(Map<String, dynamic> json) => _$CourseSemesterJsonListFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSemesterJsonListToJson(this);

}


@JsonSerializable()
class CourseTableJson {
  CourseSemesterJson courseSemester;
  List<CourseDetailJson> courseDetail;

  CourseTableJson({this.courseSemester, this.courseDetail}){
    this.courseDetail = ( this.courseDetail != null )?this.courseDetail : List();
  }

  factory CourseTableJson.fromJson(Map<String, dynamic> json) => _$CourseTableJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableJsonToJson(this);

  String toString() {
    return sprintf(
        " courseSemester  :%s \n "
        , [courseSemester.toString() ]);

  }
}



@JsonSerializable()
class CourseDetailJson{
  String courseName;
  String courseId;
  String courseHref;
  List<String> teacherName;
  List<List<CourseTimeJson>> courseTime; //Sunday Monday Tuesday Wednesday Thursday Friday Saturday

  CourseDetailJson({this.courseName, this.courseId, this.courseHref, this.teacherName, this.courseTime}){
    this.courseName = StringInit.init(this.courseName);
    this.courseId = StringInit.init(this.courseId);
    this.courseHref = StringInit.init(this.courseHref);
    this.teacherName = (teacherName != null) ? this.teacherName : List();
  }

  String toString() {
    return sprintf(
            " courseName  :%s \n " +
            " courseId    :%s \n " +
            " courseHref  :%s \n " +
            " teacherName :%s \n " +
            " courseTime : %s \n"
            , [courseName , courseId , courseHref , teacherName.toString() , courseTime.toString()]);

  }

  factory CourseDetailJson.fromJson(Map<String, dynamic> json) => _$CourseDetailJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseDetailJsonToJson(this);


}


@JsonSerializable()
class CourseTimeJson{
  String time;
  CourseClassroomJson classroom;

  CourseTimeJson( {this.time, this.classroom} );
  @override
  String toString() {
    return sprintf( "\n %s %s" , [time  , classroom.toString() ]);
  }

  factory CourseTimeJson.fromJson(Map<String, dynamic> json) => _$CourseTimeJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTimeJsonToJson(this);
}

@JsonSerializable()
class CourseClassroomJson{
  String name;
  String href;

  CourseClassroomJson( {this.name , this.href} );

  @override
  String toString() {
    return sprintf( "%s %s" , [name , href]);
  }

  factory CourseClassroomJson.fromJson(Map<String, dynamic> json) => _$CourseClassroomJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseClassroomJsonToJson(this);

}


@JsonSerializable()
class CourseSemesterJson {
  String year;
  String semester;
  CourseSemesterJson( {this.year , this.semester} );

  factory CourseSemesterJson.fromJson(Map<String, dynamic> json) => _$CourseSemesterJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSemesterJsonToJson(this);

  @override
  String toString() {
    return sprintf( "year: %s  semester: %s" , [year , semester]);
  }

  @override
  bool operator ==(dynamic  o) {
    return (o.semester == semester && o.year == year && o is CourseSemesterJson );
  }

  int get hashCode => hash2(semester.hashCode, year.hashCode);

}