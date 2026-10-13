
import 'dart:async';

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
  final codigoBarrasController = TextEditingController();
  final imagenUrlController = TextEditingController();

  Timer? _temporizadorBusqueda;

  String categoria = 'Frutas';
  bool loading = false;
  bool buscandoImagen = false;
  bool imagenEncontradaAutomaticamente = false;
  DateTime? fechaSeleccionada;
  String mensajeImagen = '';

  static const Color beige = Color(0xFFF3E8A9);
  static const Color verdeOscuro = Color(0xFF12381D);
  static const Color verde = Color(0xFF2E7D32);

  final List<String> categorias = [
    'Frutas',
    'Verduras',
    'Lácteos',
    'Carnes',
    'Bebidas',
    'Granos',
    'Snacks',
    'Otros',
  ];

  InputDecoration decoracionCampo({
    required String etiqueta,
    required IconData icono,
    String? ayuda,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: const Color(0xFFF9F9F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: verde,
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // BÚSQUEDA AUTOMÁTICA DE IMAGEN EN FIREBASE
  // ============================================================

  void programarBusquedaImagen(String texto) {
    _temporizadorBusqueda?.cancel();

    final nombre = texto.trim();

    if (nombre.length < 4) {
      if (mounted) {
        setState(() {
          buscandoImagen = false;
          mensajeImagen = '';
        });
      }
      return;
    }

    // Si el usuario escribió una URL manualmente, la respetamos.
    if (imagenUrlController.text.trim().isNotEmpty &&
        !imagenEncontradaAutomaticamente) {
      return;
    }

    setState(() {
      buscandoImagen = true;
      mensajeImagen = 'Buscando imagen en el catálogo...';
    });

    // Esperamos a que termine de escribir para evitar consultas
    // innecesarias a Firebase por cada letra.
    _temporizadorBusqueda = Timer(
      const Duration(milliseconds: 800),
      () => buscarImagenEnCatalogo(nombre),
    );
  }

  Future<void> buscarImagenEnCatalogo(String nombreBuscado) async {
    try {
      final producto =
          await FoodService.buscarProductoPorNombre(nombreBuscado);

      if (!mounted) return;

      // Ignoramos resultados de búsquedas anteriores.
      if (FoodService.normalizarNombreProducto(
            nombreController.text,
          ) !=
          FoodService.normalizarNombreProducto(nombreBuscado)) {
        return;
      }

      if (producto == null) {
        setState(() {
          buscandoImagen = false;
          mensajeImagen =
              'No encontramos este producto en el catálogo. '
              'Puedes continuar sin imagen o ingresar una URL.';
        });
        return;
      }

      final imagen = producto['imagenUrl']?.toString().trim() ?? '';
      final nombreCatalogo = producto['nombre']?.toString().trim() ?? '';

      if (imagen.isEmpty) {
        setState(() {
          buscandoImagen = false;
          mensajeImagen =
              'Encontramos el producto, pero todavía no tiene '
              'una imagen guardada en el catálogo.';
        });
        return;
      }

      final uri = Uri.tryParse(imagen);

      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        setState(() {
          buscandoImagen = false;
          mensajeImagen =
              'El producto tiene una URL de imagen inválida.';
        });
        return;
      }

      final categoriaCatalogo =
          producto['categoria']?.toString() ?? '';

      setState(() {
        imagenUrlController.text = imagen;
        imagenEncontradaAutomaticamente = true;
        buscandoImagen = false;
        mensajeImagen = nombreCatalogo.isEmpty
            ? 'Imagen encontrada en el catálogo.'
            : 'Imagen encontrada para $nombreCatalogo.';

        final categoriaCoincidente = categorias.where(
          (item) =>
              FoodService.normalizarNombreProducto(item) ==
              FoodService.normalizarNombreProducto(
                categoriaCatalogo,
              ),
        );

        if (categoriaCoincidente.isNotEmpty) {
          categoria = categoriaCoincidente.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        buscandoImagen = false;
        mensajeImagen =
            'No se pudo consultar el catálogo. '
            'Puedes continuar ingresando la imagen manualmente.';
      });
    }
  }

  void cambiarImagenManual(String valor) {
    if (valor.trim().isEmpty) {
      imagenEncontradaAutomaticamente = false;

      // Si se borra la URL, volvemos a buscar por nombre.
      programarBusquedaImagen(nombreController.text);
      return;
    }

    setState(() {
      imagenEncontradaAutomaticamente = false;
      mensajeImagen = 'Usando la URL de imagen que ingresaste.';
    });
  }

  // ============================================================
  // VISTA PREVIA DE LA IMAGEN
  // ============================================================

  Widget construirVistaPrevia() {
    final url = imagenUrlController.text.trim();

    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: verde.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: verde.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 82,
              height: 82,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 82,
                  height: 82,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Vista previa del alimento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: verdeOscuro,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Quitar imagen',
            onPressed: loading
                ? null
                : () {
                    setState(() {
                      imagenUrlController.clear();
                      imagenEncontradaAutomaticamente = false;
                      mensajeImagen = '';
                    });
                    programarBusquedaImagen(nombreController.text);
                  },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALIDAR URL DE IMAGEN
  // ============================================================

  bool urlImagenValida(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) return true;

    final uri = Uri.tryParse(texto);

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  // ============================================================
  // SELECCIONAR FECHA DE VENCIMIENTO
  // ============================================================

  Future<void> seleccionarFecha() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha de vencimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha == null || !mounted) return;

    setState(() {
      fechaSeleccionada = fecha;
    });
  }

  // ============================================================
  // GUARDAR ALIMENTO
  // ============================================================

  Future<void> guardar() async {
    final nombre = nombreController.text.trim();
    final cantidadTexto = cantidadController.text.trim();
    final codigo = codigoBarrasController.text.trim();
    final imagen = imagenUrlController.text.trim();

    if (nombre.isEmpty) {
      mostrarMensaje('Ingresa el nombre del alimento');
      return;
    }

    final cantidad = int.tryParse(cantidadTexto);

    if (cantidad == null || cantidad <= 0) {
      mostrarMensaje('Ingresa una cantidad válida');
      return;
    }

    if (fechaSeleccionada == null) {
      mostrarMensaje('Selecciona la fecha de vencimiento');
      return;
    }

    if (!urlImagenValida(imagen)) {
      mostrarMensaje(
        'La imagen debe tener una URL válida que comience con https:// o http://',
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      mostrarMensaje('Debes iniciar sesión para agregar alimentos');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // Si el producto ya está en el catálogo y no se ha
      // introducido una imagen manual, intentamos recuperarla.
      String? imagenFinal = imagen.isEmpty ? null : imagen;

      if (imagenFinal == null) {
        final producto =
            await FoodService.buscarProductoPorNombre(nombre);

        final imagenCatalogo =
            producto?['imagenUrl']?.toString().trim();

        if (imagenCatalogo != null &&
            imagenCatalogo.isNotEmpty &&
            urlImagenValida(imagenCatalogo)) {
          imagenFinal = imagenCatalogo;
        }
      }

      final food = FoodModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: nombre,
        categoria: categoria,
        cantidad: cantidad,
        fechaVencimiento: fechaSeleccionada!,
        usuarioId: usuario.uid,
        codigoBarras: codigo.isEmpty ? null : codigo,
        imagenUrl: imagenFinal,
      );

      await FoodService.addFood(food);

      // Si se proporcionó un código de barras, guardamos también
      // la información en el catálogo para futuras búsquedas.
      if (codigo.isNotEmpty) {
        await FoodService.guardarProductoEnCatalogo(
          codigoBarras: codigo,
          nombre: nombre,
          categoria: categoria,
          imagenUrl: imagenFinal,
        );
      }

      await NotificationService.programarAlerta(
        id: food.id.hashCode.abs(),
        nombreAlimento: food.nombre,
        fechaVencimiento: food.fechaVencimiento,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alimento agregado correctamente'),
          backgroundColor: verde,
        ),
      );

      Navigator.pop(context, food);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar el registro: $e'),
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

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _temporizadorBusqueda?.cancel();
    nombreController.dispose();
    cantidadController.dispose();
    codigoBarrasController.dispose();
    imagenUrlController.dispose();
    super.dispose();
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        foregroundColor: verdeOscuro,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Agregar alimento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: verde.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
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
                              color: verde.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
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
                        'Nuevo alimento',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registra tus alimentos y controla su fecha de vencimiento.',
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

                TextField(
                  controller: nombreController,
                  enabled: !loading,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: programarBusquedaImagen,
                  onSubmitted: (texto) {
                    _temporizadorBusqueda?.cancel();
                    buscarImagenEnCatalogo(texto.trim());
                  },
                  decoration: decoracionCampo(
                    etiqueta: 'Nombre del alimento',
                    ayuda: 'Ej. Ducales Noel o Mantequilla Campi',
                    icono: Icons.fastfood_outlined,
                  ),
                ),

                if (buscandoImagen) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(
                    color: verde,
                    minHeight: 3,
                  ),
                ],

                if (mensajeImagen.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    mensajeImagen,
                    style: TextStyle(
                      fontSize: 12,
                      color: imagenEncontradaAutomaticamente
                          ? verde
                          : Colors.grey.shade700,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: decoracionCampo(
                    etiqueta: 'Categoría',
                    icono: Icons.category_outlined,
                  ),
                  items: categorias.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: loading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            categoria = value;
                          });
                        },
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: cantidadController,
                  enabled: !loading,
                  keyboardType: TextInputType.number,
                  decoration: decoracionCampo(
                    etiqueta: 'Cantidad',
                    ayuda: 'Ej. 2',
                    icono: Icons.numbers_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: codigoBarrasController,
                  enabled: !loading,
                  keyboardType: TextInputType.number,
                  decoration: decoracionCampo(
                    etiqueta: 'Código de barras (opcional)',
                    ayuda: 'Escribe el número del empaque',
                    icono: Icons.qr_code_scanner,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: imagenUrlController,
                  enabled: !loading,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onChanged: cambiarImagenManual,
                  decoration: decoracionCampo(
                    etiqueta: 'URL de imagen (opcional)',
                    ayuda: 'https://...',
                    icono: Icons.image_outlined,
                  ),
                ),

                construirVistaPrevia(),

                const SizedBox(height: 8),

                Text(
                  'La aplicación buscará imágenes que ya estén guardadas '
                  'en el catálogo. Si no encuentra ninguna, puedes agregar '
                  'una URL manualmente.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 18),

                InkWell(
                  onTap: loading ? null : seleccionarFecha,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: decoracionCampo(
                      etiqueta: 'Fecha de vencimiento',
                      icono: Icons.calendar_month_outlined,
                    ),
                    child: Text(
                      fechaSeleccionada == null
                          ? 'Seleccionar fecha'
                          : '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/'
                              '${fechaSeleccionada!.month.toString().padLeft(2, '0')}/'
                              '${fechaSeleccionada!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: fechaSeleccionada == null
                            ? Colors.grey.shade600
                            : const Color(0xFF1F2937),
                        fontWeight: fechaSeleccionada == null
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFE082),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFFFFA000),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Te avisaremos 5 días antes de que el alimento venza.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeOscuro,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 3,
                    ),
                    icon: loading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      loading ? 'Guardando...' : 'Guardar alimento',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Los alimentos se guardarán en tu cuenta de ESSENTIALS.',
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
