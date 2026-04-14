import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/motivational_quotes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/neumorphic_input.dart';
import '../../../shared/widgets/neumorphic_progress_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../meals/providers/meals_provider.dart';
import '../../workouts/providers/workouts_provider.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _biometricModalChecked = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserProvider);
    final totalCal = ref.watch(totalCaloriesTodayProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('$e')),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        // ── Weekly biometric check ──
        if (!_biometricModalChecked) {
          _biometricModalChecked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkWeeklyBiometric(user.lastBiometricUpdate);
          });
        }

        final remaining = (user.dailyCalorieTarget - totalCal).clamp(0, 99999);
        final pct = totalCal / user.dailyCalorieTarget;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top bar ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard', style: AppTextStyles.h1),
                      Text('Stay on track.', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        boxShadow: AppColors.extrudedShadow,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Hero tiles (Height / Weight / BMI) ──
              Row(
                children: [
                  _heroTile('Height', '${user.heightCm.toStringAsFixed(0)} cm'),
                  const SizedBox(width: 12),
                  _heroTile('Weight', '${user.weightKg.toStringAsFixed(1)} kg'),
                  const SizedBox(width: 12),
                  _heroTile('BMI', user.bmi.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 32),

              // ── Calorie ring ──
              Center(
                child: NeumorphicProgressRing(
                  radius: 110,
                  percent: pct,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(remaining.toStringAsFixed(0),
                          style: AppTextStyles.accentNumber
                              .copyWith(fontSize: 36)),
                      Text('kcal left', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Target: ${user.dailyCalorieTarget.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 32),

              // ── Today's workout preview ──
              _workoutPreview(),
              const SizedBox(height: 24),

              // ── Analytics chart ──
              Text('Weight History', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              _weightChart(),
              const SizedBox(height: 24),

              // ── Motivational quote ──
              _quoteCard(),
            ],
          ),
        );
      },
    );
  }

  // ── Helper widgets ──

  Widget _heroTile(String label, String value) {
    return Expanded(
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.accentNumber.copyWith(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _workoutPreview() {
    final workoutsAsync = ref.watch(todayWorkoutsProvider);
    return workoutsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final done = items.where((w) => w.isDone).length;
        final total = items.length;
        return NeumorphicContainer(
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppColors.accent, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Workouts', style: AppTextStyles.h3),
                    Text('$done of $total completed',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text('$done/$total',
                  style: AppTextStyles.accentNumber.copyWith(fontSize: 20)),
            ],
          ),
        );
      },
    );
  }

  Widget _weightChart() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return NeumorphicContainer(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 12),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('biometric_history')
            .orderBy('date')
            .limitToLast(10)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
                child: Text('No data yet.', style: AppTextStyles.bodyMedium));
          }
          final docs = snap.data!.docs;
          final spots = <FlSpot>[];
          for (int i = 0; i < docs.length; i++) {
            final d = docs[i].data() as Map<String, dynamic>;
            spots.add(FlSpot(i.toDouble(), (d['weightKg'] ?? 70).toDouble()));
          }
          return LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('${v.toInt() + 1}',
                          style: AppTextStyles.bodySmall),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.accent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.accent.withAlpha(40),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quoteCard() {
    final quote =
        kMotivationalQuotes[Random().nextInt(kMotivationalQuotes.length)];
    return NeumorphicContainer(
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppColors.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(quote,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  // ── Weekly biometric modal ──
  void _checkWeeklyBiometric(DateTime? lastUpdate) {
    if (lastUpdate == null) return;
    final diff = DateTime.now().difference(lastUpdate).inDays;
    if (diff < 7) return;

    final weightCtrl = TextEditingController();

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
              const Icon(Icons.monitor_weight_outlined,
                  color: AppColors.accent, size: 48),
              const SizedBox(height: 16),
              Text('Weekly Check-in', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('It\'s been $diff days. Update your weight?',
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              NeumorphicInput(
                controller: weightCtrl,
                hintText: 'New weight (kg)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              NeumorphicButton(
                isAccent: true,
                onTap: () async {
                  final w = double.tryParse(weightCtrl.text.trim());
                  if (w == null || w <= 0) return;
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final heightCm = ref
                      .read(appUserProvider)
                      .whenOrNull(data: (u) => u?.heightCm) ?? 175;
                  final hm = heightCm / 100;
                  final bmi = w / (hm * hm);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'weightKg': w,
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
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text('Save', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
