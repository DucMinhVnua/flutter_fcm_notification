import 'dart:convert';

class MessageNotificationModel {
  final dynamic routeName;
  MessageNotificationModel({required this.routeName});

  factory MessageNotificationModel.fromJson(Map<String, dynamic> json) =>
      MessageNotificationModel(
        routeName: json['routeName'],
      );

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {'routeName': routeName};
  }
}
