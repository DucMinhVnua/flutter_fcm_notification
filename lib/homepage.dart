// lần đầu: loadFCM, requestPermissions
// thông báo đc gửi từ postman: listenFCM, _configureDidReceiveLocalNotificationSubject, onSelectNotification, _configureSelectNotificationSubject
// thông báo bên ngoài app ̣(chưa tắt app): _firebaseMessagingBackgroundHandler, onSelectNotification, _configureSelectNotificationSubject

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasetest/main.dart';
import 'package:firebasetest/notification_service_firebase.dart';
import 'package:firebasetest/secondpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    NotificationServiceFirebase().loadFCM();
    NotificationServiceFirebase().listenFCM();
    NotificationServiceFirebase().requestPermissions();
    NotificationServiceFirebase().configureDidReceiveLocalNotificationSubject();
    NotificationServiceFirebase().configureSelectNotificationSubject();

    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      // setState(() {
      //   token = token;
      // });
      print(token);
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Text('Tap on a notification when it appears to trigger'
                ' navigation'),
          ),
          _InfoValueString(
            title: 'Did notification launch app?',
            value: widget.didNotificationLaunchApp,
          ),
          if (widget.didNotificationLaunchApp)
            _InfoValueString(
              title: 'Launch notification payload:',
              value: widget.notificationAppLaunchDetails!.payload,
            ),
          PaddedElevatedButton(
            buttonText: 'Show plain notification with payload',
            onPressed: () async {
              // await _showNotification();
            },
          ),
        ],
      ),
    );
  }
}

class _InfoValueString extends StatelessWidget {
  const _InfoValueString({
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  final String title;
  final Object? value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: '$title ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '$value',
              )
            ],
          ),
        ),
      );
}

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      );
}
