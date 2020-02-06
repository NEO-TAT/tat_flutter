import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:json_annotation/json_annotation.dart';
//part 'CourseAnnouncementDetailJson.g.dart';

//@JsonSerializable()
class CourseAnnouncementJson {
  String title;
  String detail;
  CourseAnnouncementJson( {this.title , this.detail} ){
    title = JsonInit.stringInit(title);
    detail =  JsonInit.stringInit(detail);
  }

}