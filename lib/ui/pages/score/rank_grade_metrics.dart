// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/score/widgets/grade_metrics_cell_widget.dart';
import 'package:flutter_app/ui/pages/score/widgets/metrics_title_widget.dart';

class RankGradeMetrics extends StatelessWidget {
  const RankGradeMetrics({
    super.key,
    required String title,
    required RankJson rankInfo,
  })  : _title = title,
        _rankInfo = rankInfo;

  final String _title;
  final RankJson _rankInfo;

  Widget _buildSingleRankMetric(String categoryName, RankItemJson rankInfo) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '($categoryName)',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GradeMetricsCell(
                name: R.current.rank,
                value: '${rankInfo.rank.toInt()} / ${rankInfo.total.toInt()}',
              ),
              GradeMetricsCell(
                name: R.current.percentage,
                value: '${rankInfo.percentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final classRankInfo = _rankInfo.course;
    final departmentRankInfo = _rankInfo.department;

    return Column(
      children: [
        MetricsTitle(title: _title),
        _buildSingleRankMetric(R.current.kClass, classRankInfo),
        _buildSingleRankMetric(R.current.kDepartment, departmentRankInfo),
      ],
    );
  }
}
