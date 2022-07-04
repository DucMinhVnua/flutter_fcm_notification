import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasetest/homepage.dart';
import 'package:firebasetest/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationServiceFirebase {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',
    'Main channel notifications', // title
    importance: Importance.high,
    enableVibration: true,
  );

  Future<void> showNotification(
      int id, String? title, String? body, String? payload) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            channel.id, channel.name, channel.description,
            importance: Importance.max, ticker: 'ticker');
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  void loadFCM() async {
    print("===loadFCM");
    if (!kIsWeb) {
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

  // lang nghe moi khi co thong bao moi firebase
  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("===listenFCM");
      if (!kIsWeb) {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: message.notification.hashCode,
            title: message.data['title'],
            body: message.data['body'],
            payload: message.data['routeName'],
          ),
        );
      }
    });
  }

  void requestPermissions() {
    print("===requestPermissions");
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // khi co thong bao gui ve cua listenFCM -> _configureDidReceiveLocalNotificationSubject
  void configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      print("===_configureDidReceiveLocalNotificationSubject");
      await NotificationServiceFirebase().showNotification(
          receivedNotification.id,
          receivedNotification.title,
          receivedNotification.body,
          receivedNotification.payload);
    });
  }

  // khi click thong bao duoc show tu _showNotification chay sau onSelectNotification trong app
  void configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      print("===_configureSelectNotificationSubject");
      // await Navigator.pushNamed(context, '/secondPage');
    });
  }
}
