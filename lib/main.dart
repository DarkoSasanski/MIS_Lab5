import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeNotifications();
  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkAndRequestPermission();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }

  void checkAndRequestPermission() async {
    if (await hasExactAlarmPermission()) {
      // Permission is already granted
      if (kDebugMode) {
        print("Exact alarm permission is granted.");
      }
    } else {
      // Permission is not granted, request it
      await requestExactAlarmPermission();
    }
  }

  Future<bool> hasExactAlarmPermission() async {
    if (io.Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isGranted) {
        return true;
      }
    }
    return false; // On non-Android platforms, assume the permission is granted
  }

  Future<void> requestExactAlarmPermission() async {
    if (io.Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}
