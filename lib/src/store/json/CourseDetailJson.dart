import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
part 'CourseDetailJson.g.dart';

@JsonSerializable()
class CourseDetail{
  String courseName;
  String courseId;
  String courseHref;
  List<String> teacherName;
  List<List<CourseTime>> courseTime; //Sunday Monday Tuesday Wednesday Thursday Friday Saturday

  CourseDetail({this.courseName, this.courseId, this.courseHref, this.teacherName, this.courseTime});

  String toString() {
    return sprintf( "%s \n %s \n %s \n %s \n %s \n" , [courseName , courseId , courseHref , teacherName.toString() , courseTime.toString() ]);
  }

  factory CourseDetail.fromJson(Map<String, dynamic> json) => _$CourseDetailFromJson(json);
  Map<String, dynamic> toJson() => _$CourseDetailToJson(this);


}


@JsonSerializable()
class CourseTime{
  String time;
  CourseClassroom classroom;

  CourseTime( {this.time, this.classroom} );
  @override
  String toString() {
    //return sprintf( "%s" , [time]);
    return sprintf( "\n %s %s" , [time  , classroom.toString() ]);
  }

  factory CourseTime.fromJson(Map<String, dynamic> json) => _$CourseTimeFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTimeToJson(this);
}

@JsonSerializable()
class CourseClassroom{
  String name;
  String href;

  CourseClassroom( {this.name , this.href} );

  @override
  String toString() {
    //return sprintf( "%s" , [time]);
    return sprintf( "%s %s" , [name , href]);
  }

  factory CourseClassroom.fromJson(Map<String, dynamic> json) => _$CourseClassroomFromJson(json);
  Map<String, dynamic> toJson() => _$CourseClassroomToJson(this);

}