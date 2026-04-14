import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_box.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = [
      {'title': 'Push Day (Chest/Tris)', 'group': 'Hypertrophy Volume'},
      {'title': 'Pull Day (Back/Bis)', 'group': 'Hypertrophy Volume'},
      {'title': 'Leg Day (Quads/Hams)', 'group': 'Hypertrophy Power'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts', style: AppTextStyles.h2),
        leading: const BackButton(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final w = workouts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: NeumorphicBox(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.neumorphicShadowOuter,
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.accent),
                ),
                title: Text(w['title']!, style: AppTextStyles.h3),
                subtitle: Text(w['group']!, style: AppTextStyles.bodyMedium),
                trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
              ),
            ),
          );
        },
      ),
    );
  }
}
