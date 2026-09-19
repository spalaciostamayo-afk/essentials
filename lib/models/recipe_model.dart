class RecipeModel {
  final String title;
  final String image;
  final String time;
  final String difficulty;
  final String description;
  final List<String> ingredients;

  const RecipeModel({
    required this.title,
    required this.image,
    required this.time,
    required this.difficulty,
    required this.description,
    required this.ingredients,
  });
}