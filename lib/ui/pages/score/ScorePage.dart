import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppColors.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/src/model/course/CourseScoreJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/course/CourseExtraInfoTask.dart';
import 'package:flutter_app/src/task/score/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/AppExpansionTile.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/other/ProgressRateDialog.dart';
import 'package:flutter_app/ui/pages/score/GraduationPicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPageState createState() => _ScoreViewerPageState();
}

class _ScoreViewerPageState extends State<ScoreViewerPage> with TickerProviderStateMixin {
  TabController _tabController;
  bool isLoading = true;
  List<SemesterCourseScoreJson> courseScoreList = [];
  CourseScoreCreditJson courseScoreCredit;
  ScrollController _scrollController = ScrollController();
  int _currentTabIndex = 0;
  List<Widget> tabLabelList = [];
  List<Widget> tabChildList = [];
  static bool appExpansionInitiallyExpanded = false;

  @override
  void initState() {
    super.initState();
    courseScoreCredit = Model.instance.getCourseScoreCredit();
    courseScoreList = Model.instance.getSemesterCourseScore();
    if (courseScoreList.length == 0) {
      _addScoreRankTask();
    } else {
      _buildTabBar();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addScoreRankTask() async {
    courseScoreList = [];
    setState(() {
      isLoading = true;
    });
    TaskFlow taskFlow = TaskFlow();
    var scoreTask = ScoreRankTask();
    taskFlow.addTask(scoreTask);
    if (await taskFlow.start()) {
      courseScoreList = scoreTask.result;
    }
    if (courseScoreList != null && courseScoreList.isNotEmpty) {
      await Model.instance.setSemesterCourseScore(courseScoreList);
      int total = courseScoreCredit.getCourseInfoList().length;
      List<CourseScoreInfoJson> courseInfoList = courseScoreCredit.getCourseInfoList();
      ProgressRateDialog progressRateDialog = ProgressRateDialog(context);
      progressRateDialog.update(message: R.current.searchingCredit, nowProgress: 0, progressString: "0/0");
      progressRateDialog.show();
      for (int i = 0; i < total; i++) {
        CourseScoreInfoJson courseInfo = courseInfoList[i];
        String courseId = courseInfo.courseId;
        if (courseInfo.category.isEmpty) {
          //沒有類別才尋找
          var task = CourseExtraInfoTask(courseId);
          task.openLoadingDialog = false;
          if (courseId.isNotEmpty) {
            taskFlow.addTask(task);
          }
        }
      }
      total = taskFlow.length;
      int rate = 0;
      taskFlow.callback = (task) {
        rate++;
        progressRateDialog.update(nowProgress: rate / total, progressString: sprintf("%d/%d", [rate, total]));
        CourseExtraInfoJson extraInfo = task.result;
        CourseScoreInfoJson courseScoreInfo = courseScoreCredit.getCourseByCourseId(extraInfo.course.id);
        courseScoreInfo.category = extraInfo.course.category;
        courseScoreInfo.openClass = extraInfo.course.openClass.replaceAll("\n", " ");
      };
      await taskFlow.start();
      await Model.instance.setSemesterCourseScore(courseScoreList);
      progressRateDialog.hide();
    } else {
      MyToast.show(R.current.searchCreditIsNullWarning);
    }
    courseScoreList = courseScoreList ?? [];
    _buildTabBar();
    setState(() {
      isLoading = false;
    });
  }

  void _onSelectFinish(GraduationInformationJson value) {
    Log.d(value.toString());
    if (value != null) {
      courseScoreCredit.graduationInformation = value;
      Model.instance.setCourseScoreCredit(courseScoreCredit);
      Model.instance.saveCourseScoreCredit();
    }
    _buildTabBar();
  }

  void _addSearchCourseTypeTask() async {
    GraduationPicker picker = GraduationPicker(context);
    picker.show(_onSelectFinish);
    _buildTabBar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _onPopupMenuSelect(int value) async {
    switch (value) {
      case 0:
        _addScoreRankTask();
        break;
      case 1:
        _addSearchCourseTypeTask();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabLabelList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(R.current.searchScore),
          actions: [
            if (courseScoreList.length > 0)
              PopupMenuButton<int>(
                onSelected: (result) {
                  setState(() {
                    _onPopupMenuSelect(result);
                  });
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(R.current.refresh),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(R.current.calculationCredit),
                  ),
                ],
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
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
            tabs: tabLabelList,
            onTap: (int index) {
              _currentTabIndex = index;
              setState(() {});
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (!isLoading) (tabChildList.length > 0) ? tabChildList[_currentTabIndex] : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _buildTabBar() {
    tabLabelList = [];
    tabChildList = [];
    try {
      if (courseScoreCredit.graduationInformation.isSelect) {
        tabLabelList.add(_buildTabLabel(R.current.creditSummary));
        tabChildList.add(StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: <Widget>[
                    _buildSummary(),
                    _buildGeneralLessonItem(),
                    _buildOtherDepartmentItem(),
                    _buildWarning(),
                  ],
                ),
              ),
            );
          },
        ));
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
    }
    for (int i = 0; i < courseScoreList.length; i++) {
      SemesterCourseScoreJson courseScore = courseScoreList[i];
      tabLabelList.add(_buildTabLabel("${courseScore.semester.year}-${courseScore.semester.semester}"));
      tabChildList.add(_buildSemesterScores(courseScore));
    }
    if (_tabController != null) {
      if (tabChildList.length != _tabController.length) {
        _tabController.dispose();
        _tabController = TabController(length: tabChildList.length, vsync: this);
      }
    } else {
      _tabController = TabController(length: tabChildList.length, vsync: this);
    }
    _currentTabIndex = 0;
    _tabController.animateTo(_currentTabIndex);
    setState(() {});
  }

  Widget _buildTabLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Tab(
        text: title,
      ),
    );
  }

  Widget _buildTile(String title) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Material(
        //INK可以實現裝飾容器
        child: Ink(
          //用ink圓角矩形
          // color: Colors.red,
          decoration: BoxDecoration(
            //設置四周圓角 角度
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            //設置四周邊框
            border: Border.all(width: 1, color: Colors.red),
          ),
          child: InkWell(
            //圓角設置,給水波紋也設置同樣的圓角
            //如果這裡不設置就會出現矩形的水波紋效果
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              //設置 child 居中
              alignment: Alignment(0, 0),
              height: 50,
              width: 300,
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    List<Widget> widgetList = [];
    GraduationInformationJson graduationInformation = courseScoreCredit.graduationInformation;
    Widget widget = _buildTile(sprintf("%s %d/%d",
        [R.current.creditSummary, courseScoreCredit.getTotalCourseCredit(), graduationInformation.lowCredit]));
    widgetList
      ..add(_buildType(constCourseType[0], R.current.compulsoryCompulsory))
      ..add(_buildType(constCourseType[1], R.current.revisedCommonCompulsory))
      ..add(_buildType(constCourseType[2], R.current.jointElective))
      ..add(_buildType(constCourseType[3], R.current.compulsoryProfessional))
      ..add(_buildType(constCourseType[4], R.current.compulsoryMajorRevision))
      ..add(_buildType(constCourseType[5], R.current.professionalElectives));
    return Container(
      child: AppExpansionTile(
        title: widget,
        children: widgetList,
        initiallyExpanded: appExpansionInitiallyExpanded,
      ),
    );
  }

  Widget _buildType(String type, String title) {
    int nowCredit = courseScoreCredit.getCreditByType(type);
    int minCredit = courseScoreCredit.graduationInformation.courseTypeMinCredit[type];
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(sprintf("%s%s :", [
                type,
                title,
              ])),
            ),
            Text(sprintf("%d/%d", [nowCredit, minCredit]))
          ],
        ),
      ),
      onTap: () {
        Map<String, List<CourseScoreInfoJson>> result = courseScoreCredit.getCourseByType(type);
        List<String> courseInfo = [];
        for (String key in result.keys.toList()) {
          courseInfo.add(key);
          for (CourseScoreInfoJson course in result[key]) {
            courseInfo.add(sprintf("     %s", [course.name]));
          }
        }
        if (courseInfo.length != 0) {
          Get.dialog(
            AlertDialog(
              title: Text(R.current.creditInfo),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: courseInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 35,
                      child: Text(courseInfo[index]),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(R.current.sure),
                ),
              ],
            ),
            barrierDismissible: true,
          );
        }
      },
    );
  }

  Widget _buildOneLineCourse(String name, String openClass) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(name),
          ),
          Text(openClass)
        ],
      ),
    );
  }

  Widget _buildGeneralLessonItem() {
    Map<String, List<CourseScoreInfoJson>> generalLesson = courseScoreCredit.getGeneralLesson();
    List<Widget> widgetList = [];
    int selectCredit = 0;
    int coreCredit = 0;
    for (String key in generalLesson.keys) {
      for (CourseScoreInfoJson course in generalLesson[key]) {
        if (course.isCoreGeneralLesson) {
          coreCredit += course.credit.toInt();
        } else {
          selectCredit += course.credit.toInt();
        }
        Widget courseItemWidget;
        courseItemWidget = _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    Widget titleWidget = _buildTile(sprintf("%s \n %s:%d %s:%d",
        [R.current.generalLessonSummary, R.current.takeCore, coreCredit, R.current.takeSelect, selectCredit]));
    return Container(
      child: AppExpansionTile(
        title: titleWidget,
        children: widgetList,
        initiallyExpanded: appExpansionInitiallyExpanded,
      ),
    );
  }

  Widget _buildOtherDepartmentItem() {
    String department = Model.instance.getGraduationInformation().selectDepartment;
    int otherDepartmentMaxCredit = courseScoreCredit.graduationInformation.outerDepartmentMaxCredit;
    try {
      department = department.substring(0, 2);
      Log.d(department);
    } catch (e) {}
    Map<String, List<CourseScoreInfoJson>> generalLesson = courseScoreCredit.getOtherDepartmentCourse(department);
    List<Widget> widgetList = [];
    int otherDepartmentCredit = 0;
    for (String key in generalLesson.keys) {
      for (CourseScoreInfoJson course in generalLesson[key]) {
        otherDepartmentCredit += course.credit.toInt();
        Widget courseItemWidget;
        courseItemWidget = courseItemWidget = _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    Widget titleWidget = _buildTile(sprintf("%s: %d  %s: %d", [
      R.current.takeForeignDepartmentCredits,
      otherDepartmentCredit,
      R.current.takeForeignDepartmentCreditsLimit,
      otherDepartmentMaxCredit
    ]));
    return Container(
      child: AppExpansionTile(
        title: titleWidget,
        children: widgetList,
        initiallyExpanded: appExpansionInitiallyExpanded,
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              R.current.scoreCalculationWarring,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterScores(SemesterCourseScoreJson courseScore) {
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

  List<Widget> _buildCourseScores(SemesterCourseScoreJson courseScore) {
    List<CourseScoreInfoJson> scoreList = courseScore.courseScoreList;
    return [
      _buildTitle(R.current.resultsOfVariousSubjects),
      for (CourseScoreInfoJson score in scoreList) _buildScoreItem(score),
    ];
  }

  Widget _buildScoreItem(CourseScoreInfoJson score) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      int typeSelect = constCourseType.indexOf(score.category);
      return Column(
        children: <Widget>[
          Container(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: AutoSizeText(
                    score.name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                if (score.category.isNotEmpty)
                  DropdownButton(
                      underline: Container(),
                      value: typeSelect,
                      items: constCourseType
                          .map((e) => DropdownMenuItem(
                                child: Text(
                                  e,
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: constCourseType.indexOf(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          typeSelect = value;
                          score.category = constCourseType[typeSelect];
                          /*
                        print(courseScoreList
                            .map((e) => e.courseScoreList
                                .map((k) => k.category)
                                .toList())
                            .toList());
                         */
                          //存檔
                          Model.instance.setCourseScoreCredit(courseScoreCredit);
                          Model.instance.saveCourseScoreCredit();
                        });
                      }),
                Container(
                  width: 40,
                  child: Text(score.score, style: TextStyle(fontSize: 16.0), textAlign: TextAlign.end),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      );
    });
  }

  List<Widget> _buildSemesterScore(SemesterCourseScoreJson courseScore) {
    return [
      _buildTitle(R.current.semesterGrades),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              sprintf("%s: %s", [R.current.totalAverage, courseScore.getAverageScoreString()]),
              style: TextStyle(fontSize: 16),
              maxLines: 1,
            ),
          ),
          Expanded(
            child: AutoSizeText(
              sprintf("%s: %s", [R.current.performanceScores, courseScore.getPerformanceScoreString()]),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16),
              maxLines: 1,
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
          Expanded(
            child: AutoSizeText(
              sprintf(
                "%s: %s",
                [R.current.practiceCredit, courseScore.getTotalCreditString()],
              ),
              style: TextStyle(fontSize: 16),
              maxLines: 1,
            ),
          ),
          Expanded(
            child: AutoSizeText(
              sprintf("%s: %s", [R.current.creditsEarned, courseScore.getTakeCreditString()]),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16),
              maxLines: 1,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
    ];
  }

  List<Widget> _buildRanks(SemesterCourseScoreJson courseScore) {
    return (courseScore.isRankEmpty)
        ? [
            Container(
              child: Text(
                R.current.noRankInfo,
                style: TextStyle(fontSize: 24),
              ),
            )
          ]
        : [
            _buildRankItems(courseScore.now, R.current.semesterRanking),
            SizedBox(
              height: 16,
            ),
            _buildRankItems(courseScore.history, R.current.previousRankings),
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
          child: AutoSizeText(
            sprintf("%s: %s    %s: %s    %s: %s% ", [
              R.current.rank,
              rankItem.rank.toString(),
              R.current.totalPeople,
              rankItem.total.toString(),
              R.current.percentage,
              rankItem.percentage.toString()
            ]),
            style: textStyle,
            minFontSize: 10,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
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
