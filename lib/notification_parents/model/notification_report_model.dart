import 'package:intl/intl.dart';

class NotificationModel {
  final String message;
  final String sentTo;
  final DateTime notificationDate;

  NotificationModel({
    required this.message,
    required this.sentTo,
    required this.notificationDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'],
      sentTo: json['sentTo'],
      notificationDate:
          DateFormat('dd-MMM-yyyy hh:mm a').parse(json['notificationDate']),
    );
  }
}
