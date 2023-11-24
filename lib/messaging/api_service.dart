import 'dart:convert';
import 'package:cskmemp/messaging/model/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/messaging/model/student_model.dart';
import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/database/database_helper.dart';

class ApiService {
  static const String baseUrl = 'https://www.cskm.com/schoolexpert/cskmemp';

  Future<void> syncMessages() async {
    try {
      // call DatabaseHelper class to get data from table
      final dbHelper = DatabaseHelper();
      final _db = await dbHelper.initDatabase();
      await dbHelper.createTableMessages(_db, 1);
      // sync data from server
      await dbHelper.syncDataToMessages();

      dbHelper.close();
      print("syncMessages completed");
    } catch (Exception) {
      print("syncMessages Exception: $Exception");
    }
  }

  Future<List<StudentModel>> getStudents(String userNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_students.php'),
      body: {
        'userNo': userNo,
        'secretKey': AppConfig.secreetKey,
      },
    );
    syncMessages();
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      // return List<StudentModel>.from(
      //     //employees = List<Map<String, dynamic>>.from(data['employees']);
      //     jsonData['students'].map((json) => StudentModel.fromJson(json)));
      var studentList = List<StudentModel>.from(
          jsonData['students'].map((json) => StudentModel.fromJson(json)));

      studentList.sort((a, b) {
        // Sort by noOfUnreadMessages in descending order
        var result = b.noOfUnreadMessages.compareTo(a.noOfUnreadMessages);
        if (result != 0) {
          return result;
        }

        // If noOfUnreadMessages are equal, sort by st_name in ascending order
        return a.st_name.compareTo(b.st_name);
      });

      return studentList;
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> sendMessage(String fromNo, String toNo, String message) async {
    final response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmparents/send_message_to_parents.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': fromNo.toString(),
        'adm_no': toNo.toString(),
        'message': message,
      },
    );
    //print("response= ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<MessageModel>> getMessages(String fromNo, String toNo) async {
    final dbHelper = DatabaseHelper();
    // initialize database
    await dbHelper.initDatabase();
    // fetch data from database
    final data = await dbHelper.getDataFromMessages(fromNo, toNo);
    // print("fromNo= $fromNo, toNo= $toNo");
    // print(data);
    // convert data to List<MessageModel>
    List<MessageModel> messages = List.generate(data.length, (i) {
      return MessageModel.fromMap(data[i]);
    });
    // close database connection
    dbHelper.close();

    //print(messages);
    return messages;
  }

  // function to update the status of message to read for the userno and adm_no
  Future<void> updateMessageStatus(String adm_no, String userno) async {
    final dbHelper = DatabaseHelper();
    // initialize database
    await dbHelper.initDatabase();
    // update the status of message to read for the userno and adm_no
    await dbHelper.updateMessageStatusToR(adm_no, userno);
    // close database connection
    dbHelper.close();
  }
}
