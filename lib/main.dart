import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:smart_health_tracker/features/reminder/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const SmartHealthApp());
}