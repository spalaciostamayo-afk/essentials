import 'package:flutter/material.dart';
import 'package:essentials/services/firebase_service.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  static const Color verdePrincipal = Color(0xFF12381D);
  static const Color verdeClaro = Color(0xFF3F7048);
  static const Color beigeFondo = Color.fromARGB(255, 243, 232, 169);
  static const Color blancoTarjeta = Color(0xFFFFFFFF);
  static const Color textoPrincipal = Color(0xFF1F1F1F);
  static const Color textoSecundario = Color(0xFF6B7280);

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos"),
        ),
      );
      return;
    }

    try {
      await FirebaseService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> recuperarContrasena() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Escribe tu correo electrónico para recuperar tu contraseña.",
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseService.resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Te enviamos un enlace para restablecer tu contraseña.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: beigeFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: Container(
              width: isMobile ? double.infinity : 500,
              padding: EdgeInsets.all(isMobile ? 25 : 35),
              decoration: BoxDecoration(
                color: blancoTarjeta,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 25,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ==============================
                  // LOGO
                  // ==============================

                  Container(
                    width: isMobile ? 120 : 140,
                    height: isMobile ? 120 : 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: beigeFondo,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 65,
                            color: verdePrincipal,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==============================
                  // NOMBRE
                  // ==============================

                  const Text(
                    "ESSENTIALS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: textoPrincipal,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Gestiona tus alimentos sin desperdicios",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textoSecundario,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ==============================
                  // CORREO
                  // ==============================

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      hintText: "ejemplo@correo.com",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: verdePrincipal,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: verdePrincipal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================
                  // CONTRASEÑA
                  // ==============================

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: verdePrincipal,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: verdeClaro,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: verdePrincipal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==============================
                  // OLVIDASTE CONTRASEÑA
                  // ==============================

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: recuperarContrasena,
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: verdeClaro,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==============================
                  // INICIAR SESIÓN
                  // ==============================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdePrincipal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==============================
                  // CREAR CUENTA
                  // ==============================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verdePrincipal,
                        side: const BorderSide(
                          color: verdePrincipal,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==============================
                  // DIVISOR
                  // ==============================

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withAlpha(80),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "ESSENTIALS",
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withAlpha(80),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Al iniciar sesión aceptas nuestras "
                    "políticas de privacidad.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textoSecundario,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}