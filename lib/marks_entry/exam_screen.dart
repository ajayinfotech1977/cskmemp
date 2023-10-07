//import all the required packages
import 'package:flutter/material.dart';
//import 'package:cskmemp/marks_entry/marks_form.dart';
//import web_view_app.dart
import 'package:cskmemp/marks_entry/web_view_app.dart';

// create a new marks entry screen with scaffold and appbar with title Marks
// Entry and a body with a widget MarksEntryForm
class MarksEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Marks Entry Exam Wise',
      url: 'https://www.cskm.com/schoolexpert/examMarksEntry2.asp',
    );
  }
}

class MarksEntryScreenTermWise extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Marks Entry Term Wise',
      url: 'https://www.cskm.com/schoolexpert/examMarksEntry.asp',
    );
  }
}

class GradesEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Grades Entry',
      url: 'https://www.cskm.com/schoolexpert/coScholasticGradesEntry.asp',
    );
  }
}

class RemarksEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Remarks Entry',
      url: 'https://www.cskm.com/schoolexpert/remarksEntry.asp',
    );
  }
}

class ExamAttendanceEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Attendance For Report Card',
      url: 'https://www.cskm.com/schoolexpert/examAttEntry2.asp',
    );
  }
}

class TrainingDetailsEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Trainings Attended',
      url: 'https://www.cskm.com/schoolexpert/TeacherTraining.asp',
    );
  }
}

class DuesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Dues List',
      url: 'https://www.cskm.com/schoolexpert/duesListingSecWise.asp',
    );
  }
}

class SelfSubjectMapping extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Self Subject Mapping',
      url: 'https://www.cskm.com/schoolexpert/selfSubjectMap.asp',
    );
  }
}

class StudentDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Student Details',
      url: 'https://www.cskm.com/schoolexpert/studentDtlsCW.asp',
    );
  }
}

class ChangeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Change Section',
      url: 'https://www.cskm.com/schoolexpert/secChangeCW.asp?mobile=1',
    );
  }
}

class MarkAttendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Mark Attendance',
      url: 'https://www.cskm.com/schoolexpert/dailyAttendanceCW.php',
    );
  }
}

class ViewSchoolexpert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Schoolexpert Webpage',
      url: 'https://www.cskm.com/schoolexpertnew/modules.php',
    );
  }
}
