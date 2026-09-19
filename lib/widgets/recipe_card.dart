import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String time;
  final String difficulty;
  final VoidCallback onPressed;

  const RecipeCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.time,
    required this.difficulty,
    required this.onPressed,
  });

  Color get difficultyColor {
    switch (difficulty) {
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
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: difficultyColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        difficulty,
                        style: TextStyle(
                          color: difficultyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text("Ver receta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}