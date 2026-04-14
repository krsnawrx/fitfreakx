import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _saving = false;

  // ── Collected Data ──
  String _gender = 'male';
  double _heightCm = 175;
  double _weightKg = 70;
  int _age = 25;
  double _activityMultiplier = 1.55; // moderate
  String _goal = 'gain';

  void _next() {
    if (_currentPage < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    // Mifflin-St Jeor
    final bmr = _gender == 'male'
        ? (10 * _weightKg) + (6.25 * _heightCm) - (5 * _age) + 5
        : (10 * _weightKg) + (6.25 * _heightCm) - (5 * _age) - 161;

    final tdee = bmr * _activityMultiplier;
    final heightM = _heightCm / 100;
    final bmi = _weightKg / (heightM * heightM);

    double target = tdee;
    if (_goal == 'gain') target += 500;
    if (_goal == 'lose') target -= 500;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'gender': _gender,
      'age': _age,
      'heightCm': _heightCm,
      'weightKg': _weightKg,
      'goal': _goal,
      'tdee': tdee.roundToDouble(),
      'dailyCalorieTarget': target.roundToDouble(),
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'hasCompletedOnboarding': true,
      'lastBiometricUpdate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Seed first biometric history entry
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('biometric_history')
        .add({
      'date': FieldValue.serverTimestamp(),
      'weightKg': _weightKg,
      'bmi': double.parse(bmi.toStringAsFixed(1)),
    });

    // AuthGate will automatically redirect to HomeShell
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress dots ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i <= _currentPage
                            ? AppColors.accent
                            : AppColors.shadowDark,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ──
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildGenderPage(),
                  _buildMeasurementsPage(),
                  _buildAgeActivityPage(),
                  _buildGoalPage(),
                ],
              ),
            ),

            // ── Nav buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: NeumorphicButton(
                        onTap: _back,
                        child: Text('Back', style: AppTextStyles.h3),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: NeumorphicButton(
                      isAccent: true,
                      onTap: _saving ? null : _next,
                      child: _saving
                          ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              _currentPage == 3 ? 'Finish' : 'Next',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page 1: Gender ──
  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('What\'s your\ngender?', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('This affects your BMR calculation.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(child: _genderTile('male', Icons.male, 'Male')),
              const SizedBox(width: 20),
              Expanded(child: _genderTile('female', Icons.female, 'Female')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderTile(String value, IconData icon, String label) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? [] : AppColors.extrudedShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.h3.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            )),
          ],
        ),
      ),
    );
  }

  // ── Page 2: Height & Weight ──
  Widget _buildMeasurementsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Your\nMeasurements', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('We use these to calculate your TDEE.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          NeumorphicContainer(
            child: Column(
              children: [
                Text('Height', style: AppTextStyles.bodyMedium),
                Slider(
                  value: _heightCm,
                  min: 140, max: 220,
                  onChanged: (v) => setState(() => _heightCm = v),
                ),
                Text('${_heightCm.toStringAsFixed(0)} cm', style: AppTextStyles.accentNumber),
              ],
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicContainer(
            child: Column(
              children: [
                Text('Weight', style: AppTextStyles.bodyMedium),
                Slider(
                  value: _weightKg,
                  min: 35, max: 180,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
                Text('${_weightKg.toStringAsFixed(1)} kg', style: AppTextStyles.accentNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 3: Age & Activity ──
  Widget _buildAgeActivityPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Age &\nActivity Level', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('Fine-tune your calorie target.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          NeumorphicContainer(
            child: Column(
              children: [
                Text('Age', style: AppTextStyles.bodyMedium),
                Slider(
                  value: _age.toDouble(),
                  min: 14, max: 65,
                  divisions: 51,
                  onChanged: (v) => setState(() => _age = v.round()),
                ),
                Text('$_age years', style: AppTextStyles.accentNumber),
              ],
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Activity Level', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                ..._activityOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _activityOptions() {
    final options = <MapEntry<String, double>>[
      const MapEntry('Sedentary', 1.2),
      const MapEntry('Lightly Active', 1.375),
      const MapEntry('Moderately Active', 1.55),
      const MapEntry('Very Active', 1.725),
    ];
    return options.map((e) {
      final selected = _activityMultiplier == e.value;
      return GestureDetector(
        onTap: () => setState(() => _activityMultiplier = e.value),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            e.key,
            style: AppTextStyles.bodyLarge.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Page 4: Goal ──
  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Your\nGoal', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('We\'ll adjust your daily calories accordingly.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 48),
          _goalTile('gain', Icons.trending_up, 'Lean Bulk', '+500 kcal surplus'),
          const SizedBox(height: 16),
          _goalTile('lose', Icons.trending_down, 'Fat Loss', '-500 kcal deficit'),
          const SizedBox(height: 16),
          _goalTile('maintain', Icons.horizontal_rule, 'Maintain', 'Stay at TDEE'),
        ],
      ),
    );
  }

  Widget _goalTile(String value, IconData icon, String title, String sub) {
    final selected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? [] : AppColors.extrudedShadow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: selected ? Colors.white : AppColors.accent),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                )),
                Text(sub, style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white70 : AppColors.textSecondary,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
