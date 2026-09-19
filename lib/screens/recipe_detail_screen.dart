import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  Color get difficultyColor {
    switch (recipe.difficulty) {
      case "Difícil":
        return Colors.red;
      case "Media":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(recipe.title),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: recipe.title,
              child: Image.network(
                recipe.image,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.green,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        recipe.time,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(width: 30),

                      Icon(
                        Icons.local_fire_department,
                        color: difficultyColor,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        recipe.difficulty,
                        style: TextStyle(
                          fontSize: 17,
                          color: difficultyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Ingredientes",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...recipe.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 22,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Preparación",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      recipe.description,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}