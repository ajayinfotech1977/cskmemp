import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';

class HomeScreenButtons extends StatefulWidget {
  const HomeScreenButtons({super.key});

  @override
  State<HomeScreenButtons> createState() => _HomeScreenButtonsState();
}

class _HomeScreenButtonsState extends State<HomeScreenButtons> {
  bool classTeacher = false;
  //code to store classTeacher in SharedPreferences to the global variable classTeacher

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
    Navigator.pushNamed(context, '/messagetabbedscreen');
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

  void openChangeSection(context) {
    Navigator.pushNamed(context, '/changesec');
  }

  void openMarkAttendance(context) {
    Navigator.pushNamed(context, '/markattendance');
  }

  void openSchoolExpert(context) {
    Navigator.pushNamed(context, '/schoolexpert');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        ButtonWidget(
          buttonText: 'Smart Task Management',
          icon: Icons.task_alt,
          onTap: openTasks,
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

        if (AppConfig.globalClassTeacher == true)
          ButtonWidget(
            buttonText: 'Class Teacher Smart Messaging',
            icon: Icons.messenger,
            onTap: openMessages,
          ),
        if (AppConfig.globalIsSubjectTeacher == true)
          ButtonWidget(
            buttonText: 'Marks Entry (Exam Wise)',
            icon: Icons.edit,
            onTap: openMarksEntry,
          ),
        if (AppConfig.globalIsSubjectTeacher == true)
          ButtonWidget(
            buttonText: 'Marks Entry (Term Wise)',
            icon: Icons.edit,
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
        if (AppConfig.globalIsOffSupdt == true)
          ButtonWidget(
            buttonText: 'Office Smart Messaging',
            icon: Icons.supervisor_account,
            onTap: openMessages,
          ),
        // show schoolexpert page to all
        ButtonWidget(
          buttonText: 'School Expert',
          icon: Icons.school,
          onTap: openSchoolExpert,
        ),
      ],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final IconData icon;
  final Function onTap;
  const ButtonWidget({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 40.0,
        child: DecoratedBox(
          decoration: AppConfig.boxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(0, 0, 0, 0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.yellow,
                ),
                SizedBox(height: 8.0),
                Text(
                  buttonText,
                  style: AppConfig.normaYellow20(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Text(
            //   buttonText,
            //   style: AppConfig.normalWhite15(),
            // ),
            //icon: Icon(icon, size: 40),
            onPressed: () => onTap(context),
          ),
        ),
      ),
    );
  }
}
