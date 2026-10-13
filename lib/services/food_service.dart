
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';

class FoodService {
  FoodService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // ============================================================
  // CATÁLOGO DE RESPALDO DE IMÁGENES
  // ============================================================

  static const List<Map<String, String>> _productosConImagen = [
    {
      'nombre': 'Galletas Ducales Noel',
      'categoria': 'Snacks',
      'imagenUrl':
          'https://d1tiendas.vtexassets.com/arquivos/ids/198966-150-150?aspect=true&height=150&v=639179630518830000&width=150',
      'alias': 'ducales',
    },
    {
      'nombre': 'Galletas Saltin Noel',
      'categoria': 'Snacks',
      'imagenUrl':
          'https://exitocol.vtexassets.com/arquivos/ids/34385378/Galleta-Tradicional-Pqt-X-9-Pqts-Personales-839016_a.jpg?v=639211341607330000',
      'alias': 'saltin',
    },
    {
      'nombre': 'Margarina Campi con sal',
      'categoria': 'Lácteos',
      'imagenUrl':
          'https://exitocol.vtexassets.com/arquivos/ids/34464969/Mantequilla-Esparcible-Con-Sal-X-500-gr-102611_a.jpg?v=639213811047100000',
      'alias': 'campi',
    },
    {
      'nombre': 'Manzana roja',
      'categoria': 'Frutas',
      'imagenUrl':
          'https://upload.wikimedia.org/wikipedia/commons/3/3c/Manzana_Roja_Colombiana.jpg',
      'alias': 'manzana',
    },
  ];

  // ============================================================
  // USUARIO ACTUAL
  // ============================================================

  static String get uid {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return usuario.uid;
  }

  // ============================================================
  // NORMALIZAR NOMBRES
  // ============================================================

  static String normalizarNombreProducto(String nombre) {
    return nombre
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================================
  // BUSCAR EN EL CATÁLOGO DE RESPALDO
  // ============================================================

  static Map<String, dynamic>? _buscarProductoLocal(String nombre) {
    final buscado = normalizarNombreProducto(nombre);

    if (buscado.isEmpty) return null;

    for (final producto in _productosConImagen) {
      final alias = normalizarNombreProducto(
        producto['alias'] ?? '',
      );

      if (alias.isNotEmpty && buscado.contains(alias)) {
        return {
          'nombre': producto['nombre'],
          'categoria': producto['categoria'],
          'imagenUrl': producto['imagenUrl'],
        };
      }
    }

    return null;
  }

  // ============================================================
  // AGREGAR ALIMENTO
  // ============================================================

  static Future<String> addFood(FoodModel food) async {
    final usuarioId = uid;
    final id = food.id.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'El alimento debe tener un identificador válido.',
      );
    }

    final documento = db.collection('alimentos').doc(id);

    await documento.set({
      ...food.toMap(),
      'usuarioId': usuarioId,
    });

    return documento.id;
  }

  // ============================================================
  // OBTENER ALIMENTOS DEL USUARIO
  // ============================================================

  static Stream<List<FoodModel>> getFoods() {
    final usuarioId = uid;

    return db
        .collection('alimentos')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((documento) {
        return FoodModel.fromMap(
          documento.id,
          documento.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // BUSCAR PRODUCTO POR CÓDIGO DE BARRAS
  // ============================================================

  static Future<Map<String, dynamic>?> buscarProductoPorCodigo(
    String codigoBarras,
  ) async {
    final codigo = codigoBarras.trim();

    if (codigo.isEmpty) return null;

    final documento = await db
        .collection('catalogo_productos')
        .doc(codigo)
        .get();

    if (documento.exists) {
      final datos = documento.data();

      if (datos != null) {
        final imagen = datos['imagenUrl']?.toString().trim();

        if (imagen != null && imagen.isNotEmpty) {
          return {
            'codigoBarras': codigo,
            'nombre': datos['nombre']?.toString() ?? '',
            'categoria': datos['categoria']?.toString() ?? 'Otros',
            'imagenUrl': imagen,
          };
        }

        final productoLocal = _buscarProductoLocal(
          datos['nombre']?.toString() ?? '',
        );

        if (productoLocal != null) {
          return {
            ...productoLocal,
            'codigoBarras': codigo,
          };
        }
      }
    }

    // Códigos conocidos para búsquedas de respaldo.
    if (codigo == '77003004134939') {
      return {
        ..._productosConImagen[3],
        'codigoBarras': codigo,
      };
    }

    if (codigo == '7702109000334') {
      return {
        ..._productosConImagen[2],
        'codigoBarras': codigo,
      };
    }

    return null;
  }

  // ============================================================
  // BUSCAR PRODUCTO POR NOMBRE
  // ============================================================

  static Future<Map<String, dynamic>?> buscarProductoPorNombre(
    String nombre,
  ) async {
    final nombreBuscado = normalizarNombreProducto(nombre);

    if (nombreBuscado.isEmpty) return null;

    // Primero intentamos consultar el catálogo de Firebase.
    final catalogo =
        await db.collection('catalogo_productos').get();

    for (final documento in catalogo.docs) {
      final datos = documento.data();

      final nombreCatalogo = normalizarNombreProducto(
        datos['nombre']?.toString() ?? '',
      );

      if (nombreCatalogo == nombreBuscado) {
        final imagen = datos['imagenUrl']?.toString().trim();

        // Si el documento tiene imagen, usamos la de Firebase.
        if (imagen != null && imagen.isNotEmpty) {
          return {
            'codigoBarras':
                datos['codigoBarras']?.toString() ?? documento.id,
            'nombre': datos['nombre']?.toString() ?? '',
            'categoria': datos['categoria']?.toString() ?? 'Otros',
            'imagenUrl': imagen,
          };
        }

        // Si no tiene imagen, probamos el catálogo de respaldo.
        final productoLocal = _buscarProductoLocal(
          datos['nombre']?.toString() ?? nombre,
        );

        if (productoLocal != null) {
          return {
            ...productoLocal,
            'codigoBarras':
                datos['codigoBarras']?.toString() ?? documento.id,
          };
        }
      }
    }

    // Si no está registrado en Firebase, usamos el respaldo.
    return _buscarProductoLocal(nombre);
  }

  // ============================================================
  // BUSCAR IMAGEN POR NOMBRE
  // ============================================================

  static Future<String?> buscarImagenPorNombre(
    String nombre,
  ) async {
    final producto = await buscarProductoPorNombre(nombre);

    if (producto == null) return null;

    final imagen = producto['imagenUrl']?.toString().trim();

    if (imagen == null || imagen.isEmpty) return null;

    final uri = Uri.tryParse(imagen);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return imagen;
  }

  // ============================================================
  // GUARDAR O ACTUALIZAR CATÁLOGO DE PRODUCTOS
  // ============================================================

  static Future<void> guardarProductoEnCatalogo({
    required String codigoBarras,
    required String nombre,
    required String categoria,
    String? imagenUrl,
  }) async {
    final codigo = codigoBarras.trim();
    final nombreLimpio = nombre.trim();
    final categoriaLimpia = categoria.trim();
    final imagenLimpia = imagenUrl?.trim();

    if (codigo.isEmpty) {
      throw ArgumentError(
        'El código de barras no puede estar vacío.',
      );
    }

    if (nombreLimpio.isEmpty) {
      throw ArgumentError(
        'El nombre del producto no puede estar vacío.',
      );
    }

    final datos = <String, dynamic>{
      'codigoBarras': codigo,
      'nombre': nombreLimpio,
      'nombreNormalizado': normalizarNombreProducto(nombreLimpio),
      'categoria':
          categoriaLimpia.isEmpty ? 'Otros' : categoriaLimpia,
      'actualizadoEn': FieldValue.serverTimestamp(),
    };

    if (imagenLimpia != null && imagenLimpia.isNotEmpty) {
      final uri = Uri.tryParse(imagenLimpia);

      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        throw ArgumentError(
          'La URL de imagen no es válida.',
        );
      }

      datos['imagenUrl'] = imagenLimpia;
    }

    await db
        .collection('catalogo_productos')
        .doc(codigo)
        .set(
          datos,
          SetOptions(merge: true),
        );
  }

  // ============================================================
  // ELIMINAR ALIMENTO
  // ============================================================

  static Future<void> deleteFood(String id) async {
    final usuarioId = uid;
    final documento = db.collection('alimentos').doc(id);

    final existente = await documento.get();

    if (!existente.exists) {
      throw Exception('El alimento ya no existe.');
    }

    if (existente.data()?['usuarioId'] != usuarioId) {
      throw Exception(
        'No tienes permiso para eliminar este alimento.',
      );
    }

    await documento.delete();
  }

  // ============================================================
  // ACTUALIZAR ALIMENTO
  // ============================================================

  static Future<void> updateFood(FoodModel food) async {
    final usuarioId = uid;
    final documento = db.collection('alimentos').doc(food.id);

    final existente = await documento.get();

    if (!existente.exists) {
      throw Exception('El alimento ya no existe.');
    }

    if (existente.data()?['usuarioId'] != usuarioId) {
      throw Exception(
        'No tienes permiso para modificar este alimento.',
      );
    }

    await documento.update({
      ...food.toMap(),
      'usuarioId': usuarioId,
    });
  }
}
