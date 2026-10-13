
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final DateTime fechaVencimiento;
  final String usuarioId;

  // Datos opcionales para identificar el producto y mostrar su imagen.
  final String? codigoBarras;
  final String? imagenUrl;

  const FoodModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.fechaVencimiento,
    required this.usuarioId,
    this.codigoBarras,
    this.imagenUrl,
  });

  // Convierte el alimento a un mapa compatible con Firebase.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'usuarioId': usuarioId,
      if (codigoBarras != null && codigoBarras!.trim().isNotEmpty)
        'codigoBarras': codigoBarras!.trim(),
      if (imagenUrl != null && imagenUrl!.trim().isNotEmpty)
        'imagenUrl': imagenUrl!.trim(),
    };
  }

  // Crea un alimento a partir de los datos de Firebase.
  factory FoodModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final dynamic fechaRaw = map['fechaVencimiento'];

    DateTime fecha;

    if (fechaRaw is Timestamp) {
      fecha = fechaRaw.toDate();
    } else if (fechaRaw is DateTime) {
      fecha = fechaRaw;
    } else if (fechaRaw is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(fechaRaw);
    } else if (fechaRaw is String) {
      fecha = DateTime.tryParse(fechaRaw) ?? DateTime.now();
    } else {
      fecha = DateTime.now();
    }

    final dynamic cantidadRaw = map['cantidad'];

    int cantidadConvertida;

    if (cantidadRaw is int) {
      cantidadConvertida = cantidadRaw;
    } else if (cantidadRaw is num) {
      cantidadConvertida = cantidadRaw.toInt();
    } else {
      cantidadConvertida =
          int.tryParse(cantidadRaw?.toString() ?? '') ?? 0;
    }

    return FoodModel(
      id: id,
      nombre: (map['nombre'] ?? '').toString(),
      categoria: (map['categoria'] ?? 'Otros').toString(),
      cantidad: cantidadConvertida,
      fechaVencimiento: fecha,
      usuarioId: (map['usuarioId'] ?? '').toString(),
      codigoBarras: _textoOpcional(map['codigoBarras']),
      imagenUrl: _textoOpcional(map['imagenUrl']),
    );
  }

  static String? _textoOpcional(dynamic valor) {
    if (valor == null) return null;

    final texto = valor.toString().trim();

    if (texto.isEmpty) return null;

    return texto;
  }

  // Cantidad de días que faltan para el vencimiento.
  int get diasRestantes {
    final hoy = DateTime.now();

    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    final vencimientoSinHora = DateTime(
      fechaVencimiento.year,
      fechaVencimiento.month,
      fechaVencimiento.day,
    );

    return vencimientoSinHora.difference(hoySinHora).inDays;
  }
}
