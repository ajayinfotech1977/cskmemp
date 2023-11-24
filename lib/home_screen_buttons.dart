import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/custom_data_stream.dart';
import 'package:cskmemp/messaging/message_tabbed_screen.dart';
import 'package:cskmemp/notifications_sreen.dart';

StreamController<CustomData> streamController =
    StreamController<CustomData>.broadcast();

class HomeScreenButtons extends StatefulWidget {
  const HomeScreenButtons({super.key});

  @override
  State<HomeScreenButtons> createState() => _HomeScreenButtonsState();
}

class _HomeScreenButtonsState extends State<HomeScreenButtons> {
  bool classTeacher = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    streamController.stream.listen((customData) {
      if (mounted) {
        // print('customData.form: ${customData.form}');
        // print('customData.count: ${customData.count}');
        setState(() {
          if (customData.form == 'message') {
            AppConfig.globalmessageCount =
                AppConfig.globalmessageCount - customData.count;
          } else if (customData.form == 'notification') {
            AppConfig.globalnotificationCount = customData.count;
          }
        });
      }
    });
  }

  //code to fetch classTeacher from SharedPreferences
  void openTasks(context) async {
    var totalTabs = 3;
    //final bool otherAllowed = await AppConfig().isOthersPendingTasksAllowed();
    //print("otherAllowed = $otherAllowed");
    if (AppConfig.globalOthersPendingTasks == true) totalTabs = 4;
    //print("totalTabs = $totalTabs");
    Navigator.pushNamed(context, '/tasktabbedscreen', arguments: totalTabs);
    //print("On Tap clicked from open Tasks");
  }

  void openMessages(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageTabbedScreen(
          stream: streamController,
        ),
      ),
    );
  }

  void openMarksEntry(context) {
    Navigator.pushNamed(context, '/marksentryscreen');
  }

  void openMarksEntryTermWise(context) {
    Navigator.pushNamed(context, '/marksentryscreentermwise');
  }

  void openGradesEntry(context) {
    Navigator.pushNamed(context, '/gradesentry');
  }

  void openRemarksEntry(context) {
    Navigator.pushNamed(context, '/remarksentry');
  }

  void openAttendanceEntry(context) {
    Navigator.pushNamed(context, '/attendanceentry');
  }

  void openTrainingDetailsEntry(context) {
    Navigator.pushNamed(context, '/trainingdetailsentry');
  }

  void openDuesList(context) {
    Navigator.pushNamed(context, '/dueslist');
  }

  void openSelfSubjectMapping(context) {
    Navigator.pushNamed(context, '/selfsubjectmapping');
  }

  void openStudentDetails(context) {
    Navigator.pushNamed(context, '/studentdetails');
  }

  void openParentsAppInstallStatus(context) {
    Navigator.pushNamed(context, '/parentsappinstallstatus');
  }

  void openChangeSection(context) {
    Navigator.pushNamed(context, '/changesec');
  }

  void openMarkAttendance(context) {
    Navigator.pushNamed(context, '/markattendance');
  }

  void openSchoolExpert(context) {
    Navigator.pushNamed(context, '/schoolexpert');
  }

  void openNotifications(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          stream: streamController,
        ),
      ),
    );
  }

  void openSendNotifications(context) {
    Navigator.pushNamed(context, '/notificationtabbedscreen');
  }

  void openPhotoGallery(context) {
    Navigator.pushNamed(context, '/photogallery');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: GridView.count(
        crossAxisCount: 3,
        children: [
          ButtonWidget(
            buttonText: 'Smart Task Management',
            icon: Icons.task_alt,
            onTap: openTasks,
          ),
          ButtonWidget(
            buttonText: 'Notifications',
            icon: Icons.notifications,
            onTap: openNotifications,
            count: AppConfig.globalnotificationCount,
          ),
          ButtonWidget(
            buttonText: 'Notifications - Parents',
            icon: Icons.notifications_active,
            onTap: openSendNotifications,
          ),
          ButtonWidget(
            buttonText: 'Messaging - Parents',
            icon: Icons.messenger,
            onTap: openMessages,
            count: AppConfig.globalmessageCount,
          ),
          if (AppConfig.globalSelfSubjectMap == true)
            ButtonWidget(
              buttonText: 'Self Subject Mapping',
              icon: Icons.supervised_user_circle,
              onTap: openSelfSubjectMapping,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Mark Attendance',
              icon: Icons.assignment_turned_in_sharp,
              onTap: openMarkAttendance,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Dues List',
              icon: Icons.currency_rupee,
              onTap: openDuesList,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Student Details',
              icon: Icons.person,
              onTap: openStudentDetails,
            ),
          ButtonWidget(
            buttonText: 'Parents App Install Status',
            icon: Icons.mobile_friendly,
            onTap: openParentsAppInstallStatus,
          ),

          if (AppConfig.globalIsSubjectTeacher == true)
            ButtonWidget(
              buttonText: 'Marks Entry (Exam Wise)',
              icon: Icons.edit_note,
              onTap: openMarksEntry,
            ),
          if (AppConfig.globalIsSubjectTeacher == true)
            ButtonWidget(
              buttonText: 'Marks Entry (Term Wise)',
              icon: Icons.edit_document,
              onTap: openMarksEntryTermWise,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Grades Entry',
              icon: Icons.grade,
              onTap: openGradesEntry,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Remarks Entry',
              icon: Icons.comment_outlined,
              onTap: openRemarksEntry,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Attendance For Report Card',
              icon: Icons.assignment_outlined,
              onTap: openAttendanceEntry,
            ),
          if (AppConfig.globalIsSubjectTeacher == true)
            ButtonWidget(
              buttonText: 'Trainings Attended',
              icon: Icons.model_training,
              onTap: openTrainingDetailsEntry,
            ),
          if (AppConfig.globalClassTeacher == true)
            ButtonWidget(
              buttonText: 'Change Section',
              icon: Icons.swap_horiz,
              onTap: openChangeSection,
            ),
          // show schoolexpert page to all
          ButtonWidget(
            buttonText: 'School Expert',
            icon: Icons.school,
            onTap: openSchoolExpert,
          ),
          ButtonWidget(
            buttonText: 'Photo Gallery',
            icon: Icons.photo_library,
            onTap: openPhotoGallery,
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final IconData icon;
  final Function onTap;
  final int count;
  const ButtonWidget({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        //height: 60.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Colors.blue, // Dodger Blue
              ],
              stops: [0.0, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          //decoration: AppConfig.boxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            onPressed: () => onTap(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.white, Colors.amber, Colors.white70],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  child: Stack(
                    children: [
                      Icon(
                        icon,
                        size: 45,
                        //color: Color.fromARGB(255, 103, 98, 98),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 10,
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Flexible(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.yellow,
                          ],
                          stops: [0.0, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.clamp,
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
