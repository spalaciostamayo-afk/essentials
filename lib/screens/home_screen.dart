import 'package:flutter/material.dart';

import '../models/food_model.dart';


import '../services/food_service.dart';

import '../data/recipes_data.dart';

import '../widgets/food_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/recipe_card.dart';

import 'add_food_screen.dart';
import 'edit_food_screen.dart';
import 'statistics_screen.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodModel>>(
      stream: FoodService.getFoods(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final foods = snapshot.data!;

        final totalFoods = foods.length;

        final expiredFoods = foods.where((food) {
          return food.diasRestantes < 0;
        }).length;

        final expiringFoods = foods.where((food) {
          return food.diasRestantes >= 0 &&
              food.diasRestantes <= 3;
        }).length;

        final recetasDisponibles = recipes.where((recipe) {
          int coincidencias = 0;

          for (final ingrediente in recipe.ingredients) {
            if (foods.any(
              (food) =>
                  food.nombre.toLowerCase() ==
                  ingrediente.toLowerCase(),
            )) {
              coincidencias++;
            }
          }

          return coincidencias >= 2;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xffF6F8FB),

          appBar: AppBar(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text("Essentials"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFoodScreen(),
                        ),
                      );
                    },

                    icon: const Icon(Icons.add),

                    label: const Text(
                      "Agregar alimento",
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Mis alimentos",

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (foods.isEmpty)
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Center(
                      child: Text(
                        "Aún no has agregado alimentos.",

                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount: foods.length,

                    itemBuilder: (context, index) {
                      final food = foods[index];

                      return FoodCard(
                        food: food,

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditFoodScreen(
                                food: food,
                              ),
                            ),
                          );
                        },

                        onDelete: () {
                          FoodService.deleteFood(
                            food.id,
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 30),

                const Text(
                  "Resumen",

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: "Alimentos",
                        value: totalFoods.toString(),
                        icon: Icons.inventory_2,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: StatsCard(
                        title: "Por vencer",
                        value: expiringFoods.toString(),
                        icon:
                            Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: "Vencidos",
                        value: expiredFoods.toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: StatsCard(
                        title: "Recetas",
                        value: recetasDisponibles
                            .length
                            .toString(),
                        icon: Icons.restaurant_menu,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      "Recetas recomendadas",

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const StatisticsScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Ver estadísticas",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 340,

                  child: recetasDisponibles.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay recetas disponibles con tus alimentos.",

                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection:
                              Axis.horizontal,

                          itemCount:
                              recetasDisponibles.length,

                          itemBuilder:
                              (context, index) {
                            final recipe =
                                recetasDisponibles[
                                    index];

                            return RecipeCard(
                              imageUrl: recipe.image,

                              title: recipe.title,

                              time: recipe.time,

                              difficulty:
                                  recipe.difficulty,

                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(
                                      recipe: recipe,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 35),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.green.shade50,

                    borderRadius:
                        BorderRadius.circular(22),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: Colors.green,
                            size: 34,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Impacto ambiental",

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Controlando las fechas de vencimiento reduces el desperdicio de alimentos y contribuyes al cuidado del medio ambiente.",

                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "Actualmente tienes $expiredFoods alimentos vencidos y $expiringFoods próximos a vencer.",

                              style:
                                  const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,

            onDestinationSelected: (index) {
              if (index == currentIndex) {
                return;
              }

              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const StatisticsScreen(),
                  ),
                );
              }

              setState(() {
                currentIndex = index;
              });
            },

            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: "Inicio",
              ),

              NavigationDestination(
                icon: Icon(Icons.bar_chart),
                label: "Estadísticas",
              ),
            ],
          ),
        );
      },
    );
  }
}