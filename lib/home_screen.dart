import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/home_screen_buttons.dart';
import 'package:flutter/material.dart';

enum MenuItem {
  logout,
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Future<String> fetchEmpName() async {
  //   //EasyLoading.show(status: 'loading...');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var ename = prefs.getString('ename');
  //   //EasyLoading.dismiss();
  //   return Future.value(ename);
  // }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //     stream: Stream.fromFuture(fetchEmpName()),
    //     builder: (ctx, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const SpalshScreen();
    //       } else {
    //         ename = snapshot.data!;
    //       }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.globalEname),
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (AppConfig.globalNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 7,
                      child: Text(
                        AppConfig.globalNotificationCount.toString(),
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
              Navigator.pushNamed(context, '/notifications');
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
