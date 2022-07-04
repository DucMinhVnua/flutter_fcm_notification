import 'package:flutter/material.dart';

import 'notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService().requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                NotificationService().showNotification(
                  1,
                  'main_channel',
                  'Test title',
                  'Test body',
                );
              },
              child: Container(
                height: 30,
                width: 70,
                color: Colors.blue,
                child: Text("SHOW NOTIFICATION"),
              ),
            ),
            GestureDetector(
              onTap: () {
                NotificationService().showScheduledNotification(
                  1,
                  'main_channel',
                  'Test title',
                  'Test body',
                  5,
                );
              },
              child: Container(
                height: 30,
                width: 70,
                color: Colors.red,
                child: Text("SHOW NOTIFICATION2"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
