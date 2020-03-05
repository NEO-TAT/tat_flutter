import 'package:flutter/material.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sprintf/sprintf.dart';

class CreditViewerPage extends StatefulWidget {
  @override
  _CreditViewerPage createState() => _CreditViewerPage();
}

class ExpansionTile {
  double expansionHeight; //隱藏時高度
  double height; //關閉時高度
  int index;
  bool isExpansion;
  GlobalKey<AppExpansionTileState> key;

  ExpansionTile() {
    key = GlobalKey();
    isExpansion = false;
  }
}

class _CreditViewerPage extends State<CreditViewerPage> {
  bool isLoading = true;
  List<CourseScoreJson> courseScoreList;
  ScrollController _scrollController = ScrollController();
  List<ExpansionTile> _expansionControlList = List();
  Map<String, CourseExtraInfoJson> courseDetail = Map();
  double deviceHeight;

  @override
  void initState() {
    super.initState();
    _addTask();
  }

  void _addTask() async {
    TaskHandler.instance.addTask(ScoreRankTask(context));
    await TaskHandler.instance.startTaskQueue(context);
    courseScoreList =
        Model.instance.getTempData(ScoreRankTask.scoreRankTempKey);
    for (int i = 0; i < courseScoreList.length; i++) {
      CourseScoreJson course = courseScoreList[i];
      for (int j = 0; j < course.courseScoreList.length; j++) {
        String courseId = course.courseScoreList[j].courseId;
        TaskHandler.instance.addTask(TaskModelFunction(
            context, [CheckCookiesTask.checkCourse], () async {
          CourseExtraInfoJson courseInfo =
              await CourseConnector.getCourseExtraInfo(courseId);
          courseDetail[courseId] = courseInfo;
          return courseInfo == null ? false : true;
        }, () {
          ErrorDialogParameter parameter = ErrorDialogParameter(
            context: context,
            desc: R.current.getCourseDetailError,
          );
          ErrorDialog(parameter).show();
        }));
      }
      //增加展開控制器
      _expansionControlList.add((ExpansionTile()));
    }
    await TaskHandler.instance.startTaskQueue(context);
    deviceHeight = MediaQuery.of(context).size.height;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _buildComplete(double height, int index) async {
    if (isLoading) return;
    await Future.delayed(Duration(milliseconds: 400));
    double office = height * index + 10;
    _scrollController.animateTo(office,
        duration: Duration(seconds: 1), curve: Curves.ease);
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
    int length = courseScoreList.length;
    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
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
                    child: _buildOneSemesterItem(index, courseScoreList[index]),
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


  Widget _buildOneSemesterItem(int index, CourseScoreJson courseScore) {
    List<ScoreJson> scoreList = courseScore.courseScoreList;
    GlobalKey _myKey = new GlobalKey();
    String semesterString =
        courseScore.semester.year + "-" + courseScore.semester.semester;
    List<Widget> widgetList = List();

    for (ScoreJson score in scoreList) {
      widgetList.add(_buildCourseItem(score));
    }

    Widget widget = Container(
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
              child: Text(semesterString),
            ),
          ),
        ),
      ),
    );
    return Container(
      key: _myKey,
      child: AppExpansionTile(
        key: _expansionControlList[index].key,
        title: widget,
        children: widgetList,
        onExpansionChanged: (value) {
          _expansionControlList[index].isExpansion = value;
          if (value) {
            RenderObject renderObject =
                _myKey.currentContext.findRenderObject(); //找尋物件大小
            double height = renderObject.semanticBounds.size.height;
            for (int i = 0; i < courseScoreList.length; i++) {
              // 關閉其他視窗
              if (i != index) {
                _expansionControlList[i].key.currentState.collapse();
              }
            }
            _buildComplete(height, index);
          }
        },
      ),
    );
  }

  Widget _buildSpiltLine() {
    return Container(
      color: Colors.black12,
      height: 1,
    );
  }

  Widget _buildCourseItem(ScoreJson score) {
    TextStyle textStyle = TextStyle(fontSize: 16);
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: width * 0.15,
            child: Text(
              score.courseId,
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.45,
            child: Text(
              score.name,
              overflow : TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              score.credit.toInt().toString(),
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              courseDetail[score.courseId].course.category,
              style: textStyle,
            ),
          ),
          Container(
            width: width * 0.1,
            child: Text(
              sprintf("%4s", [score.score]),
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
