import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'remote.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Channel used both by locally-shown notifications and by FCM messages that
/// Android displays itself while the app is backgrounded. The manifest points
/// `default_notification_channel_id` at this same id so the two paths look
/// identical to the user.
const AndroidNotificationChannel alertsChannel = AndroidNotificationChannel(
  'acoms_alerts',
  'ACOMS Alerts',
  description: 'Service and terminal alerts pushed by the ACOMS server',
  importance: Importance.high,
);

/// FCM is only wired up on Android here. The Linux desktop build still gets
/// local notifications, and web would additionally need a service worker plus
/// generated Firebase options, so both are left out.
bool get _pushSupported => !kIsWeb && Platform.isAndroid;

/// Runs in its own isolate when a data message arrives while the app is
/// backgrounded or terminated, so it has to bring Firebase up on its own.
///
/// Messages carrying a `notification` block are drawn by the system tray
/// directly and must not be re-displayed from here, or they show up twice.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Background push received: ${message.messageId} ${message.data}');
}

class PushNotifications {
  final Remote _remote;

  /// Invoked when the user taps a notification, with the message's data
  /// payload. Set this before calling [init] so a tap that launched the app
  /// from a terminated state isn't missed.
  void Function(Map<String, dynamic> data)? onOpened;

  PushNotifications(this._remote);

  Future<void> init() async {
    await _initLocalNotifications();

    if (!_pushSupported) return;

    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Android 13+ runtime permission. On older versions this resolves to
    // authorized without prompting.
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('Push notification permission denied');
      return;
    }

    // Shown while the app is in the foreground, where Android does not draw
    // the notification for us.
    FirebaseMessaging.onMessage.listen(_showRemoteMessage);

    // Tapped while the app was backgrounded but still alive.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => onOpened?.call(message.data),
    );

    // Tapped while the app was terminated; this is the launch message.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      onOpened?.call(initialMessage.data);
    }

    // The token can be rotated by FCM at any time, so the refresh stream is
    // subscribed to before the initial fetch to avoid missing a rotation.
    messaging.onTokenRefresh.listen(_registerToken);
    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    } else {
      log('Failed to obtain an FCM token');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');
    const initSettings = InitializationSettings(
      android: androidInit,
      linux: linuxInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          onOpened?.call(jsonDecode(payload) as Map<String, dynamic>);
        }
      },
    );

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(alertsChannel);

    if (!kIsWeb && Platform.isAndroid) {
      await androidImpl?.requestNotificationsPermission(); // Android 13+
    }
  }

  Future<void> _showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // Data-only message, nothing to display.

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          alertsChannel.id,
          alertsChannel.name,
          channelDescription: alertsChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        linux: const LinuxNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _registerToken(String token) async {
    final registered = await _remote.registerPushToken(token);
    if (!registered) {
      log('Failed to register push token with the ACOMS server');
    }
  }
}
