# Fit Freak X Architecture

## State Management
We will be using **Riverpod** for state management due to its compile-time safety, scalability, and ease of testing. Riverpod will handle everything from simple UI state to complex asynchronous Firebase streams.

## Directory Structure (Feature-First)
The project will follow a feature-first architecture, keeping all related code (UI, logic, models, services) within a specific feature folder. This improves maintainability and scalability.

```text
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   └── neumorphic_utils.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── routing/
│       └── app_router.dart
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── models/
│   ├── onboarding/
│   │   ├── presentation/
│   │   ├── providers/
│   │   └── models/
│   ├── dashboard/
│   │   ├── presentation/
│   │   └── providers/
│   ├── workouts/
│   │   ├── presentation/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── models/
│   ├── nutrition/
│   │   ├── presentation/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── models/
│   └── analytics/
│       ├── presentation/
│       ├── providers/
│       ├── repositories/
│       └── models/
└── shared/
    ├── widgets/
    │   ├── neumorphic_box.dart
    │   ├── neumorphic_button.dart
    │   └── neumorphic_progress_ring.dart
    └── services/
        ├── firebase_service.dart
        └── storage_service.dart
```

## Dependency Injection
We will use Riverpod's `ProviderScope` to manage dependency injection at the top level and inject services and repositories directly into our controllers/notifiers.
