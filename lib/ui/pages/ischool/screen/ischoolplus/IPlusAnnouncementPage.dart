import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/json/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusCourseAnnouncementDetailTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusCourseAnnouncementTask.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'IPlusAnnouncementDetailPage.dart';

class IPlusAnnouncementPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  IPlusAnnouncementPage(this.studentId, this.courseInfo);

  @override
  _IPlusAnnouncementPage createState() => _IPlusAnnouncementPage();
}

class _IPlusAnnouncementPage extends State<IPlusAnnouncementPage>
    with AutomaticKeepAliveClientMixin {
  List<ISchoolPlusAnnouncementJson> items;
  bool needRefresh = false;
  bool isSupport;

  @override
  void initState() {
    super.initState();
    isSupport = Model.instance.getAccount() == widget.studentId;
    items = List();
    if (isSupport) {
      _addTask();
    }
  }

  void _addTask() async {
    //第一次
    String courseId = widget.courseInfo.main.course.id;
    TaskHandler.instance
        .addTask(ISchoolPlusCourseAnnouncementTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    items = Model.instance
        .getTempData(ISchoolPlusCourseAnnouncementTask.announcementListTempKey);
    items = items ?? List();
    setState(() {});
  }

  void _getAnnouncementDetail(ISchoolPlusAnnouncementJson value) async {
    TaskHandler.instance
        .addTask(ISchoolPlusCourseAnnouncementDetailTask(context, value));
    await TaskHandler.instance.startTaskQueue(context);
    Map detail = Model.instance.getTempData(
        ISchoolPlusCourseAnnouncementDetailTask.announcementListTempKey);
    Navigator.of(context).push(PageTransition(
        type: PageTransitionType.leftToRight,
        child: IPlusAnnouncementDetailPage(widget.courseInfo, detail)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: (items.length > 0)
          ? _buildMailList()
          : isSupport
              ? Center(
                  child: Text(R.current.noAnyAnnouncement),
                )
              : Center(
                  child: Text(R.current.notSupport),
                ),
    );
  }

  Widget _buildMailList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      scrollDirection: Axis.vertical,
      primary: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque, //讓透明部分有反應
          onTap: () {
            ISchoolPlusAnnouncementJson value = items[index];
            _getAnnouncementDetail(value);
          },
          child: _listItem(
            items[index],
          ),
        );
      },
    );
  }

  Widget _listItem(ISchoolPlusAnnouncementJson data) {
    Color color = (data.readflag != 1) ? Colors.black87 : Colors.black54;
    FontWeight fontWeight =
        (data.readflag != 1) ? FontWeight.bold : FontWeight.w400;
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 14.0, right: 14.0, top: 5.0, bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: 55.0,
                  color: Colors.red,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                data.subject,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontWeight: fontWeight,
                                    color: color,
                                    fontSize: 17.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              data.realname,
                              style: TextStyle(
                                  fontWeight: fontWeight,
                                  color: color,
                                  fontSize: 15.5),
                            ),
                            Text(
                              data.postdate,
                              style: TextStyle(
                                  fontWeight: fontWeight,
                                  color: color,
                                  fontSize: 13.5),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
