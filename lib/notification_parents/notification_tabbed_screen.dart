import 'package:flutter/material.dart';
import 'package:cskmemp/notification_parents/broadcast_form.dart';
import 'package:cskmemp/notification_parents/students_form.dart';
import 'package:cskmemp/notification_parents/notification_report.dart';

class NotificationTabbedScreen extends StatefulWidget {
  @override
  _NotificationTabbedScreenState createState() =>
      _NotificationTabbedScreenState();
}

class _NotificationTabbedScreenState extends State<NotificationTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification - Parents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Broadcast'),
            Tab(text: 'Selected Students'),
            Tab(text: 'Report'),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return MessageForm(
      //             //onSave: (Message) {
      //             //Messages.add(Message);
      //             //},
      //             );
      //       },
      //     );
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Screen 1 content
          BroadcastForm(),
          // Screen 2 content
          Center(
            child: Container(
              height: double.infinity,
              child: Center(
                child: NotificationSelectedParents(),
              ),
            ),
          ),
          // Screen 3 content
          Center(
            child: Container(
              height: double.infinity,
              child: Center(
                child: NotificationReport(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
