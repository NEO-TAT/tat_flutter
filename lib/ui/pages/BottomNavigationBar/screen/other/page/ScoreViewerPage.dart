import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/AppExpansionTile.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPage createState() => _ScoreViewerPage();
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

class _ScoreViewerPage extends State<ScoreViewerPage> {
  bool isLoading = true;
  List<CourseScoreJson> courseScoreList;
  ScrollController _scrollController = ScrollController();
  List<ExpansionTile> _expansionControlList = List();
  double deviceHeight;

  @override
  void initState() {
    super.initState();
    _addTask();
  }

  void _addTask() async {
    TaskHandler.instance.addTask(ScoreRankTask(context));
    await TaskHandler.instance.startTaskQueue(context);
    courseScoreList = Model.instance.tempData[ScoreRankTask.scoreRankTempKey];
    for (int i = 0; i <= courseScoreList.length; i++) {
      //增加展開控制器
      _expansionControlList.add((ExpansionTile()));
    }
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
        title: Text('成績查詢'),
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
      widgetList.add(_buildScoreItem(score));
    }
    widgetList.add(_buildSpiltLine());
    widgetList.add(_buildAverageScoreItem(courseScore));
    widgetList.add(_buildSpiltLine());
    widgetList.add(_buildRank(courseScore));

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

  Widget _buildScoreItem(ScoreJson score) {
    TextStyle textStyle = TextStyle(fontSize: 16);
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              score.name,
              style: textStyle,
            ),
          ),
          Text(
            score.score.toString(),
            style: textStyle,
          )
        ],
      ),
    );
  }

  Widget _buildAverageScoreItem(CourseScoreJson courseScore) {
    TextStyle textStyle = TextStyle(fontSize: 16);
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(sprintf("總平均: %s", [courseScore.getAverageScoreString()]),
                  style: textStyle),
              Text(
                  sprintf(
                      "操行成績: %s", [courseScore.getPerformanceScoreString()]),
                  style: textStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(sprintf("修習學分: %s", [courseScore.getTotalCreditString()]),
                  style: textStyle),
              Text(sprintf("實得學分: %s", [courseScore.getTotalCreditString()]),
                  style: textStyle),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRank(CourseScoreJson courseScore) {
    TextStyle textStyle = TextStyle(fontSize: 24);
    RankJson rankHistory = courseScore.history;
    RankJson rankNow = courseScore.now;
    return Container(
      child: Column(
          children: (courseScore.isRankEmpty)
              ? [
                  Container(
                    child: Text("暫無排名資訊", style: textStyle),
                  )
                ]
              : [
                  _buildRankItems(rankNow, "學期排名"),
                  _buildSpiltLine(),
                  _buildRankItems(rankHistory, "歷屆排名"),
                ]),
    );
  }

  Widget _buildRankItems(RankJson rank, String title) {
    double fontSize = 16;
    TextStyle textStyle = TextStyle(fontSize: fontSize);
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        _buildRankPart(rank.course, textStyle),
        _buildRankPart(rank.department, textStyle)
      ],
    );
  }

  Widget _buildRankPart(RankItemJson rankItem, [TextStyle textStyle]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(sprintf("班級排名: %s", [rankItem.rank.toString()]),
              textAlign: TextAlign.center, style: textStyle),
        ),
        Expanded(
          child: Text(sprintf("總共人數: %s", [rankItem.total.toString()]),
              textAlign: TextAlign.center, style: textStyle),
        ),
        Expanded(
          child: Text(sprintf("百分比: %s %", [rankItem.percentage.toString()]),
              textAlign: TextAlign.center, style: textStyle),
        ),
      ],
    );
  }
}
