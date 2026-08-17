import '../models/health_measurement.dart';
import 'health_analysis_result.dart';
import 'health_status.dart';
import 'health_threshold.dart';

class HealthAnalyzer {
  // ============================================================
  // HEART RATE
  // ============================================================

  static HealthStatus analyzeHeartRate(
      double heartRate, {
        required HealthThreshold threshold,
      }) {
    return _analyzeRange(
      value: heartRate,
      min: threshold.heartRateMin,
      max: threshold.heartRateMax,
    );
  }

  // ============================================================
  // BLOOD PRESSURE
  // ============================================================

  static HealthStatus analyzeBloodPressure(
      double systolic,
      double diastolic, {
        required HealthThreshold threshold,
      }) {
    final systolicStatus = _analyzeRange(
      value: systolic,
      min: threshold.systolicMin,
      max: threshold.systolicMax,
    );

    final diastolicStatus = _analyzeRange(
      value: diastolic,
      min: threshold.diastolicMin,
      max: threshold.diastolicMax,
    );

    return _combineStatus(
      systolicStatus,
      diastolicStatus,
    );
  }

  // ============================================================
  // BLOOD GLUCOSE
  // ============================================================

  static HealthStatus analyzeBloodGlucose(
      double glucose, {
        required HealthThreshold threshold,
      }) {
    return _analyzeRange(
      value: glucose,
      min: threshold.glucoseMin,
      max: threshold.glucoseMax,
    );
  }

  // ============================================================
  // RANGE ANALYSIS
  // ============================================================

  static HealthStatus _analyzeRange({
    required double value,
    required double min,
    required double max,
  }) {
    // Trong ngưỡng an toàn
    if (value >= min && value <= max) {
      return HealthStatus.normal;
    }

    // Độ rộng vùng an toàn
    final range = max - min;

    // Tránh chia cho 0
    if (range <= 0) {
      return HealthStatus.danger;
    }

    // Khoảng lệch cho phép trước khi thành DANGER
    final warningDistance = range * 0.10;

    // Lệch dưới min
    if (value < min) {
      final distance = min - value;

      if (distance <= warningDistance) {
        return HealthStatus.warning;
      }

      return HealthStatus.danger;
    }

    // Lệch trên max
    final distance = value - max;

    if (distance <= warningDistance) {
      return HealthStatus.warning;
    }

    return HealthStatus.danger;
  }

  // ============================================================
  // COMBINE TWO STATUSES
  // ============================================================

  static HealthStatus _combineStatus(
      HealthStatus first,
      HealthStatus second,
      ) {
    if (first == HealthStatus.danger ||
        second == HealthStatus.danger) {
      return HealthStatus.danger;
    }

    if (first == HealthStatus.warning ||
        second == HealthStatus.warning) {
      return HealthStatus.warning;
    }

    return HealthStatus.normal;
  }

  // ============================================================
  // OVERALL
  // ============================================================

  static HealthStatus analyzeOverall(
      List<HealthStatus> statuses,
      ) {
    if (statuses.contains(HealthStatus.danger)) {
      return HealthStatus.danger;
    }

    if (statuses.contains(HealthStatus.warning)) {
      return HealthStatus.warning;
    }

    return HealthStatus.normal;
  }

  // ============================================================
  // COMPLETE MEASUREMENT ANALYSIS
  // ============================================================

  static HealthAnalysisResult analyzeMeasurement(
      HealthMeasurement measurement, {
        required HealthThreshold threshold,
      }) {
    final heartRateStatus = analyzeHeartRate(
      measurement.heartRate,
      threshold: threshold,
    );

    final bloodPressureStatus = analyzeBloodPressure(
      measurement.systolic,
      measurement.diastolic,
      threshold: threshold,
    );

    final glucoseStatus = analyzeBloodGlucose(
      measurement.bloodGlucose,
      threshold: threshold,
    );

    final overallStatus = analyzeOverall([
      heartRateStatus,
      bloodPressureStatus,
      glucoseStatus,
    ]);

    return HealthAnalysisResult(
      heartRateStatus: heartRateStatus,
      bloodPressureStatus: bloodPressureStatus,
      glucoseStatus: glucoseStatus,
      overallStatus: overallStatus,
    );
  }
}