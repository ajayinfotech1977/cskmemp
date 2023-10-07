import 'dart:convert';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Notification {
  final String date;
  final String time;
  final String message;
  final String status;

  Notification({
    required this.date,
    required this.time,
    required this.message,
    required this.status,
  });
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notification> _notifications = [];
  bool fetched = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmemp/show_notifications.php'),
      body: {
        'userNo': AppConfig.globalUserNo,
        'secretKey': AppConfig.secreetKey,
      },
    );
    //print("response is ${response.body}");
    if (response.statusCode == 200) {
      // show response.body in console
      fetched = true;
      final data = json.decode(response.body);

      _notifications = List<Notification>.from(
          data['notifications'].map((notification) => Notification(
                date: notification['date'],
                time: notification['time'],
                message: notification['message'],
                status: notification['status'],
              )));
      setState(() {});
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: _notifications.isEmpty && !fetched
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Text('No Notification is yet sent to you'),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Column(
                      children: [
                        Card(
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: notification.status == 'U'
                              ? Colors.yellow[100]
                              : Colors.white,
                          child: ListTile(
                            title: notification.status == 'U'
                                ? Text(
                                    notification.message,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )
                                : Text(
                                    notification.message,
                                    style: TextStyle(color: Colors.black),
                                  ),
                            subtitle: Text(
                              '${notification.date} ${notification.time}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
