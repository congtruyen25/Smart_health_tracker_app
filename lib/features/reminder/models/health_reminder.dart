class HealthReminder {
  final int? id;
  final String title;
  final String type;
  final int hour;
  final int minute;
  final bool enabled;

  const HealthReminder({
    this.id,
    required this.title,
    required this.type,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'hour': hour,
      'minute': minute,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory HealthReminder.fromMap(
      Map<String, dynamic> map,
      ) {
    return HealthReminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: map['type'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      enabled: (map['enabled'] as int) == 1,
    );
  }
}