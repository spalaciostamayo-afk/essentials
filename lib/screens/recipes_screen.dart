import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/food_service.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  List<Map<String, dynamic>> obtenerRecetas(List<FoodModel> foods) {
    final nombres = foods
        .map((e) => e.nombre.toLowerCase())
        .toList();

    List<Map<String, dynamic>> recetas = [];

    if (nombres.contains("banano") || nombres.contains("plátano")) {
      recetas.add({
        "titulo": "Batido de banano",
        "descripcion": "Banano + leche + hielo.",
        "icono": Icons.local_drink,
      });
    }

    if (nombres.contains("tomate")) {
      recetas.add({
        "titulo": "Ensalada de tomate",
        "descripcion": "Tomate, aceite de oliva y sal.",
        "icono": Icons.eco,
      });
    }

    if (nombres.contains("huevo") || nombres.contains("huevos")) {
      recetas.add({
        "titulo": "Tortilla",
        "descripcion": "Huevos con queso o verduras.",
        "icono": Icons.egg,
      });
    }

    if (nombres.contains("pollo")) {
      recetas.add({
        "titulo": "Pollo a la plancha",
        "descripcion": "Ideal para un almuerzo saludable.",
        "icono": Icons.restaurant,
      });
    }

    if (nombres.contains("manzana")) {
      recetas.add({
        "titulo": "Ensalada de frutas",
        "descripcion": "Manzana con otras frutas.",
        "icono": Icons.apple,
      });
    }

    if (recetas.isEmpty) {
      recetas.add({
        "titulo": "Sin recetas",
        "descripcion":
            "Agrega más alimentos para recibir recomendaciones.",
        "icono": Icons.info,
      });
    }

    return recetas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F2),
      appBar: AppBar(
        title: const Text("Recetas recomendadas"),
      ),
      body: StreamBuilder<List<FoodModel>>(
        stream: FoodService.getFoods(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final recetas = obtenerRecetas(snapshot.data!);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              final receta = recetas[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      receta["icono"],
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    receta["titulo"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    receta["descripcion"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}