
import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/food_service.dart';

const Color verdePrincipal = Color(0xFF12381D);
const Color verdeSecundario = Color(0xFF3F7048);
const Color beigeFondo = Color(0xFFF3EED8);

class StatisticsScreen extends StatefulWidget {
  final String initialFilter;

  const StatisticsScreen({
    super.key,
    this.initialFilter = 'Todos',
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late String filtroSeleccionado;

  @override
  void initState() {
    super.initState();

    filtroSeleccionado = _normalizarFiltro(widget.initialFilter);
  }

  String _normalizarFiltro(String filtro) {
    switch (filtro) {
      case 'Por vencer':
        return 'Por vencer';
      case 'Vencidos':
        return 'Vencidos';
      default:
        return 'Todos';
    }
  }

  List<FoodModel> _filtrarAlimentos(List<FoodModel> alimentos) {
    switch (filtroSeleccionado) {
      case 'Por vencer':
        return alimentos.where((food) {
          return food.diasRestantes >= 0 &&
              food.diasRestantes <= 3;
        }).toList();

      case 'Vencidos':
        return alimentos.where((food) {
          return food.diasRestantes < 0;
        }).toList();

      default:
        return alimentos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeFondo,
      appBar: AppBar(
        backgroundColor: verdePrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<FoodModel>>(
        stream: FoodService.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
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
                      'No se pudieron cargar las estadísticas.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: verdePrincipal,
              ),
            );
          }

          final alimentos = snapshot.data ?? <FoodModel>[];

          final total = alimentos.length;

          final porVencer = alimentos.where((food) {
            return food.diasRestantes >= 0 &&
                food.diasRestantes <= 3;
          }).length;

          final vencidos = alimentos.where((food) {
            return food.diasRestantes < 0;
          }).length;

          final frutas = alimentos.where((food) {
            return food.categoria.toLowerCase() == 'frutas';
          }).length;

          final verduras = alimentos.where((food) {
            return food.categoria.toLowerCase() == 'verduras';
          }).length;

          final lacteos = alimentos.where((food) {
            final categoria = food.categoria.toLowerCase();
            return categoria == 'lácteos' ||
                categoria == 'lacteos';
          }).length;

          final carnes = alimentos.where((food) {
            return food.categoria.toLowerCase() == 'carnes';
          }).length;

          final seleccionados = _filtrarAlimentos(alimentos);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Resumen de tu inventario',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: verdePrincipal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona una tarjeta para consultar los alimentos.',
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              _tarjetaEstadistica(
                titulo: 'Total de alimentos',
                cantidad: total,
                icono: Icons.inventory_2_outlined,
                color: verdeSecundario,
                filtro: 'Todos',
              ),
              const SizedBox(height: 12),

              _tarjetaEstadistica(
                titulo: 'Por vencer',
                cantidad: porVencer,
                icono: Icons.warning_amber_rounded,
                color: Colors.orange.shade800,
                filtro: 'Por vencer',
              ),
              const SizedBox(height: 12),

              _tarjetaEstadistica(
                titulo: 'Vencidos',
                cantidad: vencidos,
                icono: Icons.error_outline,
                color: Colors.red.shade700,
                filtro: 'Vencidos',
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filtroSeleccionado == 'Todos'
                          ? 'Todos tus alimentos'
                          : filtroSeleccionado,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: verdePrincipal,
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (seleccionados.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 44,
                                color: verdeSecundario,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No hay alimentos para mostrar.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...seleccionados.map(_elementoAlimento),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Alimentos por categoría',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: verdePrincipal,
                ),
              ),
              const SizedBox(height: 12),

              _categoria('🍎 Frutas', frutas),
              _categoria('🥦 Verduras', verduras),
              _categoria('🥛 Lácteos', lacteos),
              _categoria('🥩 Carnes', carnes),
            ],
          );
        },
      ),
    );
  }

  Widget _tarjetaEstadistica({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
    required String filtro,
  }) {
    final seleccionada = filtroSeleccionado == filtro;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            filtroSeleccionado = filtro;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: seleccionada ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color.withAlpha(30),
                child: Icon(
                  icono,
                  color: color,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cantidad',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                seleccionada
                    ? Icons.check_circle
                    : Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _elementoAlimento(FoodModel alimento) {
    final dias = alimento.diasRestantes;

    late final Color colorEstado;
    late final String textoEstado;

    if (dias < 0) {
      colorEstado = Colors.red.shade700;
      textoEstado = 'Vencido';
    } else if (dias == 0) {
      colorEstado = Colors.orange.shade800;
      textoEstado = 'Vence hoy';
    } else if (dias <= 3) {
      colorEstado = Colors.orange.shade800;
      textoEstado = 'Vence en $dias día(s)';
    } else {
      colorEstado = verdeSecundario;
      textoEstado = 'En buen estado';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorEstado.withAlpha(28),
            child: Icon(
              Icons.fastfood_outlined,
              color: colorEstado,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alimento.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: verdePrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alimento.categoria} · Cantidad: ${alimento.cantidad}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  textoEstado,
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoria(String nombre, int cantidad) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(nombre),
        trailing: Text(
          '$cantidad',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: verdePrincipal,
          ),
        ),
      ),
    );
  }
}
