import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppConfig {
  /*below is a secretkey encrypted key which will go with each post 
  request so that nobody else can view the php file response except 
  of this app. Please dont tamper ot change this value. Its equivalent 
  decrypted text should be "ILove@Flutter_dart" which will be checked by php
  file before fetching any kind of data.
  */
  static String secreetKey = "WhzWoMoZQO2pgmw6h6So0j0b";
  static String globalUserNo = "";
  static String globalEname = "";
  static bool? globalOthersPendingTasks = false;
  static bool? globalClassTeacher = false;
  static bool? globalIsOffSupdt = false;
  static bool? globalIsTptIncharge = false;
  static bool? globalIsHostelIncharge = false;
  static bool? globalIsAccountant = false;
  static bool? globalIsSubjectTeacher = false;
  static String globalFy = "";
  static bool? globalSelfSubjectMap = false;
  static String globalUserNoT = "";
  static String globalFyT = "";
  static int globalnotificationCount = 0;
  static int globalmessageCount = 0;
  static bool isNewMessage = false;
  static bool isChatScreenActive = false;
  static bool isNotificationScreenActive = false;
  static bool isNewNotification = false;

  static BoxDecoration boxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.purple,
          Colors.blue,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static TextStyle boldWhite30() {
    return const TextStyle(
      fontSize: 30,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle normalWhite15() {
    return const TextStyle(
      fontSize: 15,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite20() {
    return const TextStyle(
      fontSize: 20,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite() {
    return const TextStyle(
      color: Colors.white,
    );
  }

  static TextStyle normaYellow20() {
    return const TextStyle(
      fontSize: 20,
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  static TextStyle normaYellow() {
    return const TextStyle(
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  Future<String> checkLogin({
    @required userid,
    @required password1,
  }) async {
    //print("sending post request to server");
    try {
      var response = await http.post(
        Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/checkLogin.php'),
        body: {
          'username': userid,
          'password': password1,
          'encrypted': 'Yes',
        },
      );
      //print("response = ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var status = data['status'];
        if (status == 'valid') {
          var userNo = data['userNo'];
          var ename = data['ename'];
          var othersPendingTasks = data['othersPendingTasks'];
          var classTeacher = data['classTeacher'];
          var isOffSupdt = data['isOffSupdt'];
          var isTptIncharge = data['isTptIncharge'];
          var isHostelIncharge = data['isHostelIncharge'];
          var isAccountant = data['isAccountant'];
          var isSubjectTeacher = data['isSubjectTeacher'];
          var fy = data['fy'];
          var selfSubjectMap = data['selfSubjectMap'];
          var usernoT = data['usernoT'];
          var fyT = data['fyT'];
          var notificationCount = data['notificationCount'];
          var messageCount = data['messageCount'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('userNo', userNo);
          prefs.setString('ename', ename);
          prefs.setBool('othersPendingTasks', othersPendingTasks);
          prefs.setBool('classTeacher', classTeacher);
          prefs.setBool('isOffSupdt', isOffSupdt);
          prefs.setBool('isTptIncharge', isTptIncharge);
          prefs.setBool('isHostelIncharge', isHostelIncharge);
          prefs.setBool('isAccountant', isAccountant);
          prefs.setBool('isSubjectTeacher', isSubjectTeacher);
          prefs.setInt('fy', fy);
          prefs.setBool('selfSubjectMap', selfSubjectMap);
          prefs.setString('usernoT', usernoT);
          prefs.setString('fyT', fyT);
          prefs.setInt('notificationCount', notificationCount);
          prefs.setInt('messageCount', messageCount);

          await AppConfig.setGlobalVariables();
          // Navigate to the home screen
          return Future.value("valid");
        } else {
          // The login was unsuccessful
          logout();
          return Future.value("invalid");
        }
      }
      //if server is not reachable
      else if (response.statusCode == 500 || response.statusCode == 404) {
        //EasyLoading.showError("Server is not reachable");
        return Future.value("serverNotReachable");
      } else {
        // The login was unsuccessful
        //EasyLoading.showError(
        //"Server Problem! Please inform admin at 9312375581");
        return Future.value("serverDown");
      }
    } catch (Exception) {
      return Future.value("serverNotReachable");
    }
  }

  Future<String> getUserNo() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userNo')) {
      var userNo = prefs.getInt('userNo').toString();
      //print("From getUserNo userNo= $userNo");
      return userNo;
    } else {
      return "";
    }
  }

  Future<bool> isOthersPendingTasksAllowed() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('othersPendingTasks')) {
      bool othersPendingTasks = prefs.getBool('othersPendingTasks') as bool;
      //print("From getUserNo userNo= $userNo");
      return Future.value(othersPendingTasks);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> isClassTeacher() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('classTeacher')) {
      bool classTeacher = prefs.getBool('classTeacher') as bool;
      //print("From getUserNo userNo= $userNo");
      return Future.value(classTeacher);
    } else {
      return Future.value(false);
    }
  }

  static Future<void> logout() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    var userNo = prefs.getInt('userNo').toString();
    await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/logout.php'),
      body: {
        'userNo': userNo,
        'secretKey': secreetKey,
      },
    );

    await prefs.remove('userid');
    await prefs.remove('password1');
    await prefs.remove('userNo');
    await prefs.remove('ename');
    await prefs.remove('loggedInState');
    await prefs.remove('othersPendingTasks');
    await prefs.remove('classTeacher');
    await prefs.remove('isOffSupdt');
    await prefs.remove('isTptIncharge');
    await prefs.remove('isHostelIncharge');
    await prefs.remove('isAccountant');
    await prefs.remove('isSubjectTeacher');
    await prefs.remove('fy');
    await prefs.remove('selfSubjectMap');
    await prefs.remove('usernoT');
    await prefs.remove('fyT');
    await prefs.remove('notificationCount');
    await prefs.remove('messageCount');
  }

  static void configLoading() {
    EasyLoading easyLoading = EasyLoading();
    easyLoading.loadingStyle = EasyLoadingStyle.dark;
    //easyLoading.indicatorType = EasyLoadingIndicatorType.threeBounce;
    //easyLoading.maskType = EasyLoadingMaskType.black;
    //easyLoading.backgroundColor = Color.fromARGB(10, 83, 83, 83);
  }

  //make globally available variables for the app fetched from shared preferences
  static Future<void> setGlobalVariables() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userNo')) {
      var userNo = await prefs.getInt('userNo').toString();
      var ename = await prefs.getString('ename');
      var othersPendingTasks = await prefs.getBool('othersPendingTasks');
      var classTeacher = await prefs.getBool('classTeacher');
      var isOffSupdt = await prefs.getBool('isOffSupdt');
      var isTptIncharge = await prefs.getBool('isTptIncharge');
      var isHostelIncharge = await prefs.getBool('isHostelIncharge');
      var isAccountant = await prefs.getBool('isAccountant');
      var isSubjectTeacher = await prefs.getBool('isSubjectTeacher');
      var fy = await prefs.getInt('fy').toString();
      var selfSubjectMap = await prefs.getBool('selfSubjectMap');
      var usernoT = await prefs.getString('usernoT');
      var fyT = await prefs.getString('fyT');
      var notificationCount = await prefs.getInt('notificationCount');
      var messageCount = await prefs.getInt('messageCount');

      globalUserNo = userNo;
      globalEname = ename as String;
      globalOthersPendingTasks = othersPendingTasks;
      globalClassTeacher = classTeacher;
      globalIsOffSupdt = isOffSupdt;
      globalIsTptIncharge = isTptIncharge;
      globalIsHostelIncharge = isHostelIncharge;
      globalIsAccountant = isAccountant;
      globalIsSubjectTeacher = isSubjectTeacher;
      globalFy = fy;
      globalSelfSubjectMap = selfSubjectMap;
      globalUserNoT = usernoT as String;
      globalFyT = fyT as String;
      globalnotificationCount = notificationCount as int;
      globalmessageCount = messageCount as int;
    }
    // print("globalUserNo= $globalUserNo");
    // print("globalEname= $globalEname");
    // print("globalOthersPendingTasks= $globalOthersPendingTasks");
    // print("globalClassTeacher= $globalClassTeacher");
  }
}
