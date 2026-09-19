import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final DateTime fechaVencimiento;
  final String usuarioId;

  FoodModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.fechaVencimiento,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "categoria": categoria,
      "cantidad": cantidad,
      "fechaVencimiento": Timestamp.fromDate(fechaVencimiento),
      "usuarioId": usuarioId,
    };
  }

  factory FoodModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime fecha;

    final valor = map["fechaVencimiento"];

    if (valor == null) {
      fecha = DateTime.now();
    } else if (valor is Timestamp) {
      fecha = valor.toDate();
    } else if (valor is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(valor);
    } else if (valor is String) {
      fecha = DateTime.parse(valor);
    } else {
      fecha = DateTime.now();
    }

    return FoodModel(
      id: id,
      nombre: map["nombre"] ?? "",
      categoria: map["categoria"] ?? "",
      cantidad: map["cantidad"] ?? 0,
      fechaVencimiento: fecha,
      usuarioId: map["usuarioId"] ?? "",
    );
  }

  int get diasRestantes {
    return fechaVencimiento.difference(DateTime.now()).inDays;
  }
}