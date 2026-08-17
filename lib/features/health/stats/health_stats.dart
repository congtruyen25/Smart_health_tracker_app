import '../models/health_measurement.dart';

class HealthStats {
  final double averageHeartRate;
  final double minHeartRate;
  final double maxHeartRate;

  final double averageSystolic;
  final double averageDiastolic;

  final double averageBloodGlucose;
  final double minBloodGlucose;
  final double maxBloodGlucose;

  final int measurementCount;

  const HealthStats({
    required this.averageHeartRate,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averageBloodGlucose,
    required this.minBloodGlucose,
    required this.maxBloodGlucose,
    required this.measurementCount,
  });

  factory HealthStats.empty() {
    return const HealthStats(
      averageHeartRate: 0,
      minHeartRate: 0,
      maxHeartRate: 0,
      averageSystolic: 0,
      averageDiastolic: 0,
      averageBloodGlucose: 0,
      minBloodGlucose: 0,
      maxBloodGlucose: 0,
      measurementCount: 0,
    );
  }

  factory HealthStats.fromMeasurements(
      List<HealthMeasurement> measurements,
      ) {
    if (measurements.isEmpty) {
      return HealthStats.empty();
    }

    final heartRates =
    measurements.map((m) => m.heartRate).toList();

    final systolic =
    measurements.map((m) => m.systolic).toList();

    final diastolic =
    measurements.map((m) => m.diastolic).toList();

    final glucose =
    measurements.map((m) => m.bloodGlucose).toList();

    double average(List<double> values) {
      return values.reduce((a, b) => a + b) /
          values.length;
    }

    return HealthStats(
      averageHeartRate: average(heartRates),
      minHeartRate: heartRates.reduce(
            (a, b) => a < b ? a : b,
      ),
      maxHeartRate: heartRates.reduce(
            (a, b) => a > b ? a : b,
      ),
      averageSystolic: average(systolic),
      averageDiastolic: average(diastolic),
      averageBloodGlucose: average(glucose),
      minBloodGlucose: glucose.reduce(
            (a, b) => a < b ? a : b,
      ),
      maxBloodGlucose: glucose.reduce(
            (a, b) => a > b ? a : b,
      ),
      measurementCount: measurements.length,
    );
  }
}