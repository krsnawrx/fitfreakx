import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../shared/widgets/home_shell.dart';
import 'login_screen.dart';

/// Reactive routing gate.
/// Watches Firebase Auth + Firestore `hasCompletedOnboarding` flag.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(firebaseAuthProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Auth error: $e', style: AppTextStyles.bodyMedium)),
      ),
      data: (firebaseUser) {
        if (firebaseUser == null) return const LoginScreen();

        // User is logged in — check onboarding flag
        final userAsync = ref.watch(appUserProvider);

        return userAsync.when(
          loading: () => const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
          error: (e, _) => Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('DB error: $e', style: AppTextStyles.bodyMedium)),
          ),
          data: (appUser) {
            if (appUser == null || !appUser.hasCompletedOnboarding) {
              return const OnboardingScreen();
            }
            return const HomeShell();
          },
        );
      },
    );
  }
}
