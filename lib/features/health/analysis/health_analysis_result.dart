  import 'health_analyzer.dart';
  import 'health_status.dart';
    class HealthAnalysisResult {
    final HealthStatus heartRateStatus;
    final HealthStatus bloodPressureStatus;
    final HealthStatus glucoseStatus;
    final HealthStatus overallStatus;

    const HealthAnalysisResult({
    required this.heartRateStatus,
    required this.bloodPressureStatus,
    required this.glucoseStatus,
    required this.overallStatus,
    });
    }