class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;

  const UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }

  factory UserProfile.fromMap(
      Map<String, dynamic> map,
      ) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}