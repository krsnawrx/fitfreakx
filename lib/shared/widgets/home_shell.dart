import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/meals/presentation/meals_tab.dart';
import '../../features/workouts/presentation/workouts_tab.dart';

/// Top-level shell: Dashboard lives above, Meals/Workouts in a bottom-nav pair.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0; // 0 = Dashboard, 1 = Meals, 2 = Workouts

  static const _pages = <Widget>[
    DashboardScreen(),
    MealsTab(),
    WorkoutsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_tabIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: Offset(0, -3),
              blurRadius: 10,
            ),
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _tabIndex,
            onTap: (i) => setState(() => _tabIndex = i),
            backgroundColor: AppColors.background,
            elevation: 0,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.accent),
            unselectedLabelStyle: AppTextStyles.bodySmall,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_outlined),
                activeIcon: Icon(Icons.restaurant),
                label: 'Meals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Workouts',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
