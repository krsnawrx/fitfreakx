import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final String goal; // 'gain', 'lose', 'maintain'
  final double tdee;
  final double dailyCalorieTarget;
  final double bmi;
  final bool hasCompletedOnboarding;
  final DateTime? lastBiometricUpdate;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.tdee,
    required this.dailyCalorieTarget,
    required this.bmi,
    required this.hasCompletedOnboarding,
    this.lastBiometricUpdate,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: d['email'] ?? '',
      displayName: d['displayName'] ?? '',
      gender: d['gender'] ?? 'male',
      age: (d['age'] ?? 25).toInt(),
      heightCm: (d['heightCm'] ?? 175).toDouble(),
      weightKg: (d['weightKg'] ?? 70).toDouble(),
      goal: d['goal'] ?? 'gain',
      tdee: (d['tdee'] ?? 2500).toDouble(),
      dailyCalorieTarget: (d['dailyCalorieTarget'] ?? 3000).toDouble(),
      bmi: (d['bmi'] ?? 22).toDouble(),
      hasCompletedOnboarding: d['hasCompletedOnboarding'] ?? false,
      lastBiometricUpdate: d['lastBiometricUpdate'] != null
          ? (d['lastBiometricUpdate'] as Timestamp).toDate()
          : null,
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'gender': gender,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goal': goal,
        'tdee': tdee,
        'dailyCalorieTarget': dailyCalorieTarget,
        'bmi': bmi,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'lastBiometricUpdate': lastBiometricUpdate != null
            ? Timestamp.fromDate(lastBiometricUpdate!)
            : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
