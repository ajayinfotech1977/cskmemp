import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/messaging/api_service.dart';
import 'package:cskmemp/messaging/model/student_model.dart';
import 'package:cskmemp/messaging/model/message_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cskmemp/custom_data_stream.dart';

String teacherUserNo = AppConfig.globalUserNo;
StreamController<bool> streamController = StreamController<bool>.broadcast();

class ChatScreen extends StatefulWidget {
  final StudentModel student;

  ChatScreen({required this.student, required this.stream});
  final StreamController<bool> stream;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ApiService apiService = ApiService();
  final TextEditingController _textEditingController = TextEditingController();
  final List<MessageModel> _messages = [];
  // Define a ScrollController
  final ScrollController _scrollController = ScrollController();
  bool sendMessageClicked = false;
  bool isKeyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    AppConfig.isChatScreenActive = true;
    fetchMessages();

    // Listen to keyboard visibility changes
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        //print("isKeyboardVisible= $visible");
        isKeyboardVisible = visible;
        if (visible) {
          _scrollToLastMessage();
          // Scroll up when the keyboard is opened
          // _scrollController.animateTo(
          //   _scrollController.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.easeOut,
          // );
        }
      });
    });

    // TODO: Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var data = message.data;
      if (data.isNotEmpty) {
        //print(data);
        if (data.containsKey('notificationType')) {
          String dataValue = data['notificationType'];
          if (dataValue == 'Message' && AppConfig.isChatScreenActive) {
            //print("datavalue is Message");
            //ApiService apiService = ApiService();
            //await apiService.syncMessages();
            // Set the _isBroadcastMessage to true
            // AppConfig.isNewMessage = true;
            // _messageNotifier.isMessageReceived = true;
            getNewMessages();
            //print("Message received completed");
          }
          // Process the data as needed
          //print('Received data from PHP: $dataValue');
        }
      }
    });
  }

  @override
  void dispose() {
    AppConfig.isChatScreenActive = false;
    keyboardSubscription.cancel();

    if (!mounted) {
      widget.stream.close();
    }
    // stop polling
    //isChatScreenActive = false;
    // Remove the listener when the widget is disposed
    super.dispose();
  }

  void _scrollToLastMessage() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> getNewMessages() async {
    //print("getNewMessages called");
    // sync data from server
    await apiService.syncMessages();
    final messagesNew = await apiService.getMessages(
      widget.student.adm_no,
      AppConfig.globalUserNo,
    );

    // Compare _messages with messagesNew and add new messages
    final List<MessageModel> newMessages = messagesNew
        .where((newMessage) => !_messages.any((existingMessage) =>
            newMessage.dateTime == existingMessage.dateTime &&
            newMessage.message == existingMessage.message))
        .toList();
    //print("newMessages= $newMessages");
    // Add new messages to the stream
    if (newMessages.isNotEmpty) {
      //print("newMessages.isNotEmpty");
      if (mounted) {
        setState(() {
          // Update the messages list with new messages
          _messages.addAll(newMessages);
        });
      }
    }
  }

  // void messagePolling() async {
  //   // Delay execution for 30 seconds
  //   await Future.delayed(Duration(seconds: 30));

  //   while (isChatScreenActive) {
  //     print("messagePolling called");
  //     if (AppConfig.isNewMessage) {
  //       final messagesNew =
  //           await apiService.getMessages(adm_no, widget.teacher.userno);

  //       // Compare _messages with messagesNew and add new messages
  //       final List<MessageModel> newMessages = messagesNew
  //           .where((newMessage) => !_messages.any((existingMessage) =>
  //               newMessage.dateTime == existingMessage.dateTime &&
  //               newMessage.message == existingMessage.message))
  //           .toList();
  //       //print("newMessages= $newMessages");
  //       // Add new messages to the stream
  //       if (newMessages.isNotEmpty) {
  //         if (mounted) {
  //           setState(() {
  //             // Update the messages list with new messages
  //             _messages.addAll(newMessages);
  //           });
  //         }
  //       }
  //       AppConfig.isNewMessage = false;
  //       // Delay execution for the next 30 seconds
  //     }
  //     await Future.delayed(Duration(seconds: 1));
  //   }
  // }

  Future<void> fetchMessages() async {
    try {
      EasyLoading.show(status: 'Loading...');
      final messages = await apiService.getMessages(
        widget.student.adm_no,
        AppConfig.globalUserNo,
      );
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {
          _messages.addAll(messages);
          AppConfig.globalmessageCount =
              AppConfig.globalmessageCount - widget.student.noOfUnreadMessages;
          widget.student.noOfUnreadMessages = 0;

          //update the TeachersListScreen widget
          widget.stream.add(true);
        });
        // Change the status of message to read
        await apiService.updateMessageStatus(
          widget.student.adm_no,
          AppConfig.globalUserNo,
        );
        // start polling and listening for new messages
        //messagePolling();
      }
    } catch (e) {
      print(e.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load messages. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    // when user clicks on send button
    setState(() {
      sendMessageClicked = true;
    });
    //close the keypad
    FocusScope.of(context).unfocus();
    final String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      try {
        await apiService.sendMessage(
            teacherUserNo, widget.student.adm_no, message);
        _textEditingController.clear();
        // Update the messages list with the new message
        getNewMessages();
      } catch (e) {
        if (this.mounted) {
          setState(() {
            _textEditingController.text = message;
            sendMessageClicked = false;
          });
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to send message. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
    //again show the send button
    setState(() {
      sendMessageClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // After the ListView.builder is built, scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.st_name),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image4.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller:
                        _scrollController, // Assign the ScrollController
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final previousMessage =
                          index > 0 ? _messages[index - 1] : null;
                      final bool isSameDay = previousMessage != null &&
                          message.dateTime.year ==
                              previousMessage.dateTime.year &&
                          message.dateTime.month ==
                              previousMessage.dateTime.month &&
                          message.dateTime.day == previousMessage.dateTime.day;
                      return Column(
                        children: [
                          if (!isSameDay) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(message.dateTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 86, 86, 86),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                          ],
                          Row(
                            mainAxisAlignment: message.fromNo == teacherUserNo
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: message.fromNo == teacherUserNo
                                      ? Colors.blue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.0),
                                    topRight: Radius.circular(12.0),
                                    bottomLeft: Radius.circular(
                                        message.fromNo == teacherUserNo
                                            ? 12.0
                                            : 0.0),
                                    bottomRight: Radius.circular(
                                        message.fromNo == teacherUserNo
                                            ? 0.0
                                            : 12.0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.message,
                                      softWrap: true,
                                      maxLines: null,
                                      style: TextStyle(
                                        color: message.fromNo == teacherUserNo
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(message.dateTime),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: message.fromNo == teacherUserNo
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                        ],
                      );
                    },
                  ),
                ),
                //create a gap of 8 pixels
                SizedBox(height: 15.0),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: sendMessageClicked
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 169, 0, 0)),
                              )
                            : IconButton(
                                icon: Icon(Icons.send),
                                color: Colors.white,
                                onPressed: sendMessage,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  final StreamController<CustomData> streamReadMessages;
  StudentListScreen({required this.streamReadMessages});
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<StudentModel>> _studentsFuture;
  final ApiService apiService = ApiService();
  TextEditingController _searchController = TextEditingController();
  List<StudentModel> filteredStudents = [];
  AsyncSnapshot<List<StudentModel>>? snapshotData;

  @override
  void initState() {
    super.initState();

    _studentsFuture = apiService.getStudents(teacherUserNo);
    //updateSearchResults('');

    streamController.stream.listen((shouldUpdate) {
      if (mounted) {
        if (shouldUpdate) {
          setState(() {
            // Update the necessary data or re-fetch the updated data
            _studentsFuture = apiService.getStudents(teacherUserNo);
          });
        }
      }
    });

    // Initialize filteredStudents with snapshot data
    _studentsFuture.then((students) {
      setState(() {
        filteredStudents = students;
      });
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!mounted) {
      streamController.close();
    }
    super.dispose();
  }

  void _openChatScreen(StudentModel student) {
    widget.streamReadMessages
        .add(CustomData(count: student.noOfUnreadMessages, form: 'message'));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          student: student,
          stream: streamController,
        ),
      ),
    );
  }

  void updateSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = snapshotData?.data ?? [];
      } else {
        filteredStudents = snapshotData?.data
                ?.where((student) =>
                    student.st_name.toLowerCase().contains(query.toLowerCase()))
                .toList() ??
            [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keypad when user taps outside of the search box
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                updateSearchResults(value);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                //create a circular border around search bar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentModel>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  snapshotData = AsyncSnapshot<List<StudentModel>>.withData(
                    ConnectionState.done,
                    snapshot.data!,
                  );
                  //filteredStudents = snapshot.data!;
                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return ListTile(
                        title: Text(
                          student.st_name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: student.isAppInstalled
                                ? Colors.black
                                : Colors.red,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adm No: ${student.adm_no} - Class: ${student.st_class} / ${student.st_section} (${student.feecategory})',
                            ),
                            Divider(),
                          ],
                        ),
                        trailing: student.noOfUnreadMessages > 0
                            ? CircleAvatar(
                                radius: 10.0,
                                backgroundColor: Colors.red,
                                child: Text(
                                  student.noOfUnreadMessages.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => student.isAppInstalled
                            ? _openChatScreen(student)
                            : EasyLoading.showToast(
                                'App not installed by parents of ${student.st_name}'),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load students'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
