
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import 'app_navigation.dart';
import 'bluetooth_service.dart';
import 'food_service.dart';
import 'notification_service.dart';

const Color _verdePrincipal = Color(0xFF12381D);
const Color _beigeFondo = Color(0xFFF3EED8);

const List<String> _categoriasProducto = [
  'Frutas',
  'Verduras',
  'Lácteos',
  'Carnes',
  'Bebidas',
  'Granos',
  'Snacks',
  'Otros',
];

class BluetoothCodeHandler extends StatefulWidget {
  const BluetoothCodeHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<BluetoothCodeHandler> createState() =>
      _BluetoothCodeHandlerState();
}

class _BluetoothCodeHandlerState extends State<BluetoothCodeHandler> {
  final BluetoothService _bluetooth = BluetoothService.instance;

  StreamSubscription<void>? _suscripcion;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();

    _suscripcion = _bluetooth.cambios.listen((_) {
      unawaited(_procesarCola());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_procesarCola());
    });
  }

  Future<void> _procesarCola() async {
    if (_procesando || !mounted) return;

    _procesando = true;

    try {
      while (mounted && _bluetooth.hayCodigosPendientes) {
        final codigo = _bluetooth.primerCodigoPendiente;

        if (codigo == null) break;

        final atendido = await _atenderCodigo(codigo);

        if (!mounted || !atendido) break;

        _bluetooth.marcarCodigoProcesado(codigo);
      }
    } finally {
      _procesando = false;

      if (mounted && _bluetooth.hayCodigosPendientes) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(_procesarCola());
          }
        });
      }
    }
  }

  Future<bool> _atenderCodigo(String codigo) async {
    try {
      final producto =
          await FoodService.buscarProductoPorCodigo(codigo);

      if (!mounted) return false;

      final contexto = essentialsNavigatorKey.currentContext;

      if (contexto == null || !contexto.mounted) {
        return false;
      }

      final datos = await showDialog<Map<String, dynamic>>(
        context: contexto,
        barrierDismissible: false,
        builder: (_) => _FormularioEscaneo(
          codigo: codigo,
          productoExistente: producto,
        ),
      );

      if (!mounted) return false;

      // Si se cancela el formulario, no se guarda nada.
      if (datos == null) return true;

      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _mostrarMensaje(
          'Debes iniciar sesión para guardar alimentos.',
        );
        return true;
      }

      final nombre = datos['nombre'] as String;
      final categoria = datos['categoria'] as String;
      final cantidad = datos['cantidad'] as int;
      final fechaVencimiento =
          datos['fechaVencimiento'] as DateTime;

      final imagenUrl = _normalizarImagenUrl(
        datos['imagenUrl']?.toString(),
      );

      // Guarda nombre, categoría y, si existe, imagen en el catálogo.
      await FoodService.guardarProductoEnCatalogo(
        codigoBarras: codigo,
        nombre: nombre,
        categoria: categoria,
        imagenUrl: imagenUrl,
      );

      final food = FoodModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: nombre,
        categoria: categoria,
        cantidad: cantidad,
        fechaVencimiento: fechaVencimiento,
        usuarioId: usuario.uid,
        codigoBarras: codigo,
        imagenUrl: imagenUrl,
      );

      await FoodService.addFood(food);

      try {
        await NotificationService.programarAlerta(
          id: food.id.hashCode.abs(),
          nombreAlimento: food.nombre,
          fechaVencimiento: food.fechaVencimiento,
        );
      } catch (e) {
        debugPrint('Error programando notificación: $e');
      }

      _mostrarMensaje(
        '¡${food.nombre} se agregó al inventario!',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error procesando el código $codigo: $e');
      debugPrintStack(stackTrace: stackTrace);

      _mostrarMensaje('Error al consultar o guardar: $e');

      return true;
    }
  }

  String? _normalizarImagenUrl(String? valor) {
    final url = valor?.trim();

    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return url;
  }

  void _mostrarMensaje(String texto) {
    final contexto = essentialsNavigatorKey.currentContext;

    if (contexto == null || !contexto.mounted) return;

    ScaffoldMessenger.of(contexto)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(texto)),
      );
  }

  @override
  void dispose() {
    unawaited(_suscripcion?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FormularioEscaneo extends StatefulWidget {
  const _FormularioEscaneo({
    required this.codigo,
    required this.productoExistente,
  });

  final String codigo;
  final Map<String, dynamic>? productoExistente;

  @override
  State<_FormularioEscaneo> createState() =>
      _FormularioEscaneoState();
}

class _FormularioEscaneoState extends State<_FormularioEscaneo> {
  late final TextEditingController _nombreController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _imagenController;

  late String _categoria;

  DateTime? _fecha;
  bool _guardando = false;
  bool _abriendoCalendario = false;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(
      text: widget.productoExistente?['nombre']?.toString() ?? '',
    );

    _cantidadController = TextEditingController(text: '1');

    _imagenController = TextEditingController(
      text: widget.productoExistente?['imagenUrl']?.toString() ?? '',
    );

    final categoriaGuardada =
        widget.productoExistente?['categoria']?.toString() ?? 'Otros';

    _categoria = _categoriasProducto.contains(categoriaGuardada)
        ? categoriaGuardada
        : 'Otros';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    if (_guardando || _abriendoCalendario) return;

    setState(() {
      _abriendoCalendario = true;
    });

    try {
      final hoy = DateTime.now();

      final seleccionada = await showDatePicker(
        context: context,
        initialDate: _fecha ?? hoy,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: 'Fecha de vencimiento',
        cancelText: 'Cancelar',
        confirmText: 'Aceptar',
      );

      if (!mounted || seleccionada == null) return;

      setState(() {
        _fecha = seleccionada;
      });
    } catch (e) {
      debugPrint('Error abriendo el calendario: $e');

      if (mounted) {
        _mostrarError('No se pudo abrir el calendario.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _abriendoCalendario = false;
        });
      }
    }
  }

  void _guardar() {
    if (_guardando || _abriendoCalendario) return;

    final nombre = _nombreController.text.trim();
    final cantidad = int.tryParse(_cantidadController.text.trim());
    final imagenTexto = _imagenController.text.trim();

    if (nombre.isEmpty) {
      _mostrarError('Escribe el nombre del producto.');
      return;
    }

    if (cantidad == null || cantidad <= 0) {
      _mostrarError('Ingresa una cantidad mayor que cero.');
      return;
    }

    if (_fecha == null) {
      _mostrarError('Selecciona la fecha de vencimiento.');
      return;
    }

    String? imagenUrl;

    if (imagenTexto.isNotEmpty) {
      final uri = Uri.tryParse(imagenTexto);

      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        _mostrarError('Ingresa una URL de imagen válida.');
        return;
      }

      imagenUrl = imagenTexto;
    }

    setState(() {
      _guardando = true;
    });

    Navigator.of(context).pop<Map<String, dynamic>>({
      'nombre': nombre,
      'categoria': _categoria,
      'cantidad': cantidad,
      'fechaVencimiento': _fecha!,
      'imagenUrl': imagenUrl,
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fecha = _fecha;
    final imagenTexto = _imagenController.text.trim();

    return PopScope(
      canPop: !_guardando && !_abriendoCalendario,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          widget.productoExistente == null
              ? 'Registrar producto nuevo'
              : 'Producto encontrado',
          style: const TextStyle(
            color: _verdePrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Código de barras',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(widget.codigo),
              const SizedBox(height: 16),
              TextField(
                controller: _nombreController,
                enabled: !_guardando,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categoriasProducto.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: _guardando
                    ? null
                    : (valor) {
                        if (valor != null) {
                          setState(() {
                            _categoria = valor;
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cantidadController,
                enabled: !_guardando,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ej. 2',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imagenController,
                enabled: !_guardando,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.image_outlined),
                  border: OutlineInputBorder(),
                  helperText:
                      'Puedes pegar el enlace directo de una imagen.',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              if (imagenTexto.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imagenTexto,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return Container(
                        height: 70,
                        alignment: Alignment.center,
                        color: _beigeFondo,
                        child: const Text(
                          'No se pudo cargar la vista previa.',
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _guardando || _abriendoCalendario
                      ? null
                      : _seleccionarFecha,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _abriendoCalendario
                        ? 'Abriendo calendario...'
                        : fecha == null
                            ? 'Seleccionar vencimiento'
                            : 'Vence: '
                                '${fecha.day.toString().padLeft(2, '0')}/'
                                '${fecha.month.toString().padLeft(2, '0')}/'
                                '${fecha.year}',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'La fecha corresponde al alimento que estás '
                'agregando a tu inventario.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _guardando || _abriendoCalendario
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: _guardando || _abriendoCalendario
                ? null
                : _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: _verdePrincipal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
