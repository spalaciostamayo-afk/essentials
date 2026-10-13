
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/notification_service.dart';

const Color _verdePrincipal = Color(0xFF12381D);
const Color _verdeSecundario = Color(0xFF3F7048);
const Color _beigeFondo = Color(0xFFF3EED8);

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
  late final TextEditingController _imagenController;

  late String _categoria;
  late DateTime _fechaVencimiento;

  bool _guardando = false;
  bool _eliminando = false;

  final List<String> _categorias = [
    'Frutas',
    'Verduras',
    'Carnes',
    'Lácteos',
    'Granos',
    'Bebidas',
    'Snacks',
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

    _imagenController = TextEditingController(
      text: widget.food.imagenUrl ?? '',
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
    _imagenController.dispose();
    super.dispose();
  }

  int get _notificationId => widget.food.id.hashCode.abs();

  String? get _imagenValida {
    final texto = _imagenController.text.trim();

    if (texto.isEmpty) return null;

    final uri = Uri.tryParse(texto);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return texto;
  }

  Future<void> _seleccionarFecha() async {
    if (_guardando || _eliminando) return;

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final fechaActual = DateTime(
      _fechaVencimiento.year,
      _fechaVencimiento.month,
      _fechaVencimiento.day,
    );

    final fechaInicial =
        fechaActual.isBefore(hoy) ? hoy : fechaActual;

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: hoy,
      lastDate: DateTime(2100),
      helpText: 'Fecha de vencimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (!mounted || fecha == null) return;

    setState(() {
      _fechaVencimiento = fecha;
    });
  }

  Future<void> _guardarCambios() async {
    if (_guardando || _eliminando) return;

    if (!_formKey.currentState!.validate()) return;

    final textoImagen = _imagenController.text.trim();

    if (textoImagen.isNotEmpty && _imagenValida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una URL de imagen válida.'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final cantidad = int.parse(
        _cantidadController.text.trim(),
      );

      final imagenUrl = _imagenValida;

      final foodActualizado = FoodModel(
        id: widget.food.id,
        nombre: _nombreController.text.trim(),
        categoria: _categoria,
        cantidad: cantidad,
        fechaVencimiento: _fechaVencimiento,
        usuarioId: widget.food.usuarioId,
        codigoBarras: widget.food.codigoBarras,
        imagenUrl: imagenUrl,
      );

      await FirebaseFirestore.instance
          .collection('alimentos')
          .doc(widget.food.id)
          .update(foodActualizado.toMap());

      try {
        await NotificationService.cancelarAlerta(
          _notificationId,
        );

        await NotificationService.programarAlerta(
          id: _notificationId,
          nombreAlimento: foodActualizado.nombre,
          fechaVencimiento: foodActualizado.fechaVencimiento,
        );
      } catch (e) {
        debugPrint('No se pudo actualizar la notificación: $e');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alimento actualizado correctamente'),
          backgroundColor: _verdeSecundario,
        ),
      );

      Navigator.pop(context, foodActualizado);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar el alimento: $e'),
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
    if (_guardando || _eliminando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alimento'),
          content: Text(
            '¿Seguro que quieres eliminar "${widget.food.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
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

    if (confirmar != true || !mounted) return;

    setState(() {
      _eliminando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('alimentos')
          .doc(widget.food.id)
          .delete();

      try {
        await NotificationService.cancelarAlerta(
          _notificationId,
        );
      } catch (e) {
        debugPrint('No se pudo cancelar la notificación: $e');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alimento eliminado'),
          backgroundColor: _verdeSecundario,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el alimento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _eliminando = false;
        });
      }
    }
  }

  Widget _construirVistaPreviaImagen() {
    final url = _imagenController.text.trim();

    if (url.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _beigeFondo,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 38,
              color: _verdePrincipal,
            ),
            SizedBox(height: 6),
            Text('Imagen opcional del producto'),
          ],
        ),
      );
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return const Text(
        'La URL debe comenzar con https:// o http://',
        style: TextStyle(color: Colors.red),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: double.infinity,
            color: _beigeFondo,
            alignment: Alignment.center,
            child: const Text(
              'No se pudo cargar la imagen.',
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = _guardando || _eliminando;

    return Scaffold(
      backgroundColor: _beigeFondo,
      appBar: AppBar(
        title: const Text('Editar alimento'),
        centerTitle: true,
        backgroundColor: _verdePrincipal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: bloqueado ? null : _eliminarAlimento,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 60,
                            color: _verdePrincipal,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Editar alimento',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _verdePrincipal,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Actualiza los datos de tu inventario.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nombreController,
                      enabled: !bloqueado,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del alimento',
                        prefixIcon: Icon(Icons.fastfood_outlined),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _categorias.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: bloqueado
                          ? null
                          : (value) {
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
                      enabled: !bloqueado,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la cantidad';
                        }

                        final cantidad = int.tryParse(value.trim());

                        if (cantidad == null || cantidad <= 0) {
                          return 'Ingresa una cantidad válida';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: widget.food.codigoBarras ?? '',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Código de barras',
                        prefixIcon: Icon(Icons.qr_code_scanner),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _imagenController,
                      enabled: !bloqueado,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen (opcional)',
                        hintText: 'https://...',
                        prefixIcon: Icon(Icons.image_outlined),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _construirVistaPreviaImagen(),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: bloqueado ? null : _seleccionarFecha,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de vencimiento',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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
                        onPressed: bloqueado ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verdePrincipal,
                          foregroundColor: Colors.white,
                        ),
                        icon: bloqueado
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando
                              ? 'Guardando...'
                              : _eliminando
                                  ? 'Eliminando...'
                                  : 'Guardar cambios',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: bloqueado ? null : _eliminarAlimento,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Eliminar alimento',
                        style: TextStyle(color: Colors.red),
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
