class Recipe {
  final int? id;
  final String title;
  final int recipeTypeId;
  final String? imagePath;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    this.id,
    required this.title,
    required this.recipeTypeId,
    this.imagePath,
    required this.ingredients,
    required this.steps,
  });
}
