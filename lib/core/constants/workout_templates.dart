/// Workout templates keyed by user goal.
const Map<String, List<Map<String, dynamic>>> kWorkoutTemplates = {
  'gain': [
    {'name': 'Barbell Bench Press', 'sets': 4, 'reps': '8-12'},
    {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': '10-12'},
    {'name': 'Barbell Squat', 'sets': 4, 'reps': '6-10'},
    {'name': 'Romanian Deadlift', 'sets': 3, 'reps': '8-12'},
    {'name': 'Overhead Press', 'sets': 3, 'reps': '8-10'},
    {'name': 'Barbell Row', 'sets': 4, 'reps': '8-12'},
    {'name': 'Lateral Raises', 'sets': 3, 'reps': '12-15'},
    {'name': 'Bicep Curls', 'sets': 3, 'reps': '10-12'},
  ],
  'lose': [
    {'name': 'Goblet Squat', 'sets': 3, 'reps': '12-15'},
    {'name': 'Push-Ups', 'sets': 3, 'reps': '15-20'},
    {'name': 'Lunges', 'sets': 3, 'reps': '12 each'},
    {'name': 'Plank Hold', 'sets': 3, 'reps': '45s'},
    {'name': 'Jumping Jacks', 'sets': 3, 'reps': '30'},
    {'name': 'Mountain Climbers', 'sets': 3, 'reps': '20'},
    {'name': 'Burpees', 'sets': 3, 'reps': '10'},
  ],
  'maintain': [
    {'name': 'Bench Press', 'sets': 3, 'reps': '10'},
    {'name': 'Squat', 'sets': 3, 'reps': '10'},
    {'name': 'Pull-Ups', 'sets': 3, 'reps': '8-10'},
    {'name': 'Dumbbell Rows', 'sets': 3, 'reps': '10'},
    {'name': 'Shoulder Press', 'sets': 3, 'reps': '10'},
    {'name': 'Leg Press', 'sets': 3, 'reps': '12'},
  ],
};
