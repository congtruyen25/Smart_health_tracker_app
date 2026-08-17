import '../database/health_database.dart';
import 'health_stats.dart';

class HealthStatsService {
  static Future<HealthStats> getStats() async {
    final measurements =
    await HealthDatabase.instance.getMeasurements();

    return HealthStats.fromMeasurements(
      measurements,
    );
  }
}