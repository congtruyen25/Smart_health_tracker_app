import '../database/health_database.dart';
import '../models/health_measurement.dart';

class HealthTrendService {
  static Future<List<HealthMeasurement>> getLast7Days() async {
    final measurements =
    await HealthDatabase.instance.getMeasurements();

    final now = DateTime.now();

    final sevenDaysAgo =
    now.subtract(const Duration(days: 7));

    final result = measurements.where((measurement) {
      return measurement.measuredAt
          .isAfter(sevenDaysAgo);
    }).toList();

    result.sort(
          (a, b) => a.measuredAt.compareTo(b.measuredAt),
    );

    return result;
  }
}