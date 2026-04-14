# Database Schema (Firestore)

This document outlines the Firestore collections and document structures for Fit Freak X.

## Collections

### 1. `users`
Stores user profile data, biomechanics, and global settings.
- `uid` (Document ID) - Matched to Firebase Auth
- `email` (String)
- `displayName` (String)
- `photoUrl` (String, Optional)
- `height` (Number) - in cm
- `weight` (Number) - in kg
- `tdee` (Number) - Total Daily Energy Expenditure
- `goal` (String) - e.g., 'hypertrophy', 'cutting', 'maintenance'
- `createdAt` (Timestamp)

### 2. `workouts`
A master library of available public workouts.
- `workoutId` (Document ID)
- `title` (String)
- `description` (String)
- `targetMuscleGroup` (String)
- `exercises` (Array of Map)
  - `exerciseId` (String)
  - `name` (String)
  - `sets` (Number)
  - `reps` (String)
  - `restSeconds` (Number)
  - `videoUrl` (String)

### 3. `user_workouts` (Subcollection under `users/{uid}`)
Tracks a user's completed or in-progress workouts.
- `logId` (Document ID)
- `workoutId` (String)
- `date` (Timestamp)
- `duration` (Number) - in minutes
- `volume` (Number) - total weight moved
- `isCompleted` (Boolean)

### 4. `meals` (Subcollection under `users/{uid}`)
Tracks daily nutrition logged by the user.
- `mealId` (Document ID)
- `date` (Timestamp)
- `type` (String) - 'breakfast', 'lunch', 'dinner', 'snack'
- `name` (String)
- `calories` (Number)
- `protein` (Number)
- `carbs` (Number)
- `fat` (Number)

### 5. `progress_logs` (Subcollection under `users/{uid}`)
Tracks body weight and metric progression over time for analytics charts.
- `logId` (Document ID)
- `date` (Timestamp)
- `weight` (Number)
- `bodyFatPercentage` (Number, Optional)
- `notes` (String, Optional)
