import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/workouts_provider.dart';

class WorkoutsTab extends ConsumerStatefulWidget {
  const WorkoutsTab({super.key});

  @override
  ConsumerState<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends ConsumerState<WorkoutsTab> {
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    // Seed workouts once from the user's goal
    final userAsync = ref.watch(appUserProvider);
    if (!_seeded) {
      userAsync.whenData((user) {
        if (user != null) {
          seedTodayWorkouts(user.goal);
          _seeded = true;
        }
      });
    }

    final workoutsAsync = ref.watch(todayWorkoutsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Today's Workout", style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('Check off exercises as you go.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          Expanded(
            child: workoutsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text('Loading workout…',
                        style: AppTextStyles.bodyMedium),
                  );
                }
                final done = items.where((w) => w.isDone).length;
                return Column(
                  children: [
                    // Progress bar
                    NeumorphicContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Text('$done / ${items.length}',
                              style: AppTextStyles.accentNumber
                                  .copyWith(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: items.isEmpty
                                    ? 0
                                    : done / items.length,
                                minHeight: 10,
                                backgroundColor: const Color(0xFFE0E0E3),
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final w = items[i];
                          return GestureDetector(
                            onTap: () =>
                                toggleWorkoutDone(w.id, w.isDone),
                            child: NeumorphicContainer(
                              flat: w.isDone,
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: w.isDone
                                          ? AppColors.accent
                                          : AppColors.background,
                                      border: w.isDone
                                          ? null
                                          : Border.all(
                                              color: AppColors.shadowDark,
                                              width: 2),
                                    ),
                                    child: w.isDone
                                        ? const Icon(Icons.check,
                                            size: 16,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          w.name,
                                          style:
                                              AppTextStyles.bodyLarge.copyWith(
                                            decoration: w.isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: w.isDone
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${w.sets} sets × ${w.reps}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
