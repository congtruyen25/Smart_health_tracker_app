class HealthMeasurement {
  final int? id;

  final double systolic;
  final double diastolic;
  final double heartRate;
  final double bloodGlucose;

  final DateTime measuredAt;

  final String? note;

  const HealthMeasurement({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.bloodGlucose,
    required this.measuredAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'heart_rate': heartRate,
      'blood_glucose': bloodGlucose,
      'measured_at': measuredAt.toIso8601String(),
      'note': note,
    };
  }

  @override
  String toString() {
    return '''
HealthMeasurement(
  id: $id,
  systolic: $systolic,
  diastolic: $diastolic,
  heartRate: $heartRate,
  bloodGlucose: $bloodGlucose,
  measuredAt: $measuredAt,
  note: $note,
)
''';
  }
  factory HealthMeasurement.fromMap(
      Map<String, dynamic> map,
      ) {
    return HealthMeasurement(
      id: map['id'] as int?,
      systolic: (map['systolic'] as num).toDouble(),
      diastolic: (map['diastolic'] as num).toDouble(),
      heartRate: (map['heart_rate'] as num).toDouble(),
      bloodGlucose: (map['blood_glucose'] as num).toDouble(),
      measuredAt: DateTime.parse(
        map['measured_at'] as String,
      ),
      note: map['note'] as String?,
    );
  }
}