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

  // ============================================================
  // COLORES DE ESSENTIALS
  // ============================================================

  static const Color verdeOscuro = Color.fromARGB(255, 18, 56, 29);
  static const Color verde = Color.fromARGB(255, 46, 125, 50);
  static const Color beige = Color.fromARGB(255, 243, 232, 169);

  // ============================================================
  // IMAGEN SEGÚN CATEGORÍA
  // ============================================================

  String get imageUrl {
    switch (food.categoria.toLowerCase()) {
      case "frutas":
        return "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400";

      case "verduras":
        return "https://images.unsplash.com/photo-1542838132-92c53300491e?w=400";

      case "carnes":
        return "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400";

      case "lácteos":
      case "lacteos":
        return "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400";

      case "bebidas":
        return "https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400";

      default:
        return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
    }
  }

  // ============================================================
  // COLOR DEL ESTADO
  // ============================================================

  Color get statusColor {
    if (food.diasRestantes < 0) {
      return Colors.red.shade700;
    }

    if (food.diasRestantes <= 2) {
      return Colors.red.shade600;
    }

    if (food.diasRestantes <= 5) {
      return Colors.orange.shade700;
    }

    return verde;
  }

  // ============================================================
  // TEXTO DEL ESTADO
  // ============================================================

  String get statusText {
    if (food.diasRestantes < 0) {
      return "Vencido";
    }

    if (food.diasRestantes == 0) {
      return "Vence hoy";
    }

    if (food.diasRestantes == 1) {
      return "Vence mañana";
    }

    return "Vence en ${food.diasRestantes} días";
  }

  // ============================================================
  // PROGRESO
  // ============================================================

  double get progress {
    if (food.diasRestantes < 0) {
      return 0.05;
    }

    if (food.diasRestantes <= 2) {
      return 0.20;
    }

    if (food.diasRestantes <= 5) {
      return 0.50;
    }

    return 0.90;
  }

  // ============================================================
  // ICONO DE CATEGORÍA
  // ============================================================

  IconData get categoryIcon {
    switch (food.categoria.toLowerCase()) {
      case "frutas":
        return Icons.apple;

      case "verduras":
        return Icons.eco;

      case "carnes":
        return Icons.restaurant;

      case "lácteos":
      case "lacteos":
        return Icons.local_drink;

      case "bebidas":
        return Icons.local_cafe;

      default:
        return Icons.fastfood;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==================================================
            // IMAGEN
            // ==================================================

            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    imageUrl,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: beige.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: verdeOscuro,
                          size: 34,
                        ),
                      );
                    },
                  ),
                ),

                // Indicador de estado
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ==================================================
            // INFORMACIÓN
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // NOMBRE + MENÚ
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          food.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      SizedBox(
                        width: 34,
                        height: 34,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Color(0xFF6B7280),
                            size: 22,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          onSelected: (value) {
                            if (value == "editar") {
                              onEdit();
                            }

                            if (value == "eliminar") {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "editar",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: verdeOscuro,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Editar"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: "eliminar",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Eliminar"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // ============================================
                  // CATEGORÍA
                  // ============================================

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: beige.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcon,
                              size: 13,
                              color: verdeOscuro,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              food.categoria,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: verdeOscuro,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // CANTIDAD
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 15,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${food.cantidad}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ============================================
                  // ESTADO
                  // ============================================

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "${food.fechaVencimiento.day.toString().padLeft(2, '0')}/"
                        "${food.fechaVencimiento.month.toString().padLeft(2, '0')}/"
                        "${food.fechaVencimiento.year}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  // ============================================
                  // BARRA DE PROGRESO
                  // ============================================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFEDEDED),
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}