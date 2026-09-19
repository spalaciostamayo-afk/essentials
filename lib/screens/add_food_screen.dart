import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../services/food_service.dart';
import '../services/notification_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final nombreController = TextEditingController();
  final cantidadController = TextEditingController();

  String categoria = "Frutas";
  bool loading = false;

  DateTime? fechaSeleccionada;

  final categorias = [
    "Frutas",
    "Verduras",
    "Lácteos",
    "Carnes",
    "Bebidas",
    "Granos",
    "Snacks",
    "Otros",
  ];

  // ============================================================
  // SELECCIONAR FECHA
  // ============================================================

  Future<void> seleccionarFecha() async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ),
      lastDate: DateTime(2100),
      helpText: "Selecciona la fecha de vencimiento",
      cancelText: "Cancelar",
      confirmText: "Aceptar",
    );

    if (fecha == null) return;

    if (!mounted) return;

    setState(() {
      fechaSeleccionada = fecha;
    });
  }

  // ============================================================
  // GUARDAR ALIMENTO
  // ============================================================

  Future<void> guardar() async {
    // Validar nombre
    if (nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa el nombre del alimento",
          ),
        ),
      );
      return;
    }

    // Validar cantidad
    if (cantidadController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa la cantidad",
          ),
        ),
      );
      return;
    }

    final cantidad = int.tryParse(
      cantidadController.text.trim(),
    );

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ingresa una cantidad válida",
          ),
        ),
      );
      return;
    }

    // Validar fecha
    if (fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona la fecha de vencimiento",
          ),
        ),
      );
      return;
    }

    // Validar usuario
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Debes iniciar sesión para agregar alimentos",
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ========================================================
      // CREAR ID ÚNICO PARA EL ALIMENTO
      // ========================================================

      final idAlimento =
          DateTime.now().microsecondsSinceEpoch.toString();

      // ========================================================
      // CREAR MODELO
      // ========================================================

      final food = FoodModel(
        id: idAlimento,
        nombre: nombreController.text.trim(),
        categoria: categoria,
        cantidad: cantidad,
        fechaVencimiento: fechaSeleccionada!,
        usuarioId: usuario.uid,
      );

      // ========================================================
      // GUARDAR EN FIREBASE
      // ========================================================

      await FoodService.addFood(food);

      // ========================================================
      // PROGRAMAR NOTIFICACIÓN
      // ========================================================

      final notificationId = food.id.hashCode.abs();

      await NotificationService.programarAlerta(
        id: notificationId,
        nombreAlimento: food.nombre,
        fechaVencimiento: food.fechaVencimiento,
      );

      if (!mounted) return;

      // ========================================================
      // MENSAJE DE ÉXITO
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Alimento agregado correctamente",
          ),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      // Regresar al Home
      Navigator.pop(context, food);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No se pudo guardar el alimento: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < 700;

    const beige = Color.fromARGB(
      255,
      243,
      232,
      169,
    );

    const verdeOscuro = Color(0xFF12381D);

    const verde = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: beige,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: beige,
        foregroundColor: verdeOscuro,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Agregar alimento",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: isMobile ? double.infinity : 520,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 25,
                  offset: const Offset(
                    0,
                    10,
                  ),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // ENCABEZADO
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: verde.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: verde,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: verde.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 15,
                              offset: const Offset(
                                0,
                                6,
                              ),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_box_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Nuevo alimento",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Registra tus alimentos y controla "
                        "su fecha de vencimiento.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // NOMBRE
                // ==================================================

                TextField(
                  controller: nombreController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Nombre del alimento",
                    hintText: "Ej. Leche",
                    prefixIcon: const Icon(
                      Icons.fastfood_outlined,
                    ),
                    filled: true,
                    fillColor:
                        const Color(0xFFF9F9F7),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color: verde,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CATEGORÍA
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: InputDecoration(
                    labelText: "Categoría",
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                    ),
                    filled: true,
                    fillColor:
                        const Color(0xFFF9F9F7),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color: verde,
                        width: 2,
                      ),
                    ),
                  ),
                  items: categorias.map(
                    (item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      categoria = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CANTIDAD
                // ==================================================

                TextField(
                  controller: cantidadController,
                  keyboardType:
                      TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    hintText: "Ej. 2",
                    prefixIcon: const Icon(
                      Icons.numbers_outlined,
                    ),
                    filled: true,
                    fillColor:
                        const Color(0xFFF9F9F7),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color: verde,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // FECHA DE VENCIMIENTO
                // ==================================================

                InkWell(
                  onTap: loading
                      ? null
                      : seleccionarFecha,
                  borderRadius:
                      BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText:
                          "Fecha de vencimiento",
                      prefixIcon: const Icon(
                        Icons.calendar_month_outlined,
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text(
                      fechaSeleccionada == null
                          ? "Seleccionar fecha"
                          : "${fechaSeleccionada!.day.toString().padLeft(2, '0')}/"
                              "${fechaSeleccionada!.month.toString().padLeft(2, '0')}/"
                              "${fechaSeleccionada!.year}",
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            fechaSeleccionada == null
                                ? Colors.grey.shade600
                                : const Color(
                                    0xFF1F2937,
                                  ),
                        fontWeight:
                            fechaSeleccionada == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // INFORMACIÓN DE LA ALERTA
                // ==================================================

                Container(
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFF8E1,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(
                        0xFFFFE082,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFFFFA000),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Te avisaremos 5 días antes "
                          "de que el alimento venza.",
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.grey.shade800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // BOTÓN GUARDAR
                // ==================================================

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        loading ? null : guardar,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          verdeOscuro,
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          Colors.grey.shade400,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      elevation: 3,
                    ),
                    icon: loading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.save_outlined,
                          ),
                    label: Text(
                      loading
                          ? "Guardando..."
                          : "Guardar alimento",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TEXTO INFORMATIVO
                // ==================================================

                const Text(
                  "Los alimentos se guardarán en tu cuenta "
                  "de ESSENTIALS.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}