# Fit Freak X — Firestore Database Schema

## Collection Map

```text
users/
  └── {uid}                              ← User profile document
        ├── daily_logs/
        │     └── {YYYY-MM-DD}           ← One doc per calendar day
        │           ├── meals/
        │           │     └── {mealId}   ← Individual meal entry
        │           └── workouts/
        │                 └── {workoutId} ← Individual workout checklist item
        └── biometric_history/
              └── {logId}                ← Periodic weight/body-fat snapshots
```

---

## 1. `users/{uid}` — Profile Document

| Field | Type | Description |
|---|---|---|
| `email` | `string` | Firebase Auth email |
| `displayName` | `string` | User-chosen name |
| `gender` | `string` | `"male"` or `"female"` |
| `age` | `number` | Years |
| `heightCm` | `number` | Height in centimeters |
| `weightKg` | `number` | Current weight in kilograms |
| `goal` | `string` | `"gain"`, `"lose"`, or `"maintain"` |
| `tdee` | `number` | Calculated Total Daily Energy Expenditure |
| `dailyCalorieTarget` | `number` | TDEE ± 500 based on goal |
| `bmi` | `number` | Calculated BMI |
| `hasCompletedOnboarding` | `boolean` | Auth gate flag |
| `lastBiometricUpdate` | `timestamp` | Used for the 7-day modal check |
| `createdAt` | `timestamp` | Account creation |
| `updatedAt` | `timestamp` | Last profile edit |

---

## 2. `users/{uid}/daily_logs/{YYYY-MM-DD}` — Daily Summary

| Field | Type | Description |
|---|---|---|
| `date` | `timestamp` | Calendar date |
| `totalCaloriesConsumed` | `number` | Auto-aggregate of child meals |
| `workoutsCompleted` | `number` | Count of done items |
| `workoutsTotal` | `number` | Total assigned items |

### 2a. `daily_logs/{date}/meals/{mealId}` — Meal Entry

| Field | Type | Description |
|---|---|---|
| `foodName` | `string` | e.g. `"Chicken Breast"` |
| `weightGrams` | `number` | Weight in grams |
| `caloriesPerGram` | `number` | Lookup multiplier used |
| `totalCalories` | `number` | `weightGrams × caloriesPerGram` |
| `loggedAt` | `timestamp` | Time of entry |

### 2b. `daily_logs/{date}/workouts/{workoutId}` — Workout Checklist Item

| Field | Type | Description |
|---|---|---|
| `name` | `string` | Exercise name |
| `sets` | `number` | Number of sets |
| `reps` | `string` | Rep range (e.g. `"8-12"`) |
| `isDone` | `boolean` | Completion state |
| `completedAt` | `timestamp?` | Null until done |

---

## 3. `users/{uid}/biometric_history/{logId}` — Weight Progression

| Field | Type | Description |
|---|---|---|
| `date` | `timestamp` | Measurement date |
| `weightKg` | `number` | Recorded weight |
| `bodyFatPct` | `number?` | Optional body-fat percentage |
| `bmi` | `number` | Calculated from current height |
| `notes` | `string?` | Free-text note |

---

## Security Rules (Summary)

```
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;

  match /daily_logs/{date} {
    allow read, write: if request.auth.uid == uid;
    match /{subcol}/{docId} {
      allow read, write: if request.auth.uid == uid;
    }
  }

  match /biometric_history/{logId} {
    allow read, write: if request.auth.uid == uid;
  }
}
```

> **⚠️ Awaiting your confirmation on this schema before proceeding to code.**
