
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/recipe_card.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';
import '../data/recipes_data.dart';
import '../widgets/food_card.dart';
import '../bluetooth_screen.dart';

import 'add_food_screen.dart';
import 'edit_food_screen.dart';
import 'statistics_screen.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';

const Color verdePrincipal = Color(0xFF12381D);
const Color verdeSecundario = Color(0xFF3F7048);
const Color beigeFondo = Color(0xFFF3EED8);
const Color blancoTarjeta = Colors.white;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  late Future<String> tipoCuentaFuture;

  @override
  void initState() {
    super.initState();
    tipoCuentaFuture = cargarTipoCuenta();
  }

  Future<String> cargarTipoCuenta() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) return 'hogar';

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      final tipo = documento.data()?['tipoCuenta']
          ?.toString()
          .toLowerCase()
          .trim();

      if (tipo == null || tipo.isEmpty) return 'hogar';
      if (tipo.contains('colegio')) return 'colegio';
      if (tipo.contains('empresa')) return 'empresa';

      return 'hogar';
    } catch (_) {
      return 'hogar';
    }
  }

  void abrirAgregarAlimento() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFoodScreen(),
      ),
    );
  }

  void abrirBluetooth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BluetoothScreen(),
      ),
    );
  }

  void abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void abrirEstadisticas([String filtro = 'Todos']) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(
          initialFilter: filtro,
        ),
      ),
    );
  }

  Future<void> eliminarAlimento(FoodModel food) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alimento'),
          content: Text(
            '¿Quieres eliminar "${food.nombre}" de tu inventario?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await FoodService.deleteFood(food.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.nombre} eliminado correctamente.'),
          backgroundColor: verdePrincipal,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el alimento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodModel>>(
      stream: FoodService.getFoods(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: beigeFondo,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: verdePrincipal,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los alimentos.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tipoCuentaFuture = cargarTipoCuenta();
                        });
                      },
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: beigeFondo,
            body: Center(
              child: CircularProgressIndicator(
                color: verdePrincipal,
              ),
            ),
          );
        }

        final foods = snapshot.data!;

        final totalFoods = foods.length;

        final expiredFoods = foods
            .where((food) => food.diasRestantes < 0)
            .length;

        final expiringFoods = foods
            .where(
              (food) =>
                  food.diasRestantes >= 0 &&
                  food.diasRestantes <= 3,
            )
            .length;

        final recetasDisponibles = recipes.where((recipe) {
          int coincidencias = 0;

          for (final ingrediente in recipe.ingredients) {
            if (foods.any(
              (food) =>
                  food.nombre.trim().toLowerCase() ==
                  ingrediente.trim().toLowerCase(),
            )) {
              coincidencias++;
            }
          }

          return coincidencias >= 2;
        }).toList();

        return FutureBuilder<String>(
          future: tipoCuentaFuture,
          builder: (context, tipoSnapshot) {
            final tipoCuenta = tipoSnapshot.data ?? 'hogar';

            return Scaffold(
              backgroundColor: beigeFondo,

              appBar: AppBar(
                backgroundColor: verdePrincipal,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  'ESSENTIALS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bluetooth),
                    tooltip: 'Conectar ESP32',
                    onPressed: abrirBluetooth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    tooltip: 'Mi perfil',
                    onPressed: abrirPerfil,
                  ),
                ],
              ),

              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BIENVENIDA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: verdePrincipal,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '¡Bienvenido a ESSENTIALS!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  tipoCuenta == 'colegio'
                                      ? 'Organiza tus refrigerios y controla tus existencias.'
                                      : tipoCuenta == 'empresa'
                                          ? 'Administra tus productos de forma sencilla.'
                                          : 'Cuida tus alimentos y aprovecha cada producto.',
                                  style: const TextStyle(
                                    color: beigeFondo,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.eco_rounded,
                            color: beigeFondo,
                            size: 55,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // INVENTARIO: ÚNICO CATÁLOGO REAL
                    const Text(
                      'Mi inventario',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: verdePrincipal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Consulta y administra los alimentos que tienes registrados.',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: abrirAgregarAlimento,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Registrar alimento',
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verdePrincipal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ALIMENTOS REGISTRADOS
                    if (foods.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: blancoTarjeta,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: verdeSecundario,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tu inventario está vacío',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: verdePrincipal,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Registra tu primer alimento para comenzar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          final food = foods[index];

                          return FoodCard(
                            food: food,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditFoodScreen(
                                    food: food,
                                  ),
                                ),
                              );
                            },
                            onDelete: () => eliminarAlimento(food),
                          );
                        },
                      ),

                    const SizedBox(height: 30),

                    // ESTADÍSTICAS INTERACTIVAS
                    const Text(
                      'Resumen de inventario',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: verdePrincipal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pulsa una tarjeta para consultar los productos.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _tarjetaEstadisticaInicio(
                            titulo: 'Alimentos',
                            cantidad: totalFoods,
                            icono: Icons.inventory_2_outlined,
                            color: verdeSecundario,
                            onTap: () => abrirEstadisticas('Todos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _tarjetaEstadisticaInicio(
                            titulo: 'Por vencer',
                            cantidad: expiringFoods,
                            icono: Icons.warning_amber_rounded,
                            color: Colors.orange.shade800,
                            onTap: () => abrirEstadisticas('Por vencer'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _tarjetaEstadisticaInicio(
                            titulo: 'Vencidos',
                            cantidad: expiredFoods,
                            icono: Icons.cancel_outlined,
                            color: Colors.red.shade700,
                            onTap: () => abrirEstadisticas('Vencidos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _tarjetaEstadisticaInicio(
                            titulo: 'Recetas',
                            cantidad: recetasDisponibles.length,
                            icono: Icons.restaurant_menu,
                            color: Colors.blueGrey,
                            onTap: () {
                              if (recetasDisponibles.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Agrega alimentos para descubrir recetas.',
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailScreen(
                                      recipe: recetasDisponibles.first,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // RECETAS RECOMENDADAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Recetas recomendadas',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: verdePrincipal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => abrirEstadisticas(),
                          child: const Text(
                            'Estadísticas',
                            style: TextStyle(color: verdePrincipal),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 340,
                      child: recetasDisponibles.isEmpty
                          ? const Center(
                              child: Text(
                                'Agrega alimentos para descubrir recetas.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recetasDisponibles.length,
                              itemBuilder: (context, index) {
                                final recipe = recetasDisponibles[index];

                                return RecipeCard(
                                  imageUrl: recipe.image,
                                  title: recipe.title,
                                  time: recipe.time,
                                  difficulty: recipe.difficulty,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RecipeDetailScreen(
                                          recipe: recipe,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 28),

                    // CONSEJO PARA REDUCIR EL DESPERDICIO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: verdeSecundario.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: verdeSecundario,
                                size: 32,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Cuidemos los alimentos',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: verdePrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Controlar las fechas de vencimiento ayuda a reducir el desperdicio y a aprovechar mejor cada producto.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Tienes $expiredFoods alimentos vencidos y $expiringFoods próximos a vencer.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: verdePrincipal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // NAVEGACIÓN INFERIOR
              bottomNavigationBar: NavigationBar(
                backgroundColor: Colors.white,
                indicatorColor: beigeFondo,
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  if (index == 0) {
                    setState(() => currentIndex = 0);
                  } else {
                    setState(() => currentIndex = 1);
                    abrirEstadisticas();
                  }
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Estadísticas',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tarjetaEstadisticaInicio({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withAlpha(45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$cantidad',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ver detalles',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
