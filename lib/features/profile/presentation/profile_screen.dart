import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_input.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _selectedGoal;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h2),
        leading: const BackButton(),
      ),
      body: userAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('$e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          // Pre-fill controllers once
          if (_heightCtrl.text.isEmpty) {
            _heightCtrl.text = user.heightCm.toStringAsFixed(0);
          }
          if (_weightCtrl.text.isEmpty) {
            _weightCtrl.text = user.weightKg.toStringAsFixed(1);
          }
          _selectedGoal ??= user.goal;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Avatar & name ──
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      boxShadow: AppColors.extrudedShadow,
                    ),
                    child: const Icon(Icons.person,
                        size: 40, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(user.email, style: AppTextStyles.bodyMedium)),
                const SizedBox(height: 32),

                // ── Edit biometrics ──
                Text('Edit Biometrics', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                NeumorphicInput(
                  controller: _heightCtrl,
                  hintText: 'Height (cm)',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.height, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                NeumorphicInput(
                  controller: _weightCtrl,
                  hintText: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // ── Goal selector ──
                Text('Goal', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Row(
                  children: ['gain', 'maintain', 'lose'].map((g) {
                    final sel = _selectedGoal == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGoal = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.accent : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: sel ? [] : AppColors.extrudedShadow,
                          ),
                          child: Center(
                            child: Text(
                              g[0].toUpperCase() + g.substring(1),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: sel ? Colors.white : AppColors.textPrimary,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                NeumorphicButton(
                  isAccent: true,
                  onTap: _saving ? null : _saveProfile,
                  child: _saving
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Save Changes', style: AppTextStyles.button),
                ),
                const SizedBox(height: 40),

                // ── Logout ──
                NeumorphicButton(
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: Text('Log Out',
                      style: AppTextStyles.h3
                          .copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 16),

                // ── Delete account ──
                Center(
                  child: TextButton(
                    onPressed: _confirmDelete,
                    child: Text('Delete Account',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h == null || w == null) return;

    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = ref.read(appUserProvider).whenOrNull(data: (u) => u);
    final gender = user?.gender ?? 'male';
    final age = user?.age ?? 25;

    final bmr = gender == 'male'
        ? (10 * w) + (6.25 * h) - (5 * age) + 5
        : (10 * w) + (6.25 * h) - (5 * age) - 161;
    final tdee = bmr * 1.55;
    final hm = h / 100;
    final bmi = w / (hm * hm);
    double target = tdee;
    if (_selectedGoal == 'gain') target += 500;
    if (_selectedGoal == 'lose') target -= 500;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'heightCm': h,
      'weightKg': w,
      'goal': _selectedGoal,
      'tdee': tdee.roundToDouble(),
      'dailyCalorieTarget': target.roundToDouble(),
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'lastBiometricUpdate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('biometric_history')
        .add({
      'date': FieldValue.serverTimestamp(),
      'weightKg': w,
      'bmi': double.parse(bmi.toStringAsFixed(1)),
    });

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  void _confirmDelete() {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Delete Account', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('This is irreversible. Enter your password to confirm.',
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              NeumorphicInput(
                controller: passCtrl,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              NeumorphicButton(
                isAccent: true,
                onTap: () async {
                  try {
                    await ref
                        .read(authServiceProvider)
                        .deleteAccount(passCtrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Failed: $e')),
                      );
                    }
                  }
                },
                child: Text('Delete', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }
}
