import 'dart:developer';

import 'package:acoms_app/notifications.dart';
import 'package:acoms_app/remote.dart';
import 'package:acoms_app/views/home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final push = PushNotifications(Remote());
  push.onOpened = (data) {
    log('Notification opened with payload: $data');
  };
  try {
    await push.init();
  } catch (e) {
    log('Push notification setup failed: $e');
  }

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