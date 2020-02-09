import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';

class CourseTableControl{
  bool isHideSaturday = false;
  bool isHideSunday   = false;
  bool isHideUnKnown  = false;
  bool isHideN        = false;
  bool isHideABCD     = false;
  CourseTableJson courseTable;
  List<String> dayStringList = ["一" , "二" , "三" , "四" , "五" , "六" , "日" , ""];
  List<String> sectionStringList = ["1" , "2" , "3" , "4" , "N" , "5" , "6" , "7" , "8" , "9" , "A" , "B" , "C" , "D"];
  static int dayLength = 8;
  static int sectionLength = 14;

  void set(CourseTableJson value){
    courseTable = value;
    isHideSaturday = !courseTable.isDayInCourseTable(Day.Sunday);
    isHideSunday   = !courseTable.isDayInCourseTable(Day.Saturday);
    isHideUnKnown  = !courseTable.isDayInCourseTable(Day.UnKnown);
    isHideN        = !courseTable.isSectionNumberInCourseTable(SectionNumber.T_N);
    isHideABCD     = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_A));
    isHideABCD     &= (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_B));
    isHideABCD     &= (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_C));
    isHideABCD     &= (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_D));
  }


  List<int> get getDayIntList {
    List<int> intList = List();
    for( int i = 0 ; i < dayLength ; i++){
      if( isHideSaturday && i == 5)
        continue;
      if( isHideSunday   && i == 6)
        continue;
      if( isHideUnKnown  && i == 7)
        continue;
      intList.add(i);
    }
    return intList;
  }


  CourseInfoJson getCourseInfo( int intDay, int intNumber ){
    Day day = Day.values[intDay];
    SectionNumber number = SectionNumber.values[intNumber];
    //Log.d( day.toString()  + " " + number.toString() );
    return courseTable.courseInfoMap[day][number];
  }


  List<int> get getSectionIntList {
    List<int> intList = List();
    for( int i = 0 ; i < sectionLength ; i++){
      if( isHideN && i == 4)
        continue;
      if( isHideABCD && ( i == 10 || i == 11 || i == 12 || i == 13 ))
        continue;
      intList.add(i);
    }
    return intList;
  }


  String getDayString( int i ){
    return dayStringList[i];
  }

  String getSectionString( int i ){
    return sectionStringList[i];
  }

}