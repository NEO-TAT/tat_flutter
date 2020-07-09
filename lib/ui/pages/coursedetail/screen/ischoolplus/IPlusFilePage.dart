import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/object/CourseFileJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusCourseFileTask.dart';
import 'package:flutter_app/ui/icon/MyIcons.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyPageTransition.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/videoplayer/ClassVideoPlayer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class IPlusFilePage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  IPlusFilePage(this.studentId, this.courseInfo);

  @override
  _IPlusFilePage createState() => _IPlusFilePage();
}

class _IPlusFilePage extends State<IPlusFilePage>
    with AutomaticKeepAliveClientMixin {
  List<CourseFileJson> courseFileList = List();
  SelectList selectList = SelectList();
  bool isSupport;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    isSupport = Model.instance.getAccount() == widget.studentId;
    Future.delayed(Duration.zero, () {
      if (isSupport) {
        _addTask();
      }
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

  void _addTask() async {
    await Future.delayed(Duration(microseconds: 500));
    String courseId = widget.courseInfo.main.course.id;
    TaskHandler.instance.addTask(ISchoolPlusCourseFileTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseFileList = Model.instance
        .getTempData(ISchoolPlusCourseFileTask.courseFileListTempKey);
    courseFileList = courseFileList ?? List();
    selectList.addItems(courseFileList.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Scaffold(
        body: (courseFileList.length > 0)
            ? _buildFileList()
            : (isSupport)
                ? Center(
                    child: Text(R.current.noAnyFile),
                  )
                : Center(
                    child: Text(R.current.notSupport),
                  ),
        floatingActionButton: (selectList.inSelectMode)
            ? FloatingActionButton(
                // FloatingActionButton: 浮動按鈕
                onPressed: _floatingDownloadPress,
                // 按下觸發的方式名稱: void _incrementCounter()
                tooltip: R.current.download,
                // 按住按鈕時出現的提示字
                child: Icon(Icons.file_download),
              )
            : null);
  }

  Future<void> _floatingDownloadPress() async {
    MyToast.show(R.current.downloadWillStart);
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
    Icon(
      MyIcon.doc_inv,
      color: Colors.blueGrey,
    )
  ];

  Widget _buildCourseFile(int index, CourseFileJson courseFile) {
    return Container(
        color: selectList.getItemSelect(index)
            ? Colors.grey
            : Theme.of(context).backgroundColor,
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
        ],
      ),
    );
    return widgetList;
  }

  Future<void> _downloadOneFile(int index, [showToast = true]) async {
    CourseFileJson courseFile = courseFileList[index];
    FileType fileType = courseFile.fileType[0];
    String dirName = widget.courseInfo.main.course.name;
    String url;
    String referer;
    List<String> urlList = List();
    if (showToast) {
      MyToast.show(R.current.downloadWillStart);
    }
    urlList = await ISchoolPlusConnector.getRealFileUrl(fileType.postData);
    if (urlList == null) {
      MyToast.show(sprintf("%s%s", [courseFile.name, R.current.downloadError]));
      return;
    }
    url = urlList[0];
    referer = urlList[1];
    Uri urlParse = Uri.parse(url);
    if (!urlParse.host.toLowerCase().contains("ntut.edu.tw")) {
      //代表可能是一個連結
      ErrorDialogParameter errorDialogParameter =
          ErrorDialogParameter(context: context, desc: R.current.isALink);
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.INFO;
      errorDialogParameter.btnOkText = R.current.sure;
      errorDialogParameter.btnOkOnPress = () {
        _launchURL(url);
      };
      ErrorDialog(errorDialogParameter).show();
      return;
    } else if (urlParse.host.contains("istream.ntut.edu.tw") &&
        urlParse.path.contains("/lecture/player/player2.html")) {
      ErrorDialogParameter errorDialogParameter =
          ErrorDialogParameter(context: context, desc: R.current.isVideo);
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.INFO;
      errorDialogParameter.btnOkText = R.current.sure;
      errorDialogParameter.btnOkOnPress = () {
        String uuid = urlParse.queryParameters["vid"]; //影片uuid
        Navigator.of(context).push(MyPage.transition(ClassVideoPlayer(uuid)));
      };
      ErrorDialog(errorDialogParameter).show();
    } else {
      await FileDownload.download(
          context, url, dirName, courseFile.name, referer);
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
