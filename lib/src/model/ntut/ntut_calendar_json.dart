import 'package:json_annotation/json_annotation.dart';

part 'ntut_calendar_json.g.dart';

List<NTUTCalendarJson> getNTUTCalendarJsonList(List<dynamic> list) {
  final List<NTUTCalendarJson> result = [];

  list.forEach((item) {
    final value = NTUTCalendarJson.fromJson(item);
    if (value.calTitle.isNotEmpty) {
      result.add(value);
    }
  });

  return result;
}

@JsonSerializable()
class NTUTCalendarJson {
  @JsonKey(name: 'id')
  late final int id;

  @JsonKey(name: 'calStart')
  late final int calStart;

  @JsonKey(name: 'calEnd')
  late final int calEnd;

  @JsonKey(name: 'allDay')
  late final String allDay;

  @JsonKey(name: 'calTitle')
  late final String calTitle;

  @JsonKey(name: 'calPlace')
  late final String calPlace;

  @JsonKey(name: 'calContent')
  late final String calContent;

  @JsonKey(name: 'calColor')
  late final String calColor;

  @JsonKey(name: 'ownerId')
  late final String ownerId;

  @JsonKey(name: 'ownerName')
  late final String ownerName;

  @JsonKey(name: 'creatorId')
  late final String creatorId;

  @JsonKey(name: 'creatorName')
  late final String creatorName;

  @JsonKey(name: 'modifierId')
  late final String modifierId;

  @JsonKey(name: 'modifierName')
  late final String modifierName;

  @JsonKey(name: 'modifyDate')
  late final int modifyDate;

  @JsonKey(name: 'hasBeenDeleted')
  late final int hasBeenDeleted;

  @JsonKey(name: 'calInviteeList')
  late final List<dynamic> calInviteeList;

  @JsonKey(name: 'calAlertList')
  late final List<dynamic> calAlertList;

  NTUTCalendarJson(
    this.id,
    this.calStart,
    this.calEnd,
    this.allDay,
    this.calTitle,
    this.calPlace,
    this.calContent,
    this.calColor,
    this.ownerId,
    this.ownerName,
    this.creatorId,
    this.creatorName,
    this.modifierId,
    this.modifierName,
    this.modifyDate,
    this.hasBeenDeleted,
    this.calInviteeList,
    this.calAlertList,
  );

  factory NTUTCalendarJson.fromJson(Map<String, dynamic> srcJson) =>
      _$NTUTCalendarJsonFromJson(srcJson);

  @override
  String toString() => calTitle;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(calStart, isUtc: true)
          .add(new Duration(hours: 8));

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(calEnd, isUtc: true)
          .add(new Duration(hours: 8));
}
