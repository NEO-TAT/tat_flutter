import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/permission/Permission.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseFileJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolCourseFileTask.dart';
import 'package:flutter_app/ui/icon/MyIcons.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class CourseFileScreen extends StatefulWidget {
  final CourseInfoJson courseInfo;

  CourseFileScreen(this.courseInfo);

  @override
  _CourseFileScreen createState() => _CourseFileScreen();
}

class _CourseFileScreen extends State<CourseFileScreen>
    with AutomaticKeepAliveClientMixin {
  List<CourseFileJson> courseFileList = List();
  SelectList selectList = SelectList();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    Future.delayed(Duration.zero, () {
      _flutterDownloaderInit();
      FileStore.findLocalPath(context);
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if (selectList.inSelectMode) {
      selectList.leaveSelectMode();
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  void _flutterDownloaderInit() async {
    FlutterDownloader.registerCallback(downloadCallback);
    _addTask();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (status == DownloadTaskStatus.complete) {
      Log.d("id : $id is complete");
    } else if (status == DownloadTaskStatus.failed) {
      Log.d("id : $id is fail");
      //FlutterDownloader.retry(taskId: id);
    }
  }

  void _addTask() async {
    await Future.delayed(Duration(microseconds: 500));
    String courseId = widget.courseInfo.main.course.id;
    TaskHandler.instance.addTask(ISchoolCourseFileTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseFileList =
        Model.instance.tempData[ISchoolCourseFileTask.courseFileListTempKey];
    selectList.addItems(courseFileList.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Scaffold(
        body: (courseFileList.length > 0)
            ? _buildFileList()
            : Center(
                child: Text("無任何檔案"),
              ),
        floatingActionButton: (selectList.inSelectMode)
            ? FloatingActionButton(
                // FloatingActionButton: 浮動按鈕
                onPressed: _floatingDownloadPress,
                // 按下觸發的方式名稱: void _incrementCounter()
                tooltip: '下載',
                // 按住按鈕時出現的提示字
                child: Icon(Icons.file_download),
              )
            : null);
  }

  Future<void> _floatingDownloadPress() async{
    MyToast.show("下載準備開始");
    for (int i = 0; i < courseFileList.length; i++) {
      if (selectList.getItemSelect(i)) {
        await _downloadOneFile(i, false);
      }
    }
    selectList.leaveSelectMode();
    setState(() {});
  }

  Widget _buildFileList() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: courseFileList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque, //讓透明部分有反應
                  child: _buildCourseFile(index, courseFileList[index]),
                  onTap: () {
                    if (selectList.inSelectMode) {
                      selectList.setItemReverse(index);
                      setState(() {});
                    } else {
                      _downloadOneFile(index);
                    }
                  },
                  onLongPress: () {
                    if (!selectList.inSelectMode) {
                      selectList.setItemReverse(index);
                      setState(() {});
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                // 顯示格線
                return Container(
                  color: Colors.black12,
                  height: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> iconList = [
    Icon(
      MyIcon.file_pdf,
      color: Colors.red,
    ),
    Icon(
      MyIcon.file_word,
      color: Colors.blue,
    ),
    Icon(
      MyIcon.file_powerpoint,
      color: Colors.redAccent,
    ),
    Icon(
      MyIcon.file_excel,
      color: Colors.green,
    ),
    Icon(
      MyIcon.file_archive,
      color: Colors.blue,
    ),
    Icon(
      MyIcon.link,
      color: Colors.grey,
    ),
  ];

  Widget _buildCourseFile(int index, CourseFileJson courseFile) {
    return Container(
        color: selectList.getItemSelect(index) ? Colors.green : Colors.white,
        padding: EdgeInsets.all(10),
        child: Column(
          children: _buildFileItem(courseFile),
        ));
  }

  List<Widget> _buildFileItem(CourseFileJson courseFile) {
    List<Widget> widgetList = List();
    List<Widget> iconWidgetList = List();
    for (FileType fileType in courseFile.fileType) {
      iconWidgetList.add(iconList[fileType.type.index]);
    }
    widgetList.add(
      Row(
        children: [
          Column(
            children: iconWidgetList,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
          ),
          Expanded(
            child: Text(courseFile.name),
          ),
          Text(courseFile.timeString),
        ],
      ),
    );
    return widgetList;
  }

  Future<void> _downloadOneFile(int index, [showToast = true]) async {
    if (showToast) {
      MyToast.show("下載準備開始");
    }
    CourseFileJson courseFile = courseFileList[index];
    FileType fileType = courseFile.fileType[0];
    String dirName = widget.courseInfo.main.course.name;
    String url = fileType.fileUrl;
    await FileDownload.download(context, url, dirName , courseFile.name);
  }

  @override
  bool get wantKeepAlive => true;
}

class SelectList {
  List<bool> _selectList = List();

  void addItem() {
    _selectList.add(false);
  }

  void addItems(int number) {
    for (int i = 0; i < number; i++) {
      addItem();
    }
  }

  void setItemSelect(int index, bool value) {
    if (index >= _selectList.length) {
      return;
    } else {
      _selectList[index] = value;
    }
  }

  void setItemReverse(int index) {
    if (index >= _selectList.length) {
      return;
    } else {
      _selectList[index] = !_selectList[index];
    }
  }

  bool getItemSelect(int index) {
    if (index >= _selectList.length) {
      return false;
    } else {
      return _selectList[index];
    }
  }

  bool get inSelectMode {
    bool select = false;
    for (bool value in _selectList) {
      select |= value;
    }
    return select;
  }

  void leaveSelectMode() {
    for (int i = 0; i < _selectList.length; i++) {
      _selectList[i] = false;
    }
  }
}