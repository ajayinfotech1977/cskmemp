import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/notification_parents/api_service.dart';
import 'package:cskmemp/notification_parents/model/student_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

String teacherUserNo = AppConfig.globalUserNo;
bool _isFetching = true;

class NotificationSelectedParents extends StatefulWidget {
  @override
  _NotificationSelectedParentsState createState() =>
      _NotificationSelectedParentsState();
}

class _NotificationSelectedParentsState
    extends State<NotificationSelectedParents> {
  late Future<List<StudentModel>> _studentsFuture;
  List<StudentModel> students = [];
  List<StudentModel> selectedStudents = [];
  TextEditingController messageController = TextEditingController();
  bool isSending = false;

  final ApiService apiService = ApiService();

  AsyncSnapshot<List<StudentModel>>? snapshotData;

  @override
  void initState() {
    _isFetching = true;
    super.initState();

    _studentsFuture = apiService.getStudents(teacherUserNo);
    _studentsFuture.then((studentsData) {
      setState(() {
        students = studentsData;
        _isFetching = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isFetching
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Students:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return CheckboxListTile(
                        title: Text(
                          '${student.st_name} (${student.adm_no}) - ${student.st_class} / ${student.st_section} - ${student.feecategory}',
                          style: TextStyle(
                            color: student.isAppInstalled
                                ? Colors.black
                                : Colors.red,
                          ),
                        ),
                        value: selectedStudents.contains(student),
                        onChanged: student.isAppInstalled
                            ? (bool? value) {
                                setState(() {
                                  if (value!) {
                                    selectedStudents.add(student);
                                  } else {
                                    selectedStudents.remove(student);
                                  }
                                });
                              }
                            : null,
                        tileColor: selectedStudents.contains(student)
                            ? Colors.lightBlue.withOpacity(0.5)
                            : null,
                        checkColor: Colors.white,
                        activeColor:
                            student.isAppInstalled ? null : Colors.grey,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Message:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () {
                          // Implement the logic to send notifications here
                          if (selectedStudents.isNotEmpty &&
                              messageController.text.isNotEmpty) {
                            // Implement the logic to send notifications here
                            sendNotifications();
                          } else if (selectedStudents.isEmpty) {
                            EasyLoading.showError('Please select students.',
                                duration: Duration(seconds: 2));
                          } else if (messageController.text.isEmpty) {
                            EasyLoading.showError('Please type a message.',
                                duration: Duration(seconds: 2));
                          }
                        },
                  child: isSending
                      ? CircularProgressIndicator()
                      : Text('Send Notification'),
                ),
              ],
            ),
          );
  }

  // Implement the logic to send notifications
  void sendNotifications() {
    // close the keypad
    FocusScope.of(context).unfocus();
    isSending = true;
    EasyLoading.show(status: 'Sending...');
    apiService
        .sendNotifications(
            selectedStudents, messageController.text, teacherUserNo)
        .then((value) {
      EasyLoading.dismiss();
      isSending = false;
      if (value == "success") {
        EasyLoading.showSuccess('Notification sent successfully.',
            duration: Duration(seconds: 2));
        setState(() {
          selectedStudents.clear();
          messageController.clear();
        });
      } else {
        EasyLoading.dismiss();
        isSending = false;
        EasyLoading.showError('Failed to send notification.',
            duration: Duration(seconds: 2));
      }
    });
  }
}
