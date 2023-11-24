import 'dart:async';

import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/tasks/task_display_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

StreamController<bool> streamController = StreamController<bool>.broadcast();

class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> employees = [];
  String userNo = "";

  final TextEditingController _taskController = TextEditingController();
  String? userNoSelected;
  bool _saving = false;

  Future<void> fetchEmployees() async {
    await AppConfig().getUserNo().then((String result) {
      userNo = result;
      userNoSelected = userNo;
    });

    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchenames.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("Response = $data");

      // print(employees);
      setState(() {
        employees = List<Map<String, dynamic>>.from(data['employees']);
      });
    }
  }

  List<DropdownMenuItem<String>> get dropDownItems {
    List<DropdownMenuItem<String>> menuItems = employees.map((employee) {
      return DropdownMenuItem<String>(
        value: employee['userno'].toString(),
        child: Container(
          //width: double.infinity,
          //height: 10,
          margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          //decoration:
          //BoxDecoration(color: Colors.blue, shape: BoxShape.rectangle),
          //AppConfig.boxDecoration(), // Set the background color here
          child: Text(
            employee['ename'],
            style: TextStyle(
              color: const Color.fromARGB(
                  255, 13, 13, 13), // Set the text color here
            ),
          ),
        ),
      );
    }).toList();

    return menuItems;
  }

  @override
  void initState() {
    fetchEmployees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      //padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          taskFormWidget(), //form to display whose code is in the same file.
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Your Pending Tasks',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 236, 244, 250)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            //Tasks assigned to user of the app
            child: TaskListScreen(
              stream: streamController.stream,
              taskType: 'My',
            ),
          ),
        ],
      ),
    );
  }

  Card taskFormWidget() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(96, 200, 252, 1),
              Color.fromRGBO(96, 200, 252, 0.8),
              Color.fromRGBO(96, 200, 252, 0.6),
              Color.fromRGBO(96, 200, 252, 0.4),
              Color.fromRGBO(96, 200, 252, 0.2),
              Color.fromRGBO(96, 200, 252, 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  style: TextStyle(color: const Color.fromARGB(255, 8, 8, 8)),
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Task',
                    labelStyle:
                        TextStyle(color: const Color.fromARGB(255, 8, 8, 8)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a task';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        itemHeight: null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Assign To',
                          labelStyle:
                              TextStyle(color: Color.fromARGB(255, 8, 8, 8)),
                        ),
                        items: dropDownItems,
                        value: userNoSelected,
                        onChanged: (value) {
                          setState(() {
                            userNoSelected = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an employee';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0)),
                        label: Text('Save'),
                        icon: _saving
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(Icons.save),
                        onPressed: _saving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  addTask();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addTask() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
    });
    //print("from add task");
    var bodyData = {
      'secretKey': AppConfig.secreetKey,
      'AssignedBy': userNo,
      'userNo': userNoSelected,
      'task': _taskController.text,
    };
    //print(bodyData);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/addTask.php'),
      body: bodyData,
    );

    //print("response = ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task Saved'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problem saving task. Retry later.'),
          ),
        );
      }
      //print(data['status']);
    }
    setState(() {
      _taskController.text = "";
      streamController.add(true);
      _saving = false;
    });
  }
}
