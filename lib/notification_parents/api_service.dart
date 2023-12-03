import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/notification_parents/model/student_model.dart';
import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/notification_parents/model/notification_report_model.dart';

class ApiService {
  static const String baseUrl = 'https://www.cskm.com/schoolexpert/cskmparents';

  Future<List<StudentModel>> getStudents(String userNo) async {
    final response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/get_students.php'),
      body: {
        'userNo': userNo,
        'secretKey': AppConfig.secreetKey,
      },
    );

    if (response.statusCode == 200) {
      //print(response.body);
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      // return List<StudentModel>.from(
      //     //employees = List<Map<String, dynamic>>.from(data['employees']);
      //     jsonData['students'].map((json) => StudentModel.fromJson(json)));
      var studentList = List<StudentModel>.from(
          jsonData['students'].map((json) => StudentModel.fromJson(json)));

      return studentList;
    } else {
      EasyLoading.dismiss();
      throw Exception('Failed to load students');
    }
  }

  Future<List<NotificationModel>> getNotifications(String userNo) async {
    final response = await http.post(
      Uri.parse(
          "https://www.cskm.com/schoolexpert/cskmemp/notification_parents_sent.php"),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': AppConfig.globalUserNo,
      },
    );

    if (response.statusCode == 200) {
      //print(response.body);
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      // return List<StudentModel>.from(
      //     //employees = List<Map<String, dynamic>>.from(data['employees']);
      //     jsonData['students'].map((json) => StudentModel.fromJson(json)));
      var notificationList = List<NotificationModel>.from(
          jsonData['notifications']
              .map((json) => NotificationModel.fromJson(json)));

      // sort the notificationList in descending order of notificationDate
      notificationList.sort((a, b) {
        // Sort by notificationDate in descending order
        var result = b.notificationDate.compareTo(a.notificationDate);
        if (result != 0) {
          return result;
        }
        return result;
      });

      return notificationList;
    } else {
      EasyLoading.dismiss();
      throw Exception('Failed to load notifications');
    }
  }

  Future<String> sendNotifications(
      List<StudentModel> students, String message, String userNo) async {
    List<String> admNos = [];
    for (var student in students) {
      admNos.add(student.adm_no);
    }
    final response = await http.post(
      Uri.parse('$baseUrl/send_notification.php'),
      body: {
        'userNo': userNo,
        'message': message,
        'admNos': admNos.join(','),
        'secretKey': AppConfig.secreetKey,
      },
    );
    //print(response.body);
    if (response.statusCode == 200) {
      //final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      return "success";
    } else {
      EasyLoading.dismiss();
      throw Exception('Failed to send notification');
    }
  }
}
