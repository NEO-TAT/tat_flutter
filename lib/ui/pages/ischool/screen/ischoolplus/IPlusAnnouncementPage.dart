import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/json/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusCourseAnnouncementDetailTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusCourseAnnouncementTask.dart';
import 'package:flutter_app/ui/other/MyPageTransition.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

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
  String courseBid;
  bool needRefresh = false;
  bool isSupport;
  bool openNotifications = false;

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
    MyProgressDialog.showProgressDialog(context, R.current.searchSubscribe);
    courseBid = await ISchoolPlusConnector.getBid(courseId);
    openNotifications =
        await ISchoolPlusConnector.getCourseSubscribe(courseBid);
    MyProgressDialog.hideProgressDialog();
    setState(() {});
  }

  void _getAnnouncementDetail(ISchoolPlusAnnouncementJson value) async {
    TaskHandler.instance
        .addTask(ISchoolPlusCourseAnnouncementDetailTask(context, value));
    await TaskHandler.instance.startTaskQueue(context);
    Map detail = Model.instance.getTempData(
        ISchoolPlusCourseAnnouncementDetailTask.announcementListTempKey);
    Navigator.of(context).push(MyPage.transition(
        IPlusAnnouncementDetailPage(widget.courseInfo, detail)));
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
        floatingActionButton: FloatingActionButton(
          // FloatingActionButton: 浮動按鈕
          onPressed: () async {
            MyToast.show((openNotifications)
                ? R.current.closeSubscribe
                : R.current.openSubscribe);
            MyProgressDialog.showProgressDialog(context, null);
            bool success = await ISchoolPlusConnector.courseSubscribe(
                courseBid, !openNotifications);
            MyProgressDialog.hideProgressDialog();
            if (success) {
              setState(() {
                openNotifications = !openNotifications;
              });
            }
          },
          tooltip: R.current.subscribe,
          // 按住按鈕時出現的提示字
          child: (openNotifications)
              ? Icon(Icons.notifications_active)
              : Icon(Icons.notifications_off),
        ));
  }

  Widget _buildMailList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      scrollDirection: Axis.vertical,
      primary: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InkWell(
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
    FontWeight fontWeight =
        (data.readflag != 1) ? FontWeight.bold : FontWeight.normal;
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
                                    fontWeight: fontWeight, fontSize: 17.0),
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
                                  fontWeight: fontWeight, fontSize: 15.5),
                            ),
                            Text(
                              data.postdate,
                              style: TextStyle(
                                  fontWeight: fontWeight, fontSize: 13.5),
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
