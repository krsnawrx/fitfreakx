import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/food_lookup.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/neumorphic_input.dart';
import '../models/meal_entry.dart';
import '../providers/meals_provider.dart';

class MealsTab extends ConsumerStatefulWidget {
  const MealsTab({super.key});

  @override
  ConsumerState<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends ConsumerState<MealsTab> {
  final _foodCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  Future<void> _add() async {
    final name = _foodCtrl.text.trim();
    final grams = double.tryParse(_weightCtrl.text.trim());
    if (name.isEmpty || grams == null || grams <= 0) return;

    final key = name.toLowerCase();
    final perGram = kFoodCaloriesPerGram[key] ?? kDefaultCaloriesPerGram;
    final total = grams * perGram;

    await addMeal(MealEntry(
      id: '',
      foodName: name,
      weightGrams: grams,
      caloriesPerGram: perGram,
      totalCalories: total,
      loggedAt: DateTime.now(),
    ));

    _foodCtrl.clear();
    _weightCtrl.clear();
  }

  @override
  void dispose() {
    _foodCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(todayMealsProvider);
    final totalCal = ref.watch(totalCaloriesTodayProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Add Meal Form ──
          NeumorphicContainer(
            child: Column(
              children: [
                Text('Log a Meal', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                NeumorphicInput(
                  controller: _foodCtrl,
                  hintText: 'Food name (e.g. Chicken)',
                  prefixIcon: const Icon(Icons.restaurant, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                NeumorphicInput(
                  controller: _weightCtrl,
                  hintText: 'Weight (grams)',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.scale, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  isAccent: true,
                  onTap: _add,
                  child: Text('Add Meal', style: AppTextStyles.button),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Daily total ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Meals", style: AppTextStyles.h3),
              Text('${totalCal.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.accentNumber.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),

          // ── Meal list ──
          Expanded(
            child: mealsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(child: Text('$e')),
              data: (meals) {
                if (meals.isEmpty) {
                  return Center(
                    child: Text('No meals logged yet.',
                        style: AppTextStyles.bodyMedium),
                  );
                }
                return ListView.separated(
                  itemCount: meals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final m = meals[i];
                    return Dismissible(
                      key: ValueKey(m.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => deleteMeal(m.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: NeumorphicContainer(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.foodName, style: AppTextStyles.bodyLarge),
                                  Text('${m.weightGrams.toStringAsFixed(0)}g',
                                      style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            Text('${m.totalCalories.toStringAsFixed(0)} kcal',
                                style: AppTextStyles.accentNumber.copyWith(fontSize: 18)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
