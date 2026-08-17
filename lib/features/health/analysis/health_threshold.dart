class HealthThreshold {
  final int? id;

  // Heart Rate
  final double heartRateMin;
  final double heartRateMax;

  // Blood Pressure - Systolic
  final double systolicMin;
  final double systolicMax;

  // Blood Pressure - Diastolic
  final double diastolicMin;
  final double diastolicMax;

  // Blood Glucose
  final double glucoseMin;
  final double glucoseMax;

  const HealthThreshold({
    this.id,

    required this.heartRateMin,
    required this.heartRateMax,

    required this.systolicMin,
    required this.systolicMax,

    required this.diastolicMin,
    required this.diastolicMax,

    required this.glucoseMin,
    required this.glucoseMax,
  });

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'heart_rate_min': heartRateMin,
      'heart_rate_max': heartRateMax,

      'systolic_min': systolicMin,
      'systolic_max': systolicMax,

      'diastolic_min': diastolicMin,
      'diastolic_max': diastolicMax,

      'glucose_min': glucoseMin,
      'glucose_max': glucoseMax,
    };
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory HealthThreshold.fromMap(
      Map<String, dynamic> map,
      ) {
    return HealthThreshold(
      id: map['id'] as int?,

      heartRateMin:
      (map['heart_rate_min'] as num).toDouble(),
      heartRateMax:
      (map['heart_rate_max'] as num).toDouble(),

      systolicMin:
      (map['systolic_min'] as num).toDouble(),
      systolicMax:
      (map['systolic_max'] as num).toDouble(),

      diastolicMin:
      (map['diastolic_min'] as num).toDouble(),
      diastolicMax:
      (map['diastolic_max'] as num).toDouble(),

      glucoseMin:
      (map['glucose_min'] as num).toDouble(),
      glucoseMax:
      (map['glucose_max'] as num).toDouble(),
    );
  }

  // ============================================================
  // DEFAULT
  // ============================================================

  static const HealthThreshold defaultThreshold =
  HealthThreshold(
    heartRateMin: 60,
    heartRateMax: 100,

    systolicMin: 90,
    systolicMax: 120,

    diastolicMin: 60,
    diastolicMax: 80,

    glucoseMin: 3.9,
    glucoseMax: 7.8,
  );
}