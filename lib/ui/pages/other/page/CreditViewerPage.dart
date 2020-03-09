import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/TaskModelFunction.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseExtraInfoTask.dart';
import 'package:flutter_app/src/taskcontrol/task/score/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/AppExpansionTile.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sprintf/sprintf.dart';

class CreditViewerPage extends StatefulWidget {
  @override
  _CreditViewerPage createState() => _CreditViewerPage();
}

class _CreditViewerPage extends State<CreditViewerPage> {
  bool isLoading = true;
  final List<String> creditType = ["○", "△", "☆", "●", "▲", "★"];

  /*
  ○	  必	部訂共同必修
  △	必	校訂共同必修
  ☆	選	共同選修
  ●	  必	部訂專業必修
  ▲	  必	校訂專業必修
  ★	選	專業選修
  */
  ScrollController _scrollController = ScrollController();
  Map courseDataSemester = Map(); //紀錄全部課程按照學期
  Map totalCreditMap = Map(); //紀錄課程學分
  Map generalLessonMap = Map(); //紀錄博雅課程
  Map graduationMap = Map(); //紀錄畢業
  final List<String> generalLessonType = [
    "文化向度",
    "歷史向度",
    "哲學向度",
    "法治向度",
    "社會向度",
    "自然向度",
    "社哲向度",
    "創創向度",
    "美學向度",
    "文史向度"
  ];

  Map courseDataByType = Map(); //紀錄全部課程按照課程類別
  int courseDataLength = 0;

  @override
  void initState() {
    super.initState();
    _addTask();
  }

  void _addTask() async {
    TaskHandler.instance.addTask(TaskModelFunction(
      context,
      require: [CheckCookiesTask.checkScore],
      taskFunction: () async {
        MyProgressDialog.showProgressDialog(context, R.current.creditSearch);
        //查詢已修課程
        NTUTAppConnectorStatus status = await NTUTAppConnector.login(
            Model.instance.getAccount(), Model.instance.getPassword());
        if (status != NTUTAppConnectorStatus.LoginSuccess) {
          return false;
        }
        courseDataSemester = await NTUTAppConnector.getCredit();
        //查詢畢業標準
        String department = courseDataSemester.remove("department");
        graduationMap = await CourseConnector.getGraduation(
            Model.instance.getAccount().substring(0, 3), department);
        MyProgressDialog.hideProgressDialog();
        return true;
      },
      errorFunction: () {
        ErrorDialogParameter parameter = ErrorDialogParameter(
          context: context,
          desc: R.current.getCourseDetailError,
        );
        ErrorDialog(parameter).show();
      },
      successFunction: () async {},
    ));
    await TaskHandler.instance.startTaskQueue(context);

    generalLessonMap["core"] = 0; //博雅核心
    generalLessonMap["select"] = 0; //博雅選修
    for (String type in creditType) {
      courseDataByType[type] = List();
      totalCreditMap[type] = 0;
      totalCreditMap[type + "_need"] = 0;
      if (graduationMap.containsKey(type)) {
        totalCreditMap[type + "_need"] = graduationMap[type];
      }
    }
    totalCreditMap["lowCredit"] = 0;
    totalCreditMap["lowCredit_need"] = graduationMap["lowCredit"];
    totalCreditMap["otherDepartmentCredit"] = 0;
    for (String semester in courseDataSemester.keys.toList()) {
      List courseList = courseDataSemester[semester];
      for (int i = 0; i < courseList.length; i++) {
        Map courseItem = courseList[i];
        //計算總學分
        String key = courseItem["category"];
        if (totalCreditMap.containsKey(key)) {
          totalCreditMap[key] += courseItem["credit"];
        } else {
          totalCreditMap[key] = courseItem["credit"];
        }
        totalCreditMap["lowCredit"] += courseItem["credit"];
        //計算課程按造分類
        String category = courseItem["category"];
        courseDataByType[category].add(courseItem);
        if (courseItem.containsKey("extra")) {
          String type = courseItem["extra"];
          //計算博雅
          if (generalLessonType.contains(type)) {
            if (generalLessonMap.containsKey(type)) {
              generalLessonMap[type].add(courseItem);
            } else {
              generalLessonMap[type] = [courseItem];
            }
            if (courseItem.containsKey("core")) {
              //博雅核心課程
              generalLessonMap["core"] += courseItem['credit'];
            } else {
              //博雅選修課程
              generalLessonMap["select"] += courseItem['credit'];
            }
          } else {
            totalCreditMap["otherDepartmentCredit"] += courseItem['credit'];
          }
          //計算外系課程

        }
      }
    }
    courseDataLength = courseDataSemester.keys.toList().length;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.creditViewer),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            (isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: getAnimationList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getAnimationList() {
    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: courseDataLength + 2,
        itemBuilder: (BuildContext context, int index) {
          Widget buildWidget;
          if (index == 0) {
            buildWidget = _buildSummaryItem();
          } else if (index == 1) {
            buildWidget = _buildGeneralLessonItem(); //博雅
          } else {
            String semester = courseDataSemester.keys.toList()[index - 2];
            List courseList = courseDataSemester[semester];
            buildWidget = _buildOneSemesterItem(semester, courseList);
          }
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, //讓透明部分有反應
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: buildWidget,
                  ),
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem() {
    Widget widget = _buildTile(sprintf("學分總覽 %d/%d",
        [totalCreditMap["lowCredit"], totalCreditMap["lowCredit_need"]]));
    List<Widget> widgetList = List();
    widgetList.add(_buildType("○", "部訂共同必修"));
    widgetList.add(_buildType("△", "校訂共同必修"));
    widgetList.add(_buildType("☆", "共同選修"));
    widgetList.add(_buildType("●", "部訂專業必修"));
    widgetList.add(_buildType("▲", "校訂專業必修"));
    widgetList.add(_buildType("★", "專業選修"));
    widgetList.add(
      Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text("外系學分:"),
            ),
            Text( totalCreditMap["otherDepartmentCredit"].toString() )
          ],
        ),
      ),
    );
    /*
    widgetList.add(
        _buildType("外系學分", totalCreditMap["otherDepartmentCredit"], 0 ));
     */
    return Container(
      child: AppExpansionTile(
        title: widget,
        children: widgetList,
      ),
    );
  }

  Widget _buildType(String type, String title) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, //讓透明部分有反應
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(sprintf("%s%s :", [
                type,
                title,
              ])),
            ),
            Text(sprintf("%d/%d",
                [totalCreditMap[type], totalCreditMap[type + "_need"]]))
          ],
        ),
      ),
      onTap: () {
        Log.d( courseDataByType[type].toString() );
      },
    );
  }

  Widget _buildGeneralLessonItem() {
    Widget titleWidget = _buildTile(sprintf("博雅總覽 實得核心:%d 實得選修:%d",
        [generalLessonMap["core"], generalLessonMap["select"]]));
    List<Widget> widgetList = List();
    for (String type in generalLessonMap.keys.toList()) {
      if (type == "core" || type == "select") continue;
      List courseList = generalLessonMap[type];
      Log.d(courseList.toString());
      for (Map courseItem in courseList) {
        Widget courseItemWidget;
        courseItemWidget = Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(courseItem['name']),
              ),
              Text(type)
            ],
          ),
        );
        widgetList.add(courseItemWidget);
      }
    }

    return Container(
      child: AppExpansionTile(
        title: titleWidget,
        children: widgetList,
      ),
    );
  }

  Widget _buildOneSemesterItem(String semester, List courseList) {
    String semesterString = semester;
    List<Widget> widgetList = List();
    for (Map courseItem in courseList) {
      widgetList.add(_buildCourseItem(courseItem));
    }
    Widget widget = _buildTile(semesterString);
    return Container(
      child: AppExpansionTile(
        title: widget,
        children: widgetList,
      ),
    );
  }

  Widget _buildTile(String title) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: new Material(
        //INK可以實現裝飾容器
        child: new Ink(
          //用ink圓角矩形
          // color: Colors.red,
          decoration: new BoxDecoration(
            //背景
            color: Colors.white,
            //設置四周圓角 角度
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            //設置四周邊框
            border: new Border.all(width: 1, color: Colors.red),
          ),
          child: new InkWell(
            //圓角設置,給水波紋也設置同樣的圓角
            //如果這裡不設置就會出現矩形的水波紋效果
            borderRadius: new BorderRadius.circular(25.0),
            child: Container(
              //設置 child 居中
              alignment: Alignment(0, 0),
              height: 50,
              width: 300,
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpiltLine() {
    return Container(
      color: Colors.black12,
      height: 1,
    );
  }

  Widget _buildCourseItem(Map courseItem) {
    TextStyle textStyle = TextStyle(fontSize: 16);
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: width * 0.6,
            child: Text(
              courseItem["name"],
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              courseItem["credit"].toString(),
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              courseItem["category"],
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              sprintf("%4s", [courseItem["score"]]),
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
