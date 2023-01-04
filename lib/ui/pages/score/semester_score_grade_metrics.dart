import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/score/widgets/grade_metrics_cell_widget.dart';
import 'package:flutter_app/ui/pages/score/widgets/metrics_title_widget.dart';

class SemesterScoreGradeMetrics extends StatelessWidget {
  const SemesterScoreGradeMetrics({
    super.key,
    required String totalAverageScoreValue,
    required String performanceScoreValue,
    required String totalCreditValue,
    required String creditsEarnedValue,
  })  : _totalAverageScoreValue = totalAverageScoreValue,
        _performanceScoreValue = performanceScoreValue,
        _totalCreditValue = totalCreditValue,
        _creditsEarnedValue = creditsEarnedValue;

  final String _totalAverageScoreValue;
  final String _performanceScoreValue;
  final String _totalCreditValue;
  final String _creditsEarnedValue;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          MetricsTitle(title: R.current.semesterGrades),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            children: [
              GradeMetricsCell(
                name: R.current.totalAverage,
                value: _totalAverageScoreValue,
              ),
              GradeMetricsCell(
                name: R.current.performanceScores,
                value: _performanceScoreValue,
              ),
              GradeMetricsCell(
                name: R.current.practiceCredit,
                value: _totalCreditValue,
              ),
              GradeMetricsCell(
                name: R.current.creditsEarned,
                value: _creditsEarnedValue,
              ),
            ],
          ),
        ],
      );
}
