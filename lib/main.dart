import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: FitFreakXApp()));
}

class FitFreakXApp extends StatelessWidget {
  const FitFreakXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Freak X',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
