import 'package:flutter/material.dart';

import 'health_status.dart';
import 'package:smart_health_tracker/app/theme/app_colors.dart';

class HealthStatusHelper {
  static String label(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:
        return 'NORMAL';

      case HealthStatus.warning:
        return 'WARNING';

      case HealthStatus.danger:
        return 'DANGER';
    }
  }

  static Color color(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:
        return AppColors.success;

      case HealthStatus.warning:
        return Colors.orange;

      case HealthStatus.danger:
        return Colors.red;
    }
  }
}