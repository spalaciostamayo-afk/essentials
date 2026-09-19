import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ================= LOGIN =================

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= REGISTRO =================

 static Future<UserCredential> register({
  required String email,
  required String password,
  required String nombre,
  required String tipoCuenta,
}) async {
    UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
    await firestore.collection("usuarios").doc(user.uid).set({
  "uid": user.uid,
  "nombre": nombre,
  "correo": email,
  "tipoCuenta": tipoCuenta,
  "fechaRegistro": FieldValue.serverTimestamp(),
});
    }

    return userCredential;
  }

  // ================= LOGOUT =================

  static Future<void> logout() async {
    await auth.signOut();
  }

  // ================= RECUPERAR CONTRASEÑA =================

  static Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // ================= USUARIO ACTUAL =================

  static User? get currentUser => auth.currentUser;
}