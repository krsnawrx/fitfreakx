/// Calorie-per-gram lookup for common foods.
/// Falls back to 1.5 kcal/g for unknown items.
const Map<String, double> kFoodCaloriesPerGram = {
  'chicken breast': 1.65,
  'chicken': 1.65,
  'rice': 1.30,
  'white rice': 1.30,
  'brown rice': 1.10,
  'eggs': 1.55,
  'egg': 1.55,
  'oats': 3.89,
  'oatmeal': 0.68,
  'banana': 0.89,
  'milk': 0.42,
  'whole milk': 0.61,
  'whey protein': 4.00,
  'protein shake': 1.20,
  'bread': 2.65,
  'peanut butter': 5.88,
  'almonds': 5.79,
  'salmon': 2.08,
  'tuna': 1.32,
  'beef': 2.50,
  'steak': 2.71,
  'pasta': 1.31,
  'sweet potato': 0.86,
  'potato': 0.77,
  'broccoli': 0.34,
  'spinach': 0.23,
  'avocado': 1.60,
  'greek yogurt': 0.59,
  'yogurt': 0.59,
  'cheese': 4.02,
  'olive oil': 8.84,
  'butter': 7.17,
  'apple': 0.52,
  'orange': 0.47,
};

const double kDefaultCaloriesPerGram = 1.5;

double lookupCalories(String foodName, double weightGrams) {
  final key = foodName.trim().toLowerCase();
  final perGram = kFoodCaloriesPerGram[key] ?? kDefaultCaloriesPerGram;
  return weightGrams * perGram;
}
