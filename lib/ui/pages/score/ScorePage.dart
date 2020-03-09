import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/costants/app_colors.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/score/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/AppExpansionTile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sprintf/sprintf.dart';

class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPageState createState() => _ScoreViewerPageState();
}

class _ScoreViewerPageState extends State<ScoreViewerPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<CourseScoreJson> courseScoreList = List();
  ScrollController _scrollController = ScrollController();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    courseScoreList = Model.instance.getCourseScoreList();
    if( courseScoreList.length == 0){
      _addTask();
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addTask() async {
    courseScoreList = List();
    setState(() {
      isLoading = true;
    });
    TaskHandler.instance.addTask(ScoreRankTask(context));
    await TaskHandler.instance.startTaskQueue(context);
    courseScoreList = Model.instance.getTempData(ScoreRankTask.tempDataKey);
    if( courseScoreList != null ){
      await Model.instance.setCourseScoreList(courseScoreList);
    }
    courseScoreList = courseScoreList ?? List();
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
    return DefaultTabController(
      length: courseScoreList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('成績查詢'),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                right: 20,
              ),
              child: GestureDetector(
                onTap: () {
                  _addTask();
                },
                child: Icon(EvaIcons.refreshOutline),
              ),
            ),
          ],
          bottom: _buildTabBar(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (!isLoading) _buildSemesterScores(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelColor: AppColors.mainColor,
      unselectedLabelColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
//      labelPadding: EdgeInsets.symmetric(horizontal: 8),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
      ),
      isScrollable: true,
      tabs: courseScoreList
          .map(
            (courseScore) => Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
              ),
              child: Tab(
                text:
                    "${courseScore.semester.year}-${courseScore.semester.semester}",
              ),
            ),
          )
          .toList(),
      onTap: (int index) {
        _currentTabIndex = index;
        setState(() {});
      },
    );
  }

  Widget _buildSemesterScores() {
    if (_currentTabIndex != null) {
      CourseScoreJson courseScore = courseScoreList[_currentTabIndex];

      return Container(
        padding: EdgeInsets.all(24.0),
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: <Widget>[
                ..._buildCourseScores(courseScore),
                SizedBox(height: 16),
                ..._buildSemesterScore(courseScore),
                SizedBox(height: 16),
                ..._buildRanks(courseScore),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  List<Widget> _buildCourseScores(CourseScoreJson courseScore) {
    List<ScoreJson> scoreList = courseScore.courseScoreList;

    return [
      _buildTitle('各科成績'),
      for (ScoreJson score in scoreList) _buildScoreItem(score),
    ];
  }

  Widget _buildScoreItem(ScoreJson score) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              score.name,
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              score.score.toString(),
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  List<Widget> _buildSemesterScore(CourseScoreJson courseScore) {
    return [
      _buildTitle('學期成績'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            sprintf("總平均: %s", [courseScore.getAverageScoreString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            sprintf("操行成績: %s", [courseScore.getPerformanceScoreString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            sprintf("修習學分: %s", [courseScore.getTotalCreditString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            sprintf("實得學分: %s", [courseScore.getTotalCreditString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
    ];
  }

  List<Widget> _buildRanks(CourseScoreJson courseScore) {
    return (courseScore.isRankEmpty)
        ? [
            Container(
              child: Text(
                "暫無排名資訊",
                style: TextStyle(fontSize: 24),
              ),
            )
          ]
        : [
            _buildRankItems(courseScore.now, "學期排名"),
            SizedBox(
              height: 16,
            ),
            _buildRankItems(courseScore.history, "歷屆排名"),
          ];
  }

  Widget _buildRankItems(RankJson rank, String title) {
    double fontSize = 16;
    TextStyle textStyle = TextStyle(fontSize: fontSize);
    return Column(
      children: <Widget>[
        _buildTitle(title),
        _buildRankPart(rank.course, textStyle),
        _buildRankPart(rank.department, textStyle),
        SizedBox(
          height: 8,
        ),
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

  Widget _buildTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
