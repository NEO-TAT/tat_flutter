import 'package:tat/src/model/json_init.dart';
//part 'CourseAnnouncementDetailJson.g.dart';

//@JsonSerializable()
class CourseAnnouncementJson {
  String title;
  String detail;

  CourseAnnouncementJson({this.title, this.detail}) {
    title = JsonInit.stringInit(title);
    detail = JsonInit.stringInit(detail);
  }
}
