import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_box.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/services/mock_database_service.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  double heightCm = 175;
  double weightKg = 70;
  bool _isLoading = false;

  void calculateAndSave() async {
    setState(() => _isLoading = true);
    
    // Mifflin-St Jeor + 500 surplus for Hypertrophy 
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * 25) + 5;
    double tdee = bmr * 1.55 + 500; 

    await ref.read(mockDatabaseProvider).saveUserBiometrics(
      height: heightCm,
      weight: weightKg,
      tdee: tdee,
      goal: 'Hypertrophy / V-Taper',
    );
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('Build Your\nV-Taper', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('Enter your biometrics to calculate your hypertrophy macros.', 
                style: AppTextStyles.bodyMedium),
              const Spacer(),
              
              NeumorphicBox(
                child: Column(
                  children: [
                    Text('Height', style: AppTextStyles.bodyMedium),
                    Slider(
                      value: heightCm,
                      min: 140, max: 220,
                      activeColor: AppColors.accent,
                      onChanged: (val) => setState(() => heightCm = val),
                    ),
                    Text('${heightCm.toStringAsFixed(0)} cm', style: AppTextStyles.accentNumber),
                  ],
                )
              ),
              const SizedBox(height: 32),
              NeumorphicBox(
                child: Column(
                  children: [
                    Text('Current Weight', style: AppTextStyles.bodyMedium),
                    Slider(
                      value: weightKg,
                      min: 40, max: 150,
                      activeColor: AppColors.accent,
                      onChanged: (val) => setState(() => weightKg = val),
                    ),
                    Text('${weightKg.toStringAsFixed(1)} kg', style: AppTextStyles.accentNumber),
                  ],
                )
              ),
              
              const Spacer(),
              NeumorphicButton(
                isAccent: true,
                onTap: _isLoading ? () {} : calculateAndSave,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Generate Strategy', 
                        style: AppTextStyles.h3.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          )
        ),
      ),
    );
  }
}
