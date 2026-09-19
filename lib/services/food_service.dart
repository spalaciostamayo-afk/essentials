import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';

class FoodService {
  FoodService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // ============================================================
  // USUARIO ACTUAL
  // ============================================================

  static String get uid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return user.uid;
  }

  // ============================================================
  // AGREGAR ALIMENTO
  // ============================================================

  static Future<String> addFood(FoodModel food) async {
    final doc = await db.collection('alimentos').add(
      food.toMap(),
    );

    return doc.id;
  }

  // ============================================================
  // OBTENER ALIMENTOS DEL USUARIO
  // ============================================================

  static Stream<List<FoodModel>> getFoods() {
    final usuarioId = uid;

    return db
        .collection('alimentos')
        .where(
          'usuarioId',
          isEqualTo: usuarioId,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (doc) {
                return FoodModel.fromMap(
                  doc.id,
                  doc.data(),
                );
              },
            ).toList();
          },
        );
  }

  // ============================================================
  // ELIMINAR ALIMENTO
  // ============================================================

  static Future<void> deleteFood(String id) async {
    await db
        .collection('alimentos')
        .doc(id)
        .delete();
  }

  // ============================================================
  // EDITAR ALIMENTO
  // ============================================================

  static Future<void> updateFood(FoodModel food) async {
    await db
        .collection('alimentos')
        .doc(food.id)
        .update(
          food.toMap(),
        );
  }
}