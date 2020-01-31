import 'package:flutter_app/debug/log/Log.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';
import '../JsonInit.dart';
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
  List<SemesterJson> courseSemesterList;

  CourseSemesterJsonList({this.courseSemesterList});

  factory CourseSemesterJsonList.fromJson(Map<String, dynamic> json) => _$CourseSemesterJsonListFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSemesterJsonListToJson(this);

}

enum Day{
  Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday , UnKnown
}

enum SectionNumber{
  T_1 , T_2, T_3, T_4, T_N, T_5, T_6 , T_7 , T_8 , T_9 , T_A , T_B , T_C , T_D , T_UnKnown
}

@JsonSerializable()
class CourseTableJson {
  SemesterJson courseSemester;  //課程學期資料
  Map < Day , Map< SectionNumber , CourseTableDetailJson > > courseDetailMap;

  CourseTableJson({ this.courseSemester ,this.courseDetailMap }){
    courseSemester = ( courseSemester != null )?courseSemester : SemesterJson();
    if( courseDetailMap != null ){
      courseDetailMap = courseDetailMap;
    }else{
      courseDetailMap = Map();
      for( Day value in Day.values) {
        courseDetailMap[ value ] = Map();
      }
    }
  }

  factory CourseTableJson.fromJson(Map<String, dynamic> json) => _$CourseTableJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableJsonToJson(this);

  String toString() {
    return sprintf(
        " courseSemester  :%s \n " +
        " courseDetail  :%s \n "
        , [ courseSemester.toString() , courseDetailMap.toString() ]);
  }

  void setCourseSemester(String year , String semester){
    courseSemester = SemesterJson( year: year , semester: semester);
  }

  CourseTableDetailJson getCourseDetailByTime(Day day , SectionNumber sectionNumber){
    return courseDetailMap[day][sectionNumber];
  }

  void setCourseDetailByTime(Day day , SectionNumber sectionNumber ,CourseTableDetailJson courseDetail ) {
    if( courseDetailMap[day].containsKey(sectionNumber) ){
      throw Exception("衝堂");
    }
    courseDetailMap[day][sectionNumber] = courseDetail;
  }

  bool setCourseDetailByTimeString(Day day , String sectionNumber ,CourseTableDetailJson courseDetail ) {
    bool add = false;
    if( courseDetailMap[day].containsKey(sectionNumber) ){
      throw Exception("衝堂");
    }
    for( SectionNumber value in SectionNumber.values ){
      String time  = value.toString().split("_")[1];
      if( sectionNumber.contains(time) ){
        courseDetailMap[day][value] = courseDetail;
        add = true;
      }
    }
    return add;
  }

  String getCourseNameByCourseId( String courseId){
    for( Day day in Day.values){
      for( SectionNumber number in SectionNumber.values ){
        CourseTableDetailJson courseDetail = courseDetailMap[day][number];
        if( courseDetail != null ){
          if( courseDetail.course.id == courseId ){
            return courseDetail.course.name;
          }
        }
      }
    }
    return null;
  }


  
}



@JsonSerializable()
class CourseTableDetailJson{
  CourseJson course;
  ClassroomJson classroom;
  List<TeacherJson> teacher;

  CourseTableDetailJson( { this.course , this.classroom , this. teacher }) {
    course    = (course    != null) ? course    : CourseJson();
    classroom = (classroom != null) ? classroom : ClassroomJson();
    teacher   = (teacher   != null) ? teacher   : List();
  }

  @override
  String toString() {
    return sprintf( "course : %s \n  classroom : %s \n teacher : %s" , [course.toString() , classroom.toString() , teacher.toString() ]);
  }

  void addTeacher(TeacherJson teacherJson){
    teacher.add(teacherJson);
  }

  String getTeacherName(){
    String name = "";
    for(TeacherJson value in teacher){
      name += value.name + ' ';
    }
    return name;
  }

  void  setClassroom(ClassroomJson value) {
    classroom = value;
  }

  factory CourseTableDetailJson.fromJson(Map<String, dynamic> json) => _$CourseTableDetailJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableDetailJsonToJson(this);

}


@JsonSerializable()
class CourseJson{
  String name;
  String id;
  String href;

  CourseJson( {this.name , this.href , this.id} ){
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
    id = JsonInit.stringInit(id);
  }

  @override
  String toString() {
    return sprintf( "%s %s" , [name , id]);
  }

  factory CourseJson.fromJson(Map<String, dynamic> json) => _$CourseJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseJsonToJson(this);

}


@JsonSerializable()
class ClassroomJson{
  String name;
  String href;

  ClassroomJson( {this.name , this.href} ){
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }


  @override
  String toString() {
    return sprintf( "%s %s" , [name , href]);
  }

  factory ClassroomJson.fromJson(Map<String, dynamic> json) => _$ClassroomJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ClassroomJsonToJson(this);

}


@JsonSerializable()
class TeacherJson{
  String name;
  String href;

  TeacherJson( {this.name , this.href} ){
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }

  @override
  String toString() {
    return sprintf( "%s %s" , [name , href]);
  }

  factory TeacherJson.fromJson(Map<String, dynamic> json) => _$TeacherJsonFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherJsonToJson(this);

}



@JsonSerializable()
class SemesterJson {
  String year;
  String semester;
  SemesterJson( {this.year , this.semester} );

  factory SemesterJson.fromJson(Map<String, dynamic> json) => _$SemesterJsonFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterJsonToJson(this);

  @override
  String toString() {
    return sprintf( "year: %s  semester: %s" , [year , semester]);
  }

  @override
  bool operator ==(dynamic  o) {
    return (o.semester == semester && o.year == year && o is SemesterJson );
  }

  int get hashCode => hash2(semester.hashCode, year.hashCode);

}