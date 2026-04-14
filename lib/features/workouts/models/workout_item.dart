import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutItem {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final bool isDone;
  final DateTime? completedAt;

  const WorkoutItem({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.isDone,
    this.completedAt,
  });

  factory WorkoutItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutItem(
      id: doc.id,
      name: d['name'] ?? '',
      sets: (d['sets'] ?? 3).toInt(),
      reps: d['reps'] ?? '10',
      isDone: d['isDone'] ?? false,
      completedAt: d['completedAt'] != null
          ? (d['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'isDone': isDone,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  WorkoutItem copyWith({bool? isDone, DateTime? completedAt}) {
    return WorkoutItem(
      id: id,
      name: name,
      sets: sets,
      reps: reps,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
