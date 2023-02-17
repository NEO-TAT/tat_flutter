// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/file/file_download.dart';
import 'package:flutter_app/src/file/file_store.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/model/ischoolplus/course_file_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/iplus/iplus_course_file_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/ui/icon/my_icons.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class IPlusFilePage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  const IPlusFilePage(
    this.studentId,
    this.courseInfo, {
    super.key,
  });

  @override
  State<IPlusFilePage> createState() => _IPlusFilePage();
}

class _IPlusFilePage extends State<IPlusFilePage> with AutomaticKeepAliveClientMixin {
  final List<CourseFileJson> courseFileList = [];
  final selectList = SelectList();
  bool isSupport = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    isSupport = LocalStorage.instance.getAccount() == widget.studentId;
    Future.delayed(Duration.zero, () {
      if (isSupport) {
        _addTask();
      }
      FileStore.findLocalPath();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (selectList.inSelectMode) {
      setState(() {
        selectList.leaveSelectMode();
      });
      return true;
    }

    return false;
  }

  void _addTask() async {
    await Future.delayed(const Duration(microseconds: 500));
    final courseId = widget.courseInfo.main.course.id;

    final taskFlow = TaskFlow();
    final task = IPlusCourseFileTask(courseId);
    taskFlow.addTask(task);

    if (await taskFlow.start()) {
      final result = task.result;
      if (result != null) {
        courseFileList.addAll(result);
      }
    }

    setState(() {
      selectList.addItems(courseFileList.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: (courseFileList.isNotEmpty)
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
              child: const Icon(Icons.file_download),
            )
          : null,
    );
  }

  Future<void> _floatingDownloadPress() async {
    MyToast.show(R.current.downloadWillStart);
    for (int i = 0; i < courseFileList.length; i++) {
      if (selectList.getItemSelect(i)) {
        await _downloadOneFile(i, false);
      }
    }

    setState(() {
      selectList.leaveSelectMode();
    });
  }

  Widget _buildFileList() => Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: courseFileList.length,
              itemBuilder: (context, index) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: _buildCourseFile(index, courseFileList[index]),
                onTap: () {
                  if (selectList.inSelectMode) {
                    setState(() {
                      selectList.setItemReverse(index);
                    });
                  } else {
                    _downloadOneFile(index);
                  }
                },
                onLongPress: () {
                  if (!selectList.inSelectMode) {
                    setState(() {
                      selectList.setItemReverse(index);
                    });
                  }
                },
              ),
              separatorBuilder: (context, index) => Container(
                color: Colors.black12,
                height: 1,
              ),
            ),
          ),
        ],
      );

  List<Widget> iconList = [
    const Icon(
      MyIcon.filePdf,
      color: Colors.red,
    ),
    const Icon(
      MyIcon.fileWord,
      color: Colors.blue,
    ),
    const Icon(
      MyIcon.filePowerPoint,
      color: Colors.redAccent,
    ),
    const Icon(
      MyIcon.fileExcel,
      color: Colors.green,
    ),
    const Icon(
      MyIcon.fileArchive,
      color: Colors.blue,
    ),
    const Icon(
      MyIcon.link,
      color: Colors.grey,
    ),
    const Icon(
      MyIcon.docInv,
      color: Colors.blueGrey,
    )
  ];

  Widget _buildCourseFile(int index, CourseFileJson courseFile) => Container(
      color: selectList.getItemSelect(index) ? Colors.grey : Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: _buildFileItem(courseFile),
      ));

  List<Widget> _buildFileItem(CourseFileJson courseFile) {
    final List<Widget> widgetList = [];
    final List<Widget> iconWidgetList = [];
    for (final fileType in courseFile.fileType) {
      iconWidgetList.add(iconList[fileType.type.index]);
    }
    widgetList.add(
      Row(
        children: [
          Column(
            children: const [
              // TODO(TU): To know why we can't use the icon list here.
              Icon(Icons.file_copy),
            ],
          ),
          const Padding(
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
    final courseFile = courseFileList[index];
    final fileType = courseFile.fileType[0];
    final dirName = widget.courseInfo.main.course.name;
    String url = "";
    String referer = "";

    await AnalyticsUtils.logDownloadFileEvent();
    if (showToast) {
      MyToast.show(R.current.downloadWillStart);
    }
    final urlList = await ISchoolPlusConnector.getRealFileUrl(fileType.postData) as List<String>?;
    if (urlList == null) {
      MyToast.show(sprintf("%s%s", [courseFile.name, R.current.downloadError]));
      return;
    }
    url = urlList[0];
    referer = urlList[1];
    final urlParse = Uri.parse(url);
    if (!urlParse.host.toLowerCase().contains("ntut.edu.tw")) {
      final errorDialogParameter = MsgDialogParameter(desc: R.current.isALink);
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.info;
      errorDialogParameter.okButtonText = R.current.sure;
      errorDialogParameter.onOkButtonClicked = () {
        _launchURL(url);
      };
      MsgDialog(errorDialogParameter).show();
      return;
    }

    if (urlParse.host.contains("istream.ntut.edu.tw")) {
      final errorDialogParameter = MsgDialogParameter(
        desc: '${R.current.isVideo}\n${R.current.videoMayLoadFailedWarningMsg}',
      );
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.info;
      errorDialogParameter.okButtonText = R.current.sure;
      errorDialogParameter.onOkButtonClicked =
          () => RouteUtils.toVideoPlayer(urlParse.toString(), widget.courseInfo, courseFile.name);
      MsgDialog(errorDialogParameter).show();
    } else {
      await FileDownload.download(url, dirName, courseFile.name, referer);
    }
  }

  _launchURL(String url) async {
    final preparedUrl = Uri.tryParse(url);
    if (preparedUrl != null && await canLaunchUrl(preparedUrl)) {
      RouteUtils.toWebViewPage(initialUrl: preparedUrl);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class SelectList {
  final List<bool> _selectList = [];

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
    }
    _selectList[index] = value;
  }

  void setItemReverse(int index) {
    if (index >= _selectList.length) {
      return;
    }
    _selectList[index] = !_selectList[index];
  }

  bool getItemSelect(int index) {
    if (index >= _selectList.length) {
      return false;
    }

    return _selectList[index];
  }

  bool get inSelectMode {
    bool select = false;
    for (final value in _selectList) {
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
