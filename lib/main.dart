import 'dart:io';
import 'package:acoms_app/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'simple_channel',
  'Simple Notifications',
  description: 'Used for basic notifications triggered by button press',
  importance: Importance.high,
);

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const linuxInit = LinuxInitializationSettings(
    defaultActionName: 'Open',
  );
  const initSettings = InitializationSettings(android: androidInit, linux: linuxInit);
  await _notifications.initialize(initSettings);

  // Android-specific setup
  final androidImpl = _notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidImpl?.createNotificationChannel(_channel);

  if (Platform.isAndroid) {
    await androidImpl?.requestNotificationsPermission(); // Android 13+
  }

}

Future<void> _showNotification() async {
  await _notifications.show(
    0,
    'Hello from Flutter!',
    'This is a simple local notification.',
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACOMS',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          elevation: 0,
        ),
        fontFamily: 'OCR-B',
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        shadowColor: Colors.transparent,
        cardTheme: CardThemeData(
          color: Colors.black,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.grey.shade400, width: 0.5),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontFamily: 'Alliance2'),
          bodyMedium: TextStyle(color: Colors.white, letterSpacing: -2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.grey.shade400, width: 0.5),
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: Home(),
    );
  }
}