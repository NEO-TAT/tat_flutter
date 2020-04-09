import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/src/store/json/SettingJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ischool/ISchoolDeleteNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischool/ISchoolNewAnnouncementDetailTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischool/ISchoolNewAnnouncementPageTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischool/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'page/AnnouncementDetailPage.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<NewAnnouncementJson> items;
  bool needRefresh = false;

  @override
  void initState() {
    super.initState();
    items = Model.instance.getNewAnnouncementList();
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
    Model.instance.getAnnouncementSetting().page = 1;
    Model.instance.saveAnnouncementSetting();
    _loadAnnouncement();
  }

  void _getAnnouncementDetail(NewAnnouncementJson value) async {
    //第一次時需要取得公告
    TaskHandler.instance
        .addTask(ISchoolNewAnnouncementDetailTask(context, value));
    await TaskHandler.instance.startTaskQueue(context);
    _showAnnouncementDetail(value);
  }

  void _showAnnouncementDetail(NewAnnouncementJson value) {
    //顯示公告詳細內容
    setState(() {});
    Navigator.of(context).push(PageTransition(
        type: PageTransitionType.leftToRight,
        child: AnnouncementDetailPage(value)));
  }

  void _loadAnnouncement() async {
    //取得已經儲存的公告
    items = Model.instance.getNewAnnouncementList();
    setState(() {});
  }

  Future<void> _loadAnnouncementMaxPage() async {
    AnnouncementSettingJson announcementSetting =
        Model.instance.getAnnouncementSetting();
    Log.d(announcementSetting.maxPage.toString());
    if (announcementSetting.maxPage == 0) {
      //第一次要取得頁數
      TaskHandler.instance.addTask(ISchoolNewAnnouncementPageTask(context));
      await TaskHandler.instance.startTaskQueue(context);
    }
  }

  void _onRefresh() async {
    TaskHandler.instance.addTask(ISchoolNewAnnouncementTask(context, 1));
    await TaskHandler.instance.startTaskQueue(context);
    _refreshController.refreshCompleted();
    _loadAnnouncement();
    setState(() {});
  }

  void _onLoading() async {
    if (!needRefresh) {
      needRefresh = true;
      MyToast.show(R.current.pullAgainToUpdate);
      Future.delayed(Duration(seconds: 2), () {
        needRefresh = false;
      });
    } else {
      await _loadAnnouncementMaxPage();
      AnnouncementSettingJson announcementSetting =
          Model.instance.getAnnouncementSetting();
      announcementSetting.page++;
      int page = announcementSetting.page;
      Log.d(items.length.toString());
      int maxPage = announcementSetting.maxPage;
      if (page <= maxPage) {
        Model.instance.setAnnouncementSetting(announcementSetting);
        Model.instance.saveAnnouncementSetting();
        TaskHandler.instance.addTask(ISchoolNewAnnouncementTask(context, page));
        await TaskHandler.instance.startTaskQueue(context);
        _loadAnnouncement();
      } else {
        MyToast.show(R.current.noMoreData);
      }
    }
    _refreshController.loadComplete();
  }

  _onPopupMenuSelect(int value) async {
    switch (value) {
      case 1:
        await Model.instance.clearNewAnnouncement();
        _getAnnouncement();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.titleNotification),
        actions: [
          PopupMenuButton<int>(
            // overflow menu
            onSelected: (value) {
              _onPopupMenuSelect(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Text(R.current.clearAndRefresh),
                ),
              ];
            },
          ),
        ],
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
              body = Text(R.current.pullUpLoad);
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text(R.current.loadFailed);
            } else if (mode == LoadStatus.canLoading) {
              body = Text(R.current.ReleaseLoadMore);
            } else {
              body = Text(R.current.noMoreData);
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: _buildListItem(
                  items[index],
                ),
                secondaryActions: <Widget>[
                  new IconSlideAction(
                    caption: R.current.delete,
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      _deleteMessage(index);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _deleteMessage(int index) {
    NewAnnouncementJson newAnnouncement = items[index];
    ErrorDialogParameter parameter = ErrorDialogParameter(
        context: context,
        dialogType: DialogType.INFO,
        title: R.current.warning,
        desc: R.current.areYouSureDeleteMessage,
        btnOkText: R.current.sure,
        btnCancelText: R.current.cancel,
        btnOkOnPress: () async {
          TaskHandler.instance.addTask(ISchoolDeleteNewAnnouncementTask(
              context, newAnnouncement.messageId));
          await TaskHandler.instance.startTaskQueue(context);
          bool isDelete = Model.instance
              .getTempData(ISchoolDeleteNewAnnouncementTask.isDeleteKey);
          if (isDelete) {
            Model.instance.getNewAnnouncementList().removeAt(index);
            Model.instance.saveNewAnnouncement();
            items.removeAt(index);
            setState(() {});
          }
        });
    ErrorDialog(parameter).show();
  }

  Widget _buildListItem(NewAnnouncementJson data) {
    FontWeight fontWeight =
        (!data.isRead) ? FontWeight.bold : FontWeight.normal;
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: 55.0,
                  color: Colors.deepOrangeAccent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data.title,
                          overflow: TextOverflow.visible,
                          style:
                              TextStyle(fontWeight: fontWeight, fontSize: 18),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          data.courseName,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontWeight: fontWeight, fontSize: 16),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              data.sender,
                              style: TextStyle(
                                  fontWeight: fontWeight, fontSize: 15.5),
                            ),
                            Text(
                              data.timeString,
                              style: TextStyle(fontSize: 13.5),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
