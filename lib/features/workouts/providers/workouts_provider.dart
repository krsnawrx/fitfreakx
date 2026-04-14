import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/workout_templates.dart';
import '../models/workout_item.dart';

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

CollectionReference<Map<String, dynamic>> _workoutsRef() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('daily_logs')
      .doc(_todayKey())
      .collection('workouts');
}

final todayWorkoutsProvider = StreamProvider<List<WorkoutItem>>((ref) {
  return _workoutsRef().snapshots().map(
      (snap) => snap.docs.map((d) => WorkoutItem.fromFirestore(d)).toList());
});

/// Seeds today's workout checklist from the template if it's empty.
Future<void> seedTodayWorkouts(String goal) async {
  final snap = await _workoutsRef().limit(1).get();
  if (snap.docs.isNotEmpty) return; // already seeded

  final template = kWorkoutTemplates[goal] ?? kWorkoutTemplates['gain']!;

  final todayDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('daily_logs')
      .doc(_todayKey());

  await todayDoc.set({'date': FieldValue.serverTimestamp()}, SetOptions(merge: true));

  final batch = FirebaseFirestore.instance.batch();
  for (final w in template) {
    batch.set(_workoutsRef().doc(), {
      'name': w['name'],
      'sets': w['sets'],
      'reps': w['reps'],
      'isDone': false,
      'completedAt': null,
    });
  }
  await batch.commit();
}

Future<void> toggleWorkoutDone(String docId, bool currentDone) async {
  await _workoutsRef().doc(docId).update({
    'isDone': !currentDone,
    'completedAt': !currentDone ? FieldValue.serverTimestamp() : null,
  });
}
