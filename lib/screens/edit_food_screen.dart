import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/notification_service.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodModel food;

  const EditFoodScreen({
    super.key,
    required this.food,
  });

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _cantidadController;

  late String _categoria;
  late DateTime _fechaVencimiento;

  bool _guardando = false;

  final List<String> _categorias = [
    'Frutas',
    'Verduras',
    'Carnes',
    'Lácteos',
    'Granos',
    'Bebidas',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(
      text: widget.food.nombre,
    );

    _cantidadController = TextEditingController(
      text: widget.food.cantidad.toString(),
    );

    _categoria = widget.food.categoria.isEmpty
        ? 'Otros'
        : widget.food.categoria;

    if (!_categorias.contains(_categoria)) {
      _categoria = 'Otros';
    }

    _fechaVencimiento = widget.food.fechaVencimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  int get _notificationId {
    return widget.food.id.hashCode.abs();
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fechaInicial = _fechaVencimiento.isBefore(ahora)
        ? ahora
        : _fechaVencimiento;

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: ahora,
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        _fechaVencimiento = fecha;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final cantidad = int.parse(
        _cantidadController.text.trim(),
      );

      final foodActualizado = FoodModel(
        id: widget.food.id,
        nombre: _nombreController.text.trim(),
        categoria: _categoria,
        cantidad: cantidad,
        fechaVencimiento: _fechaVencimiento,
        usuarioId: widget.food.usuarioId,
      );

      await FirebaseFirestore.instance
          .collection('alimentos')
          .doc(widget.food.id)
          .update(foodActualizado.toMap());

      // Cancelar la alerta anterior.
      await NotificationService.cancelarAlerta(
        _notificationId,
      );

      // Programar nuevamente la alerta.
      await NotificationService.programarAlerta(
        id: _notificationId,
        nombreAlimento: foodActualizado.nombre,
        fechaVencimiento: foodActualizado.fechaVencimiento,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alimento actualizado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, foodActualizado);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar el alimento: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _eliminarAlimento() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar alimento'),
          content: Text(
            '¿Seguro que quieres eliminar '
            '"${widget.food.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('alimentos')
          .doc(widget.food.id)
          .delete();

      await NotificationService.cancelarAlerta(
        _notificationId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alimento eliminado'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo eliminar el alimento: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar alimento'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: _guardando
                ? null
                : _eliminarAlimento,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(24),
                        color: primaryColor.withValues(
                          alpha: 0.08,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 60,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Editar alimento',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Actualiza la información '
                            'de tu alimento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nombreController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del alimento',
                        prefixIcon:
                            Icon(Icons.fastfood_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa el nombre del alimento';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon:
                            Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _categorias.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _categoria = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa la cantidad';
                        }

                        final cantidad =
                            int.tryParse(value.trim());

                        if (cantidad == null ||
                            cantidad <= 0) {
                          return 'Ingresa una cantidad válida';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _seleccionarFecha,
                      borderRadius:
                          BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Fecha de vencimiento',
                          prefixIcon: Icon(
                            Icons.calendar_month_outlined,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_fechaVencimiento.day.toString().padLeft(2, '0')}/'
                          '${_fechaVencimiento.month.toString().padLeft(2, '0')}/'
                          '${_fechaVencimiento.year}',
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _guardando
                            ? null
                            : _guardarCambios,
                        icon: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                              ),
                        label: Text(
                          _guardando
                              ? 'Guardando...'
                              : 'Guardar cambios',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: _guardando
                          ? null
                          : _eliminarAlimento,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Eliminar alimento',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}