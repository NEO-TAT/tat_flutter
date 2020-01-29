import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
part 'CourseDetailJson.g.dart';

@JsonSerializable()
class CourseDetailJson{
  String courseName;
  String courseId;
  String courseHref;
  List<String> teacherName;
  CourseSemesterJson courseSemester;
  List<List<CourseTimeJson>> courseTime; //Sunday Monday Tuesday Wednesday Thursday Friday Saturday

  CourseDetailJson({this.courseName, this.courseId, this.courseHref, this.teacherName, this.courseTime});

  String toString() {
    return sprintf( "%s \n %s \n %s \n %s \n %s \n" , [courseName , courseId , courseHref , teacherName.toString() , courseTime.toString() ]);
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
    //return sprintf( "%s" , [time]);
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
    //return sprintf( "%s" , [time]);
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


}