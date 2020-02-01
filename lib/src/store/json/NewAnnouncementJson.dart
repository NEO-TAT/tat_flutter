import 'package:flutter_app/debug/log/Log.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';
import '../JsonInit.dart';
part 'NewAnnouncementJson.g.dart';

@JsonSerializable()
class NewAnnouncementJsonList {
  List<NewAnnouncementJson> newAnnouncementList;
  NewAnnouncementJsonList( {this.newAnnouncementList} ){
    newAnnouncementList = ( newAnnouncementList != null ) ? newAnnouncementList : List();
  }

  void addNewAnnouncement( NewAnnouncementJson newAnnouncement ){
    bool pass = true;
    for( NewAnnouncementJson  value in newAnnouncementList ){
      if(  value.courseId == newAnnouncement.courseId && newAnnouncement.time ==  value.time ){
        pass = false;
        break;
      }
    }
    if( pass ){
      Log.d( sprintf("add : %s" , [newAnnouncement.toString()]) );
      newAnnouncementList.add(newAnnouncement);
      newAnnouncementList.sort( (a , b) => b.time.compareTo( a.time ) );  //排序
    }
  }


  factory NewAnnouncementJsonList.fromJson(Map<String, dynamic> json) => _$NewAnnouncementJsonListFromJson(json);
  Map<String, dynamic> toJson() => _$NewAnnouncementJsonListToJson(this);

  @override
  String toString() {
    return sprintf("%s" , [newAnnouncementList.toString()]);
  }

}



@JsonSerializable()
class NewAnnouncementJson {
  String title;
  String detail;
  String sender;
  String courseId;
  String courseName;
  String messageId;
  bool isRead;
  DateTime time;

  NewAnnouncementJson({this.title , this.detail , this.sender, this.courseId , this.courseName ,this.messageId ,this.isRead ,this.time });

  factory NewAnnouncementJson.fromJson(Map<String, dynamic> json) => _$NewAnnouncementJsonFromJson(json);
  Map<String, dynamic> toJson() => _$NewAnnouncementJsonToJson(this);
  @override
  String toString() {
    var formatter = DateFormat.yMd().add_jm();
    String formatted = formatter.format( time );
    return sprintf(" title:%s \n sender:%s \n messageId:%s \n courseName:%s \n postTime:%s \n\n",
        [title, sender, messageId, courseName, formatted ] );
  }
}