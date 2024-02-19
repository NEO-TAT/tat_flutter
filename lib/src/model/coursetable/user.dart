import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String id;
  String name;
  String className;

  User.origin()
      : id = "",
        name = "",
        className = "";

  User({required this.id, required this.name, required this.className}) {
    id = id;
    name = name;
    className = className;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
