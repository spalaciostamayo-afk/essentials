
import 'package:flutter/material.dart';

import '../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FoodCard({
    super.key,
    required this.food,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color verdePrincipal = Color(0xFF12381D);
  static const Color verdeSecundario = Color(0xFF3F7048);
  static const Color beigeFondo = Color(0xFFF3EED8);
  static const Color blanco = Colors.white;

  // ============================================================
  // IMAGEN GUARDADA EN FIREBASE
  // ============================================================

  String? get imagenPersonalizada {
    final url = food.imagenUrl?.trim();

    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return url;
  }

  // ============================================================
  // NORMALIZAR TEXTO
  // ============================================================

  String normalizar(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // IMÁGENES DE RESPALDO POR PRODUCTO
  // ============================================================

  String get imagenRespaldo {
    final nombre = normalizar(food.nombre);
    final categoria = normalizar(food.categoria);

    // Manzana y otras frutas.
    if (nombre.contains('manzana')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/3/3c/Manzana_Roja_Colombiana.jpg';
    }

    if (nombre.contains('pera') ||
        nombre.contains('banano') ||
        nombre.contains('banana') ||
        nombre.contains('uva') ||
        nombre.contains('naranja')) {
      return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400';
    }

    // Ducales Noel.
    if (nombre.contains('ducales')) {
      return 'https://d1tiendas.vtexassets.com/arquivos/ids/198966-150-150?aspect=true&height=150&v=639179630518830000&width=150';
    }

    // Saltín Noel.
    if (nombre.contains('saltin')) {
      return 'https://exitocol.vtexassets.com/arquivos/ids/34385378/Galleta-Tradicional-Pqt-X-9-Pqts-Personales-839016_a.jpg?v=639211341607330000';
    }

    // Campi para untar.
    if (nombre.contains('campi')) {
      return 'https://exitocol.vtexassets.com/arquivos/ids/34464969/Mantequilla-Esparcible-Con-Sal-X-500-gr-102611_a.jpg?v=639213811047100000';
    }

    // Otros alimentos.
    if (categoria.contains('fruta')) {
      return 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400';
    }

    if (categoria.contains('verdura')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400';
    }

    if (categoria.contains('carne')) {
      return 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400';
    }

    if (categoria.contains('bebida')) {
      return 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400';
    }

    if (categoria.contains('grano') ||
        categoria.contains('cereal')) {
      return 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400';
    }

    if (categoria.contains('snack') ||
        categoria.contains('galleta')) {
      return 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400';
    }

    if (categoria.contains('lacteo') ||
        nombre.contains('mantequilla') ||
        nombre.contains('margarina')) {
      return 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400';
    }

    return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';
  }

  // ============================================================
  // ESTADO DE VENCIMIENTO
  // ============================================================

  Color get colorEstado {
    if (food.diasRestantes < 0) {
      return Colors.red.shade700;
    }

    if (food.diasRestantes <= 3) {
      return Colors.orange.shade800;
    }

    if (food.diasRestantes <= 7) {
      return Colors.amber.shade800;
    }

    return verdeSecundario;
  }

  String get textoEstado {
    if (food.diasRestantes < 0) {
      return 'Vencido';
    }

    if (food.diasRestantes == 0) {
      return 'Vence hoy';
    }

    if (food.diasRestantes == 1) {
      return 'Vence mañana';
    }

    return 'Vence en ${food.diasRestantes} días';
  }

  double get progresoVencimiento {
    if (food.diasRestantes < 0) return 1.0;
    if (food.diasRestantes <= 3) return 0.85;
    if (food.diasRestantes <= 7) return 0.60;
    if (food.diasRestantes <= 14) return 0.35;
    return 0.15;
  }

  // ============================================================
  // ICONO DE CATEGORÍA
  // ============================================================

  IconData get iconoCategoria {
    final categoria = normalizar(food.categoria);

    if (categoria.contains('fruta')) {
      return Icons.apple;
    }

    if (categoria.contains('verdura')) {
      return Icons.eco;
    }

    if (categoria.contains('lacteo')) {
      return Icons.egg_alt_outlined;
    }

    if (categoria.contains('carne')) {
      return Icons.set_meal;
    }

    if (categoria.contains('bebida')) {
      return Icons.local_drink_outlined;
    }

    if (categoria.contains('grano') ||
        categoria.contains('cereal')) {
      return Icons.grain;
    }

    if (categoria.contains('snack') ||
        categoria.contains('galleta')) {
      return Icons.cookie_outlined;
    }

    return Icons.kitchen_outlined;
  }

  // ============================================================
  // FORMATO DE FECHA
  // ============================================================

  String get fechaFormateada {
    final fecha = food.fechaVencimiento;

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    return '$dia/$mes/$anio';
  }

  // ============================================================
  // MOSTRAR IMAGEN
  // ============================================================

  Widget construirImagen(String url, {bool esRespaldo = false}) {
    return Image.network(
      url,
      width: 88,
      height: 100,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          width: 88,
          height: 100,
          color: beigeFondo,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: verdePrincipal,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Solo intenta la imagen de respaldo una vez.
        if (!esRespaldo && url != imagenRespaldo) {
          return construirImagen(
            imagenRespaldo,
            esRespaldo: true,
          );
        }

        return Container(
          width: 88,
          height: 100,
          color: beigeFondo,
          alignment: Alignment.center,
          child: Icon(
            iconoCategoria,
            color: verdePrincipal,
            size: 38,
          ),
        );
      },
    );
  }

  // ============================================================
  // TARJETA DEL ALIMENTO
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final imagen = imagenPersonalizada ?? imagenRespaldo;

    return Card(
      color: blanco,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: verdePrincipal.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 88,
                height: 100,
                color: beigeFondo,
                alignment: Alignment.center,
                child: construirImagen(imagen),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: verdePrincipal,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        iconoCategoria,
                        size: 16,
                        color: verdeSecundario,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          food.categoria,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: verdeSecundario,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Cantidad: ${food.cantidad}',
                          style: const TextStyle(
                            color: verdePrincipal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: colorEstado,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          fechaFormateada,
                          style: TextStyle(
                            color: colorEstado,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progresoVencimiento,
                      minHeight: 5,
                      backgroundColor: beigeFondo,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorEstado,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    textoEstado,
                    style: TextStyle(
                      color: colorEstado,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opciones del alimento',
              icon: const Icon(
                Icons.more_vert,
                color: verdePrincipal,
              ),
              onSelected: (opcion) {
                if (opcion == 'editar') {
                  onEdit();
                } else if (opcion == 'eliminar') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: verdePrincipal,
                      ),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
