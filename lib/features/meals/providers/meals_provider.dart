import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_entry.dart';

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

CollectionReference<Map<String, dynamic>> _mealsRef() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('daily_logs')
      .doc(_todayKey())
      .collection('meals');
}

final todayMealsProvider = StreamProvider<List<MealEntry>>((ref) {
  return _mealsRef().orderBy('loggedAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => MealEntry.fromFirestore(d)).toList());
});

final totalCaloriesTodayProvider = Provider<double>((ref) {
  final mealsAsync = ref.watch(todayMealsProvider);
  final meals = mealsAsync.whenOrNull(data: (d) => d) ?? [];
  return meals.fold<double>(0, (total, m) => total + m.totalCalories);
});

Future<void> addMeal(MealEntry meal) async {
  final todayDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('daily_logs')
      .doc(_todayKey());

  // Ensure the daily_logs parent doc exists
  await todayDoc.set({'date': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  await todayDoc.collection('meals').add(meal.toMap());
}

Future<void> deleteMeal(String mealId) async {
  await _mealsRef().doc(mealId).delete();
}
