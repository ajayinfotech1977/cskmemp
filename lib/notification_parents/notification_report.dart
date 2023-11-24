import 'package:intl/intl.dart';
import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/notification_parents/model/notification_report_model.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/notification_parents/api_service.dart';

class NotificationReport extends StatefulWidget {
  @override
  _NotificationReportState createState() => _NotificationReportState();
}

class _NotificationReportState extends State<NotificationReport> {
  late Future<List<NotificationModel>> _notificationsFuture;
  List<NotificationModel> notifications = [];
  final ApiService apiService = ApiService();
  bool _isFetching = true;

  @override
  void initState() {
    _isFetching = true;
    super.initState();
    _notificationsFuture = apiService.getNotifications(AppConfig.globalUserNo);
    _notificationsFuture.then((NotificationsData) {
      setState(() {
        notifications = NotificationsData;
        _isFetching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isFetching
        ? Center(
            child: CircularProgressIndicator(),
          )
        :
        // if notification count is 0 then show text in center no notification found
        notifications.length == 0
            ? Center(
                child: Text('No Notification sent by you'),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(notification.message),
                      subtitle: Text(
                          'Sent to: ${notification.sentTo} - ${DateFormat('dd-MMM-yyyy h:mm a').format(notification.notificationDate)}'),
                    );
                  },
                ),
              );
  }
}
