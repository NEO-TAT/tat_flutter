import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CoursePartJson.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';
import '../JsonInit.dart';
import 'CourseClassJson.dart';
part 'CourseMainJson.g.dart';

enum Day{
  Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday , UnKnown
}

enum SectionNumber{
  T_1 , T_2, T_3, T_4, T_N, T_5, T_6 , T_7 , T_8 , T_9 , T_A , T_B , T_C , T_D , T_UnKnown
}

@JsonSerializable()
class CourseTableJson {
  SemesterJson courseSemester;  //課程學期資料
  Map < Day , Map< SectionNumber , CourseInfoJson > > courseDetailMap;

  CourseTableJson({ this.courseSemester ,this.courseDetailMap }){
    courseSemester = courseSemester ?? SemesterJson();
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
        " courseSemester : %s \n " +
        " courseDetail   : %s \n "
        , [ courseSemester.toString() , courseDetailMap.toString() ]);
  }

  CourseInfoJson getCourseDetailByTime(Day day , SectionNumber sectionNumber){
    return courseDetailMap[day][sectionNumber];
  }

  void setCourseDetailByTime(Day day , SectionNumber sectionNumber ,CourseInfoJson courseInfo ) {
    if( day == Day.UnKnown ){
      for(SectionNumber value in SectionNumber.values){
        if( !courseDetailMap[day].containsKey(value) ){
          courseDetailMap[day][value] = courseInfo;
        }
      }
    }
    else if( courseDetailMap[day].containsKey(sectionNumber) ) {
      throw Exception("衝堂");
    }
    else{
      courseDetailMap[day][sectionNumber] = courseInfo;
    }
  }

  bool setCourseDetailByTimeString(Day day , String sectionNumber ,CourseInfoJson courseDetail ) {
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
        CourseInfoJson courseDetail = courseDetailMap[day][number];
        if( courseDetail != null ){
          if( courseDetail.main.course.id == courseId ){
            return courseDetail.main.course.name;
          }
        }
      }
    }
    return null;
  }

}



@JsonSerializable()
class CourseInfoJson{
  CourseMainInfoJson main;
  CourseExtraInfoJson extra;

  CourseInfoJson( { this.main , this.extra }) {
    main  = main  ?? CourseMainInfoJson();
    extra = extra ?? CourseExtraInfoJson();
  }

  @override
  String toString() {
    return sprintf(
        "main : %s \n" +
        "extra: %s \n "
        , [main.toString() , extra.toString() ]);
  }

  factory CourseInfoJson.fromJson(Map<String, dynamic> json) => _$CourseInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseInfoJsonToJson(this);

}


