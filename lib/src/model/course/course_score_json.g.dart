// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_score_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScoreCreditJson _$CourseScoreCreditJsonFromJson(
        Map<String, dynamic> json) =>
    CourseScoreCreditJson(
      graduationInformation: json['graduationInformation'] == null
          ? null
          : GraduationInformationJson.fromJson(
              json['graduationInformation'] as Map<String, dynamic>),
      semesterCourseScoreList:
          (json['semesterCourseScoreList'] as List<dynamic>?)
              ?.map((e) =>
                  SemesterCourseScoreJson.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CourseScoreCreditJsonToJson(
        CourseScoreCreditJson instance) =>
    <String, dynamic>{
      'graduationInformation': instance.graduationInformation,
      'semesterCourseScoreList': instance.semesterCourseScoreList,
    };

GraduationInformationJson _$GraduationInformationJsonFromJson(
        Map<String, dynamic> json) =>
    GraduationInformationJson(
      lowCredit: json['lowCredit'] as int? ?? 0,
      courseTypeMinCredit:
          (json['courseTypeMinCredit'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as int),
      ),
      outerDepartmentMaxCredit: json['outerDepartmentMaxCredit'] as int? ?? 0,
      selectYear: json['selectYear'] as String?,
      selectDivision: json['selectDivision'] as String?,
      selectMatric: json['selectMatric'] as String? ?? '7',
      courseCodeList: (json['courseCodeList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GraduationInformationJsonToJson(
        GraduationInformationJson instance) =>
    <String, dynamic>{
      'selectYear': instance.selectYear,
      'selectMatric': instance.selectMatric,
      'selectDivision': instance.selectDivision,
      'lowCredit': instance.lowCredit,
      'outerDepartmentMaxCredit': instance.outerDepartmentMaxCredit,
      'courseTypeMinCredit': instance.courseTypeMinCredit,
      'courseCodeList': instance.courseCodeList,
    };

SemesterCourseScoreJson _$SemesterCourseScoreJsonFromJson(
        Map<String, dynamic> json) =>
    SemesterCourseScoreJson(
      semester: json['semester'] == null
          ? null
          : SemesterJson.fromJson(json['semester'] as Map<String, dynamic>),
      now: json['now'] == null
          ? null
          : RankJson.fromJson(json['now'] as Map<String, dynamic>),
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      courseScoreList: (json['courseScoreList'] as List<dynamic>?)
          ?.map((e) => CourseScoreInfoJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: json['history'] == null
          ? null
          : RankJson.fromJson(json['history'] as Map<String, dynamic>),
      performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 0,
      takeCredit: (json['takeCredit'] as num?)?.toDouble() ?? 0,
      totalCredit: (json['totalCredit'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$SemesterCourseScoreJsonToJson(
        SemesterCourseScoreJson instance) =>
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

RankJson _$RankJsonFromJson(Map<String, dynamic> json) => RankJson(
      course: json['course'] == null
          ? null
          : RankItemJson.fromJson(json['course'] as Map<String, dynamic>),
      department: json['department'] == null
          ? null
          : RankItemJson.fromJson(json['department'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RankJsonToJson(RankJson instance) => <String, dynamic>{
      'course': instance.course,
      'department': instance.department,
    };

RankItemJson _$RankItemJsonFromJson(Map<String, dynamic> json) => RankItemJson(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      rank: (json['rank'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$RankItemJsonToJson(RankItemJson instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'total': instance.total,
      'percentage': instance.percentage,
    };

CourseScoreInfoJson _$CourseScoreInfoJsonFromJson(Map<String, dynamic> json) =>
    CourseScoreInfoJson(
      courseId: json['courseId'] as String? ?? "",
      courseCode: json['courseCode'] as String? ?? "",
      nameZh: json['nameZh'] as String? ?? "",
      nameEn: json['nameEn'] as String? ?? "",
      score: json['score'] as String? ?? "",
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? "",
      openClass: json['openClass'] as String? ?? "",
    );

Map<String, dynamic> _$CourseScoreInfoJsonToJson(
        CourseScoreInfoJson instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'courseCode': instance.courseCode,
      'nameZh': instance.nameZh,
      'nameEn': instance.nameEn,
      'score': instance.score,
      'credit': instance.credit,
      'openClass': instance.openClass,
      'category': instance.category,
    };
