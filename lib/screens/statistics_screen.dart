import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/food_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F2),

      appBar: AppBar(
        title: const Text("Estadísticas"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<FoodModel>>(
        stream: FoodService.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final foods = snapshot.data!;

          final total = foods.length;

          final vencidos =
              foods.where((e) => e.diasRestantes < 0).length;

          final porVencer =
              foods.where((e) => e.diasRestantes >= 0 && e.diasRestantes <= 3).length;

          final frutas =
              foods.where((e) => e.categoria == "Frutas").length;

          final verduras =
              foods.where((e) => e.categoria == "Verduras").length;

          final lacteos =
              foods.where((e) => e.categoria == "Lácteos").length;

          final carnes =
              foods.where((e) => e.categoria == "Carnes").length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              _card(
                "Total de alimentos",
                total.toString(),
                Icons.inventory,
                Colors.green,
              ),

              const SizedBox(height: 20),

              _card(
                "Por vencer",
                porVencer.toString(),
                Icons.warning_amber,
                Colors.orange,
              ),

              const SizedBox(height: 20),

              _card(
                "Vencidos",
                vencidos.toString(),
                Icons.dangerous,
                Colors.red,
              ),

              const SizedBox(height: 30),

              const Text(
                "Alimentos por categoría",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _category("🍎 Frutas", frutas),

              _category("🥦 Verduras", verduras),

              _category("🥛 Lácteos", lacteos),

              _category("🥩 Carnes", carnes),
            ],
          );
        },
      ),
    );
  }

  Widget _card(
      String titulo,
      String valor,
      IconData icono,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(
              icono,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(String nombre, int cantidad) {
    return Card(
      child: ListTile(
        title: Text(nombre),
        trailing: Text(
          cantidad.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}