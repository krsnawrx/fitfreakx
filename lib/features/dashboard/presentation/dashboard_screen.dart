import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_box.dart';
import '../../../shared/widgets/neumorphic_progress_ring.dart';
import '../../../shared/services/mock_database_service.dart';
import '../../workouts/presentation/workouts_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mockDatabaseProvider).currentUser;
    final tdee = user?.tdee ?? 2800;
    
    // Hardcoded mock values for UI evaluation
    const caloriesConsumed = 1800.0;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dashboard', style: AppTextStyles.h1),
                  const CircleAvatar(
                    backgroundColor: AppColors.shadowDepth,
                    child: Icon(Icons.person, color: AppColors.background),
                  )
                ],
              ),
              const SizedBox(height: 32),
              
              Center(
                child: NeumorphicProgressRing(
                  radius: 120.0,
                  percent: caloriesConsumed / tdee,
                  progressColor: AppColors.accent,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (tdee - caloriesConsumed).toStringAsFixed(0),
                        style: AppTextStyles.accentNumber.copyWith(fontSize: 40),
                      ),
                      Text('kcal left', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              Text('Quick Actions', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(context, 'Workouts', Icons.fitness_center),
                    _buildActionCard(context, 'Nutrition', Icons.restaurant),
                    _buildActionCard(context, 'Analytics', Icons.show_chart),
                    _buildActionCard(context, 'Settings', Icons.settings),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Workouts') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutsScreen()));
        } else if (title == 'Analytics') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
        }
      },
      child: NeumorphicBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.h3),
          ],
        ),
      ),
    );
  }
}
