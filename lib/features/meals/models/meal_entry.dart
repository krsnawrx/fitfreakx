import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntry {
  final String id;
  final String foodName;
  final double weightGrams;
  final double caloriesPerGram;
  final double totalCalories;
  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.foodName,
    required this.weightGrams,
    required this.caloriesPerGram,
    required this.totalCalories,
    required this.loggedAt,
  });

  factory MealEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MealEntry(
      id: doc.id,
      foodName: d['foodName'] ?? '',
      weightGrams: (d['weightGrams'] ?? 0).toDouble(),
      caloriesPerGram: (d['caloriesPerGram'] ?? 1.5).toDouble(),
      totalCalories: (d['totalCalories'] ?? 0).toDouble(),
      loggedAt: d['loggedAt'] != null
          ? (d['loggedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'foodName': foodName,
        'weightGrams': weightGrams,
        'caloriesPerGram': caloriesPerGram,
        'totalCalories': totalCalories,
        'loggedAt': Timestamp.fromDate(loggedAt),
      };
}
