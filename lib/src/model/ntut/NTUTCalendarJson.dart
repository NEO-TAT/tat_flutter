import 'package:json_annotation/json_annotation.dart';

part 'NTUTCalendarJson.g.dart';

List<NTUTCalendarJson> getNTUTCalendarJsonList(List<dynamic> list) {
  List<NTUTCalendarJson> result = [];
  list.forEach((item) {
    NTUTCalendarJson value = NTUTCalendarJson.fromJson(item);
    if (value.calTitle.isNotEmpty) {
      result.add(value);
    }
  });
  return result;
}

@JsonSerializable()
class NTUTCalendarJson {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'calStart')
  int calStart;

  @JsonKey(name: 'calEnd')
  int calEnd;

  @JsonKey(name: 'allDay')
  String allDay;

  @JsonKey(name: 'calTitle')
  String calTitle;

  @JsonKey(name: 'calPlace')
  String calPlace;

  @JsonKey(name: 'calContent')
  String calContent;

  @JsonKey(name: 'calColor')
  String calColor;

  @JsonKey(name: 'ownerId')
  String ownerId;

  @JsonKey(name: 'ownerName')
  String ownerName;

  @JsonKey(name: 'creatorId')
  String creatorId;

  @JsonKey(name: 'creatorName')
  String creatorName;

  @JsonKey(name: 'modifierId')
  String modifierId;

  @JsonKey(name: 'modifierName')
  String modifierName;

  @JsonKey(name: 'modifyDate')
  int modifyDate;

  @JsonKey(name: 'hasBeenDeleted')
  int hasBeenDeleted;

  @JsonKey(name: 'calInviteeList')
  List<dynamic> calInviteeList;

  @JsonKey(name: 'calAlertList')
  List<dynamic> calAlertList;

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

  factory NTUTCalendarJson.fromJson(Map<String, dynamic> srcJson) => _$NTUTCalendarJsonFromJson(srcJson);

  @override
  String toString() {
    return calTitle;
  }

  DateTime get startTime {
    return DateTime.fromMillisecondsSinceEpoch(calStart, isUtc: true).add(Duration(hours: 8));
  }

  DateTime get endTime {
    return DateTime.fromMillisecondsSinceEpoch(calEnd, isUtc: true).add(Duration(hours: 8));
  }
}
