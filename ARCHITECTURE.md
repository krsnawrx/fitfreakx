# Fit Freak X — Architecture

## 1. Directory Structure (Feature-First)

```text
lib/
├── main.dart                         # App entry, Firebase init, ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData (scaffoldBg = #F0F0F3)
│   │   ├── colors.dart               # AppColors palette + shadow lists
│   │   └── text_styles.dart          # Poppins / Inter type scale
│   ├── constants/
│   │   └── food_lookup.dart          # Calorie-per-gram lookup map
│   └── router/
│       └── auth_gate.dart            # Auth + onboarding routing guard
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # FirebaseAuth state notifier
│   │   └── models/
│   │       └── app_user.dart
│   │
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   └── onboarding_screen.dart  # Multi-step Discovery Quiz
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart
│   │   └── models/
│   │       └── biometrics.dart
│   │
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   └── dashboard_screen.dart   # Hero cards, ring, quotes, chart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   │
│   ├── meals/
│   │   ├── presentation/
│   │   │   └── meals_tab.dart
│   │   ├── providers/
│   │   │   └── meals_provider.dart
│   │   └── models/
│   │       └── meal_entry.dart
│   │
│   ├── workouts/
│   │   ├── presentation/
│   │   │   └── workouts_tab.dart
│   │   ├── providers/
│   │   │   └── workouts_provider.dart
│   │   └── models/
│   │       └── workout_item.dart
│   │
│   ├── profile/
│   │   ├── presentation/
│   │   │   └── profile_screen.dart
│   │   └── providers/
│   │       └── profile_provider.dart
│   │
│   └── analytics/
│       └── presentation/
│           └── analytics_section.dart  # Inline fl_chart widget
│
└── shared/
    └── widgets/
        ├── neumorphic_box.dart          # Extruded container
        ├── neumorphic_button.dart       # Extruded button with press state
        ├── neumorphic_input.dart        # Inverted (inset) text field
        ├── neumorphic_progress_ring.dart
        └── app_bottom_nav.dart          # 2-tab bottom bar (Meals / Workouts)
```

## 2. State Management — Riverpod

| Layer | Riverpod Primitive | Purpose |
|---|---|---|
| Firebase Auth stream | `StreamProvider<User?>` | Reactively gate login/logout |
| User profile doc | `StreamProvider<AppUser>` | Live Firestore user document |
| Onboarding form | `StateNotifierProvider` | Multi-step quiz state |
| Daily meals list | `StreamProvider` | Today's subcollection stream |
| Workout checklist | `StateNotifierProvider` | Toggle done / undone |
| Dashboard aggregates | `Provider` (computed) | TDEE remaining, BMI, etc. |

## 3. Navigation Strategy

```
main.dart
  └── AuthGate (StreamProvider<User?>)
        ├── User == null  →  LoginScreen
        └── User != null
              ├── hasCompletedOnboarding == false  →  OnboardingScreen
              └── hasCompletedOnboarding == true   →  HomeShell
                                                        ├── DashboardScreen (top)
                                                        ├── BottomNavBar
                                                        │     ├── Tab 0: MealsTab
                                                        │     └── Tab 1: WorkoutsTab
                                                        └── Profile (icon button → push)
```

**Key rule:** No `Navigator.pushReplacement` hacks. The `AuthGate` widget watches the auth stream and the Firestore flag, rebuilding itself reactively. Once onboarding saves `hasCompletedOnboarding: true`, the gate automatically shows `HomeShell`.

## 4. Math Engine

| Formula | Implementation |
|---|---|
| **BMR** (Mifflin-St Jeor) | Male: `10w + 6.25h - 5a + 5`; Female: `10w + 6.25h - 5a - 161` |
| **TDEE** | `BMR × activityMultiplier` (default 1.55 for moderate) |
| **Daily Target** | Goal = Gain → `TDEE + 500`; Goal = Lose → `TDEE - 500`; Maintain → `TDEE` |
| **BMI** | `weight / (height_m)²` |
| **Meal Calories** | `weight_g × lookup[foodName]` (fallback 1.5 kcal/g) |
