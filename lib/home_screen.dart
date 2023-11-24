import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/home_screen_buttons.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/notifications_sreen.dart';
import 'package:cskmemp/custom_data_stream.dart';

StreamController<CustomData> streamController =
    StreamController<CustomData>.broadcast();

enum MenuItem {
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.globalEname),
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (AppConfig.globalnotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 7,
                      child: Text(
                        AppConfig.globalnotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                    stream: streamController,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<MenuItem>(
              onSelected: (logout) async {
                AppConfig.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: MenuItem.logout,
                      child: Text('Logout'),
                    )
                  ])
        ],
      ),
      body: const Center(
        child: HomeScreenButtons(),
      ),
    );
    //});
  }
}
