// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseScoreJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScoreJson _$CourseScoreJsonFromJson(Map<String, dynamic> json) {
  return CourseScoreJson(
    semester: json['semester'] == null
        ? null
        : SemesterJson.fromJson(json['semester'] as Map<String, dynamic>),
    now: json['now'] == null
        ? null
        : RankJson.fromJson(json['now'] as Map<String, dynamic>),
    averageScore: (json['averageScore'] as num)?.toDouble(),
    courseScoreList: (json['courseScoreList'] as List)
        ?.map((e) =>
            e == null ? null : ScoreJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    history: json['history'] == null
        ? null
        : RankJson.fromJson(json['history'] as Map<String, dynamic>),
    performanceScore: (json['performanceScore'] as num)?.toDouble(),
    takeCredit: (json['takeCredit'] as num)?.toDouble(),
    totalCredit: (json['totalCredit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$CourseScoreJsonToJson(CourseScoreJson instance) =>
    <String, dynamic>{
      'semester': instance.semester,
      'now': instance.now,
      'history': instance.history,
      'courseScoreList': instance.courseScoreList,
      'averageScore': instance.averageScore,
      'performanceScore': instance.performanceScore,
      'totalCredit': instance.totalCredit,
      'takeCredit': instance.takeCredit,
    };

RankJson _$RankJsonFromJson(Map<String, dynamic> json) {
  return RankJson(
    course: json['course'] == null
        ? null
        : RankItemJson.fromJson(json['course'] as Map<String, dynamic>),
    department: json['department'] == null
        ? null
        : RankItemJson.fromJson(json['department'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RankJsonToJson(RankJson instance) => <String, dynamic>{
      'course': instance.course,
      'department': instance.department,
    };

RankItemJson _$RankItemJsonFromJson(Map<String, dynamic> json) {
  return RankItemJson(
    percentage: (json['percentage'] as num)?.toDouble(),
    rank: (json['rank'] as num)?.toDouble(),
    total: (json['total'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$RankItemJsonToJson(RankItemJson instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'total': instance.total,
      'percentage': instance.percentage,
    };

ScoreJson _$ScoreJsonFromJson(Map<String, dynamic> json) {
  return ScoreJson(
    courseId: json['courseId'] as String,
    name: json['name'] as String,
    score: json['score'] as String,
    credit: (json['credit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ScoreJsonToJson(ScoreJson instance) => <String, dynamic>{
      'courseId': instance.courseId,
      'name': instance.name,
      'score': instance.score,
      'credit': instance.credit,
    };
