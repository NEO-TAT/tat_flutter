// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/course/course_extra_info_task.dart';
import 'package:flutter_app/src/task/score/score_rank_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/ui/other/app_expansion_tile.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/other/progress_rate_dialog.dart';
import 'package:flutter_app/ui/pages/score/app_bar_action_buttons.dart';
import 'package:flutter_app/ui/pages/score/course_score_section.dart';
import 'package:flutter_app/ui/pages/score/graduation_picker.dart';
import 'package:flutter_app/ui/pages/score/rank_grade_metrics.dart';
import 'package:flutter_app/ui/pages/score/semester_score_grade_metrics.dart';
import 'package:flutter_app/ui/pages/score/widgets/calculation_warning_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class ScoreViewerPage extends StatefulWidget {
  const ScoreViewerPage({super.key});

  @override
  State<ScoreViewerPage> createState() => _ScoreViewerPageState();
}

class _ScoreViewerPageState extends State<ScoreViewerPage> with TickerProviderStateMixin {
  static bool appExpansionInitiallyExpanded = false;

  TabController? _tabController;
  late CourseScoreCreditJson courseScoreCredit;

  final List<SemesterCourseScoreJson> courseScoreList = [];
  final ScrollController _scrollController = ScrollController();
  final List<Widget> tabLabelList = [];
  final List<Widget> tabChildList = [];

  int _currentTabIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    courseScoreCredit = LocalStorage.instance.getCourseScoreCredit();
    courseScoreList.addAll(LocalStorage.instance.getSemesterCourseScore());

    if (courseScoreList.isEmpty) {
      _addScoreRankTask();
    } else {
      _buildTabBar();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addScoreRankTask() async {
    courseScoreList.clear();

    setState(() {
      isLoading = true;
    });

    final taskFlow = TaskFlow();
    final scoreTask = ScoreRankTask();
    taskFlow.addTask(scoreTask);

    if (await taskFlow.start()) {
      courseScoreList
        ..clear()
        ..addAll(scoreTask.result ?? const []);
    }

    if (courseScoreList.isNotEmpty) {
      await LocalStorage.instance.setSemesterCourseScore(courseScoreList);
      int total = courseScoreCredit.getCourseInfoList().length;
      final courseInfoList = courseScoreCredit.getCourseInfoList();
      // ignore: use_build_context_synchronously
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
        courseScoreInfo.category = extraInfo.course.category;
        courseScoreInfo.openClass = extraInfo.course.openClass.replaceAll("\n", " ");
      };

      await taskFlow.start();
      await LocalStorage.instance.setSemesterCourseScore(courseScoreList);
      progressRateDialog.hide();
    } else {
      MyToast.show(R.current.searchCreditIsNullWarning);
    }

    _buildTabBar();
    setState(() {
      isLoading = false;
    });
  }

  void _onSelectFinish(GraduationInformationJson? value) {
    Log.d(value.toString());
    if (value != null) {
      courseScoreCredit.graduationInformation = value;
      LocalStorage.instance.setCourseScoreCredit(courseScoreCredit);
      LocalStorage.instance.saveCourseScoreCredit();
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
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: tabLabelList.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(R.current.searchScore),
            actions: [
              if (courseScoreList.isNotEmpty)
                ScorePageAppBarActionButtons(
                  onRefreshPressed: _addScoreRankTask,
                  onCalculateCreditPressed: _addSearchCourseTypeTask,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.mainColor,
              unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: Theme.of(context).colorScheme.onPrimary,
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
                if (!isLoading) (tabChildList.isNotEmpty) ? tabChildList[_currentTabIndex] : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      );

  void _buildTabBar() {
    tabLabelList.clear();
    tabChildList.clear();

    try {
      if (courseScoreCredit.graduationInformation.isSelect) {
        tabLabelList.add(_buildTabLabel(R.current.creditSummary));
        tabChildList.add(
          AnimationLimiter(
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
                  const ScoreCalculationWarning(),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
    }

    for (int i = 0; i < courseScoreList.length; i++) {
      final courseScore = courseScoreList[i];
      tabLabelList.add(_buildTabLabel("${courseScore.semester.year}-${courseScore.semester.semester}"));
      tabChildList.add(_buildSemesterScores(courseScore));
    }

    if (_tabController != null) {
      if (tabChildList.length != _tabController?.length) {
        _tabController?.dispose();
        _tabController = TabController(length: tabChildList.length, vsync: this);
      }
    } else {
      _tabController = TabController(length: tabChildList.length, vsync: this);
    }

    _currentTabIndex = 0;
    _tabController?.animateTo(_currentTabIndex);
    setState(() {});
  }

  Widget _buildTabLabel(String title) => Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
        ),
        child: Tab(
          text: title,
        ),
      );

  Widget _buildTile(String title) => Container(
      height: 50,
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        border: Border.all(
          width: 2,
          color: context.read<AppProvider>().theme.colorScheme.tertiary,
        ),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center
        ),
      ),
    );

  Widget _buildSummary() {
    final List<Widget> widgetList = [];
    final graduationInformation = courseScoreCredit.graduationInformation;

    final widget = _buildTile(sprintf("%s %d/%d", [
      R.current.creditSummary,
      courseScoreCredit.getTotalCourseCredit(),
      graduationInformation.lowCredit,
    ]));

    widgetList
      ..add(_buildType(constCourseType[0], R.current.compulsoryCompulsory))
      ..add(_buildType(constCourseType[1], R.current.revisedCommonCompulsory))
      ..add(_buildType(constCourseType[2], R.current.jointElective))
      ..add(_buildType(constCourseType[3], R.current.compulsoryProfessional))
      ..add(_buildType(constCourseType[4], R.current.compulsoryMajorRevision))
      ..add(_buildType(constCourseType[5], R.current.professionalElectives));

    return AppExpansionTile(
      title: widget,
      initiallyExpanded: appExpansionInitiallyExpanded,
      children: widgetList,
    );
  }

  Widget _buildGeneralLessonItem() {
    final generalLesson = courseScoreCredit.getGeneralLesson();
    final List<Widget> widgetList = [];
    int selectCredit = 0;
    int coreCredit = 0;

    for (final key in generalLesson.keys) {
      // FIXME: remove `!`.
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

    final titleWidget = _buildTile(sprintf("%s \n %s:%d %s:%d", [
      R.current.generalLessonSummary,
      R.current.takeCore,
      coreCredit,
      R.current.takeSelect,
      selectCredit,
    ]));

    return AppExpansionTile(
      title: titleWidget,
      initiallyExpanded: appExpansionInitiallyExpanded,
      children: widgetList,
    );
  }

  Widget _buildOtherDepartmentItem() {
    final department = LocalStorage.instance.getGraduationInformation().selectDepartment.substring(0, 2);
    final otherDepartmentMaxCredit = courseScoreCredit.graduationInformation.outerDepartmentMaxCredit;

    Map<String, List<CourseScoreInfoJson>> generalLesson = courseScoreCredit.getOtherDepartmentCourse(department);
    final List<Widget> widgetList = [];
    int otherDepartmentCredit = 0;

    for (final key in generalLesson.keys) {
      // FIXME: remove `!`.
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

    return AppExpansionTile(
      title: titleWidget,
      initiallyExpanded: appExpansionInitiallyExpanded,
      children: widgetList,
    );
  }

  Widget _buildType(String type, String title) {
    final nowCredit = courseScoreCredit.getCreditByType(type);
    final minCredit = courseScoreCredit.graduationInformation.courseTypeMinCredit[type];

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sprintf("%s%s :", [
                  type,
                  title,
                ]),
              ),
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
          // FIXME: remove `!`.
          for (final course in result[key]!) {
            courseInfo.add(sprintf("     %s", [course.name]));
          }
        }

        if (courseInfo.isNotEmpty) {
          Get.dialog(
            AlertDialog(
              title: Text(R.current.creditInfo),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: courseInfo.length,
                  itemBuilder: (_, index) {
                    return SizedBox(
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

  Widget _buildOneLineCourse(String name, String openClass) => Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Text(name),
            ),
            Text(openClass)
          ],
        ),
      );

  Widget _buildSemesterScores(SemesterCourseScoreJson courseScore) => Padding(
        padding: const EdgeInsets.all(24.0),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CourseScoreSection(scoreInfoList: courseScore.courseScoreList),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SemesterScoreGradeMetrics(
                    totalAverageScoreValue: courseScore.getAverageScoreString(),
                    performanceScoreValue: courseScore.getPerformanceScoreString(),
                    totalCreditValue: courseScore.getTotalCreditString(),
                    creditsEarnedValue: courseScore.getTakeCreditString(),
                  ),
                ),
                _buildRankMetrics(courseScore),
              ],
            ),
          ),
        ),
      );

  Widget _buildRankMetrics(SemesterCourseScoreJson courseScore) => (courseScore.isRankEmpty)
      ? Text(
          R.current.noRankInfo,
          style: const TextStyle(fontSize: 24),
        )
      : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RankGradeMetrics(
                title: R.current.semesterRanking,
                rankInfo: courseScore.now,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RankGradeMetrics(
                title: R.current.previousRankings,
                rankInfo: courseScore.history,
              ),
            ),
          ],
        );
}
