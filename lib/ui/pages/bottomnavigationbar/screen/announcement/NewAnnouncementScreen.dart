import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementDetailTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementPageTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/announcement/page/AnnouncementDetailPage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewAnnouncementScreen extends StatefulWidget {
  @override
  _NewAnnouncementScreen createState() => _NewAnnouncementScreen();
}

class _NewAnnouncementScreen extends State<NewAnnouncementScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<NewAnnouncementJson> items;

  @override
  void initState() {
    super.initState();
    items = Model.instance.newAnnouncementList.newAnnouncementList;
    if (items.length == 0) {
      _getAnnouncement();
    } else {
      _loadAnnouncement();
    }
  }

  void _getAnnouncement() async {
    //第一次
    TaskHandler.instance.addTask(ISchoolNewAnnouncementTask(context, 1));
    await TaskHandler.instance.startTaskQueue(context);
    Model.instance.setting.announcement.page = 1;
    Model.instance.save(Model.settingJsonKey);
    _loadAnnouncement();
  }

  void _getAnnouncementDetail(NewAnnouncementJson value) async {
    //第一次
    TaskHandler.instance
        .addTask(ISchoolNewAnnouncementDetailTask(context, value));
    await TaskHandler.instance.startTaskQueue(context);
    _showAnnouncementDetail(value);
  }

  void _showAnnouncementDetail(NewAnnouncementJson value) {
    setState(() {});
    Navigator.of(context).push(PageTransition(
        type: PageTransitionType.leftToRight,
        child: AnnouncementDetailPage(value)));
  }

  void _loadAnnouncement() async {
    if( Model.instance.setting.announcement.maxPage == 0){  //第一次要取得頁數
      TaskHandler.instance.addTask( ISchoolNewAnnouncementPageTask(context) );
      await TaskHandler.instance.startTaskQueue(context);
    }
    items = Model.instance.newAnnouncementList.newAnnouncementList;
    setState(() {});
  }

  void _onRefresh() async {
    TaskHandler.instance.addTask(ISchoolNewAnnouncementTask(context, 1));
    await TaskHandler.instance.startTaskQueue(context);
    _loadAnnouncement();
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    Model.instance.setting.announcement.page++;
    int page = Model.instance.setting.announcement.page;
    Log.d(items.length.toString());
    int maxPage = Model.instance.setting.announcement.maxPage;
    if (page <= maxPage) {
      Model.instance.save(Model.settingJsonKey);
      TaskHandler.instance.addTask(ISchoolNewAnnouncementTask(context, page));
      await TaskHandler.instance.startTaskQueue(context);
      _loadAnnouncement();
      _refreshController.loadComplete();
    } else {
      Fluttertoast.showToast(
          msg: "已經到底了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      _refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        //header: WaterDropHeader(),
        header: WaterDropMaterialHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.vertical,
          primary: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque, //讓透明部分有反應
              onTap: () {
                NewAnnouncementJson value = items[index];
                if (value.detail.isEmpty) {
                  _getAnnouncementDetail(value);
                } else {
                  _showAnnouncementDetail(value);
                }
              },
              child: Slidable(
                delegate: SlidableDrawerDelegate(),
                actionExtentRatio: 0.25,
                child: _listItem(
                  items[index],
                ),
                secondaryActions: <Widget>[
                  new IconSlideAction(
                    caption: 'More',
                    color: Colors.black45,
                    icon: Icons.more_horiz,
                    onTap: () => {},
                  ),
                  new IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => {},
                  ),
                ],

              ),
            );
          },
        ),
      ),
    );
  }

  Widget _listItem(NewAnnouncementJson data) {
    Color color = (!data.isRead) ? Colors.black87 : Colors.black54;
    FontWeight fontWeight = (!data.isRead) ? FontWeight.bold : FontWeight.w400;
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
                                data.title,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data.courseName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: fontWeight,
                                  color: color,
                                  fontSize: 15.5),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              data.sender,
                              style: TextStyle(
                                  fontWeight: fontWeight,
                                  color: color,
                                  fontSize: 15.5),
                            ),
                            Text(
                              data.timeString,
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
}