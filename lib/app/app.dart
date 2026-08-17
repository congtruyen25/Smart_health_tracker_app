import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:smart_health_tracker/features/health/screens/add_health_measurement_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_health_tracker/features/health/screens/health_history_screen.dart';
class SmartHealthApp extends StatelessWidget {
  const SmartHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Health Tracker',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(

      ),
    );
  }
}