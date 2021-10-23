import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_colors.dart';
import 'package:tat/src/model/course/course_score_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/course/course_extra_info_task.dart';
import 'package:tat/src/task/score/score_rank_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/ui/other/app_expansion_tile.dart';
import 'package:tat/ui/other/my_toast.dart';
import 'package:tat/ui/other/progress_rate_dialog.dart';
import 'package:tat/ui/pages/score/graduation_picker.dart';

class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPageState createState() => _ScoreViewerPageState();
}

class _ScoreViewerPageState extends State<ScoreViewerPage> with TickerProviderStateMixin {
  late TabController? _tabController;
  bool isLoading = true;
  List<SemesterCourseScoreJson>? courseScoreList = [];
  late CourseScoreCreditJson courseScoreCredit;
  final _scrollController = ScrollController();
  int _currentTabIndex = 0;
  List<Widget> tabLabelList = [];
  List<Widget> tabChildList = [];
  static bool appExpansionInitiallyExpanded = false;

  @override
  void initState() {
    super.initState();
    courseScoreCredit = Model.instance.getCourseScoreCredit();
    courseScoreList = Model.instance.getSemesterCourseScore();
    if (courseScoreList!.length == 0) {
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
    final taskFlow = TaskFlow();
    final scoreTask = ScoreRankTask();
    taskFlow.addTask(scoreTask);
    if (await taskFlow.start()) {
      courseScoreList = scoreTask.result;
    }
    if (courseScoreList != null && courseScoreList!.isNotEmpty) {
      await Model.instance.setSemesterCourseScore(courseScoreList!);
      int total = courseScoreCredit.getCourseInfoList().length;
      final courseInfoList = courseScoreCredit.getCourseInfoList();
      final progressRateDialog = ProgressRateDialog(context);
      progressRateDialog.update(message: R.current.searchingCredit, nowProgress: 0, progressString: "0/0");
      progressRateDialog.show();
      for (int i = 0; i < total; i++) {
        final courseInfo = courseInfoList[i];
        final courseId = courseInfo.courseId;
        if (courseInfo.category.isEmpty) {
          final task = CourseExtraInfoTask(courseId);
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
        final extraInfo = task.result;
        final courseScoreInfo = courseScoreCredit.getCourseByCourseId(extraInfo.course.id);
        courseScoreInfo!.category = extraInfo.course.category;
        courseScoreInfo.openClass = extraInfo.course.openClass.replaceAll("\n", " ");
      };
      await taskFlow.start();
      await Model.instance.setSemesterCourseScore(courseScoreList!);
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

  void _onSelectFinish(GraduationInformationJson? value) {
    Log.d(value.toString());
    if (value != null) {
      courseScoreCredit.graduationInformation = value;
      Model.instance.setCourseScoreCredit(courseScoreCredit);
      Model.instance.saveCourseScoreCredit();
    }
    _buildTabBar();
  }

  void _addSearchCourseTypeTask() {
    final picker = GraduationPicker(context);
    picker.show(_onSelectFinish);
    _buildTabBar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  _onPopupMenuSelect(int value) {
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
            if (courseScoreList!.length > 0)
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
            children: [
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
      if (courseScoreCredit.graduationInformation!.isSelect) {
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
                  children: [
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
    for (int i = 0; i < courseScoreList!.length; i++) {
      final courseScore = courseScoreList![i];
      tabLabelList.add(_buildTabLabel("${courseScore.semester!.year}-${courseScore.semester!.semester}"));
      tabChildList.add(_buildSemesterScores(courseScore));
    }
    if (_tabController != null) {
      if (tabChildList.length != _tabController!.length) {
        _tabController!.dispose();
        _tabController = TabController(length: tabChildList.length, vsync: this);
      }
    } else {
      _tabController = TabController(length: tabChildList.length, vsync: this);
    }
    _currentTabIndex = 0;
    _tabController!.animateTo(_currentTabIndex);
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
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            border: Border.all(width: 1, color: Colors.red),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
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
    final List<Widget> widgetList = [];
    final graduationInformation = courseScoreCredit.graduationInformation;
    final widget = _buildTile(sprintf("%s %d/%d",
        [R.current.creditSummary, courseScoreCredit.getTotalCourseCredit(), graduationInformation!.lowCredit]));
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
    final nowCredit = courseScoreCredit.getCreditByType(type);
    final minCredit = courseScoreCredit.graduationInformation!.courseTypeMinCredit![type];
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
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
        final result = courseScoreCredit.getCourseByType(type);
        final List<String> courseInfo = [];
        for (final key in result.keys.toList()) {
          courseInfo.add(key);
          for (final course in result[key]!) {
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
        children: [
          Expanded(
            child: Text(name),
          ),
          Text(openClass)
        ],
      ),
    );
  }

  Widget _buildGeneralLessonItem() {
    final generalLesson = courseScoreCredit.getGeneralLesson();
    final List<Widget> widgetList = [];
    int selectCredit = 0;
    int coreCredit = 0;
    for (final key in generalLesson.keys) {
      for (final course in generalLesson[key]!) {
        if (course.isCoreGeneralLesson) {
          coreCredit += course.credit.toInt();
        } else {
          selectCredit += course.credit.toInt();
        }
        final courseItemWidget = _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    final titleWidget = _buildTile(sprintf("%s \n %s:%d %s:%d",
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
    final divisionCode = Model.instance.getGraduationInformation().selectDivision;
    final otherDepartmentMaxCredit = courseScoreCredit.graduationInformation!.outerDepartmentMaxCredit;
    final generalLesson = courseScoreCredit.getOtherDepartmentCourse(divisionCode!);
    final List<Widget> widgetList = [];
    int otherDepartmentCredit = 0;
    for (final key in generalLesson.keys) {
      for (final course in generalLesson[key]!) {
        otherDepartmentCredit += course.credit.toInt();
        final courseItemWidget = _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    final titleWidget = _buildTile(sprintf("%s: %d  %s: %d", [
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
        children: [
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
            children: [
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
    final scoreList = courseScore.courseScoreList;
    return [
      _buildTitle(R.current.resultsOfVariousSubjects),
      for (final score in scoreList!) _buildScoreItem(score),
    ];
  }

  Widget _buildScoreItem(CourseScoreInfoJson score) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      int typeSelect = constCourseType.indexOf(score.category);
      return Column(
        children: [
          Container(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    score.name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                if (score.category.isNotEmpty)
                  DropdownButton<int>(
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
                          typeSelect = value as int;
                          score.category = constCourseType[typeSelect];
                          Model.instance.setCourseScoreCredit(courseScoreCredit);
                          Model.instance.saveCourseScoreCredit();
                        });
                      }),
                Container(
                  width: 40,
                  child: Text(
                    score.score,
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.end,
                  ),
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
        children: [
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
        children: [
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
            _buildRankItems(courseScore.now!, R.current.semesterRanking),
            SizedBox(
              height: 16,
            ),
            _buildRankItems(courseScore.history!, R.current.previousRankings),
          ];
  }

  Widget _buildRankItems(RankJson rank, String title) {
    const fontSize = 16.0;
    final textStyle = TextStyle(fontSize: fontSize);
    return Column(
      children: [
        _buildTitle(title),
        _buildRankPart(rank.course!, textStyle),
        _buildRankPart(rank.department!, textStyle),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildRankPart(RankItemJson rankItem, [TextStyle? textStyle]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
