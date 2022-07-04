import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasetest/main.dart';
import 'package:firebasetest/mainscreen.dart';
import 'package:firebasetest/models/message.dart';
import 'package:firebasetest/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MainScreenFB extends StatefulWidget {
  const MainScreenFB({Key? key}) : super(key: key);

  @override
  State<MainScreenFB> createState() => _MainScreenFBState();
}

class _MainScreenFBState extends State<MainScreenFB> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? token = " ";

  @override
  void initState() {
    super.initState();
//

    requestPermission();
    //
    loadFCM();
    //
    listenFCM();
    //
    // listenOpenFCM();
    //
    getToken();
    //
    // setUpLocalNotification(context);
    // FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  void sendPushMessage() async {
    print("Vao day");
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAtf2IlIs:APA91bHWBpKYwp8RozjzkyzI3lIvPO48aoARVEgwcZdBAoUrA6uZqFnymB_htV1ZDbeCUQ6YK8QS18EPeMbTdM7iMVJhMiUT6uo5ZX6Ix7U8U6e3ZO46vyzUDC2cuJhpxRGFC_pLPyTF',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Test Body',
              'title': 'Test Title 2'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "/topic/Animal",
          },
        ),
      );
    } catch (e) {
      print("error push notification: ${e}");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      // setState(() {
      //   token = token;
      // });
      print(token);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      await AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Turn on'),
                onPressed: () {
                  AppSettings.openNotificationSettings();
                })
          ]);

      print(
          'User declined or has not accepted permission =======================');
    }
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications',
        'Main channel notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
  void setUpLocalNotification(BuildContext context) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          !kIsWeb && Platform.isLinux
              ? null
              : await flutterLocalNotificationsPlugin
                  .getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      if (payload == '1') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        var a = payload;
      }
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            message.notification.hashCode,
            message.data['title'],
            message.data['body'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                  'default_notification_channel_id',
                  'channel.name',
                  'your channel description',
                  icon: 'ic_stat',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker'),
            ),
            payload: message.data['routeName']);
      }
    });
  }

  // void listenOpenFCM() async {
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('A new onMessageOpenedApp event was published!');
  //     // Navigator.pushNamed(
  //     //   context,
  //     //   '/message',
  //     //   arguments: MessageArguments(message, true),
  //     // );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            // sendPushMessage();
          },
          child: Container(
            height: 40,
            width: 200,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
