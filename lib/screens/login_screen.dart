
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
  bool loading = false;

  static const Color verdePrincipal = Color(0xFF12381D);
  static const Color verdeClaro = Color(0xFF3F7048);
  static const Color beigeFondo = Color(0xFFF3EED8);
  static const Color textoPrincipal = Color(0xFF1F2921);
  static const Color textoSecundario = Color(0xFF68736A);

  Future<void> login() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos.'),
          backgroundColor: verdePrincipal,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseService.login(
        email: email,
        password: password,
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
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> recuperarContrasena() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escribe tu correo electrónico para recuperar tu contraseña.',
          ),
          backgroundColor: verdePrincipal,
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
            'Te enviamos un enlace para restablecer tu contraseña.',
          ),
          backgroundColor: verdePrincipal,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
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

  InputDecoration decoracionCampo({
    required String etiqueta,
    required String sugerencia,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: sugerencia,
      prefixIcon: Icon(
        icono,
        color: verdePrincipal,
      ),
      suffixIcon: sufijo,
      filled: true,
      fillColor: const Color(0xFFF9FAF6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E5DC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E5DC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: verdePrincipal,
          width: 1.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 600;

    return Scaffold(
      backgroundColor: beigeFondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    // CABECERA VERDE
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: esMovil ? 35 : 45,
                        bottom: esMovil ? 38 : 48,
                        left: 24,
                        right: 24,
                      ),
                      decoration: const BoxDecoration(
                        color: verdePrincipal,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(38),
                          bottomRight: Radius.circular(38),
                        ),
                      ),
                      child: Column(
                        children: [
                          // HOJA EN LUGAR DEL LOGO ANTERIOR
                          Container(
                            width: esMovil ? 100 : 112,
                            height: esMovil ? 100 : 112,
                            decoration: BoxDecoration(
                              color: beigeFondo,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(100),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 62,
                              color: verdePrincipal,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'ESSENTIALS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: beigeFondo,
                              fontSize: esMovil ? 30 : 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Gestiona tus alimentos\nsin desperdicios',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: beigeFondo,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Container(
                            width: 48,
                            height: 3,
                            decoration: BoxDecoration(
                              color: beigeFondo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // FORMULARIO
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 480,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: esMovil ? 23 : 35,
                            vertical: 30,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                '¡Bienvenido de nuevo!',
                                style: TextStyle(
                                  color: textoPrincipal,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Ingresa a tu cuenta para continuar.',
                                style: TextStyle(
                                  color: textoSecundario,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 26),

                              TextField(
                                controller: emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                decoration: decoracionCampo(
                                  etiqueta: 'Correo electrónico',
                                  sugerencia: 'ejemplo@correo.com',
                                  icono: Icons.mail_outline_rounded,
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => login(),
                                decoration: decoracionCampo(
                                  etiqueta: 'Contraseña',
                                  sugerencia: 'Ingresa tu contraseña',
                                  icono: Icons.lock_outline_rounded,
                                  sufijo: IconButton(
                                    tooltip: obscurePassword
                                        ? 'Mostrar contraseña'
                                        : 'Ocultar contraseña',
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword =
                                            !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: verdeClaro,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: loading
                                      ? null
                                      : recuperarContrasena,
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      color: verdeClaro,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 13),

                              // BOTÓN VERDE: INICIAR SESIÓN
                              SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: loading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: verdePrincipal,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        verdePrincipal.withAlpha(130),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          width: 23,
                                          height: 23,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Iniciar sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // BOTÓN VERDE: CREAR CUENTA
                              SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: verdeClaro,
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Crear cuenta',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 27),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color:
                                          verdePrincipal.withAlpha(40),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Icon(
                                      Icons.eco_outlined,
                                      color: verdeClaro,
                                      size: 19,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color:
                                          verdePrincipal.withAlpha(40),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 17),

                              const Text(
                                'Tu despensa, más organizada.\n'
                                'Menos desperdicio.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textoSecundario,
                                  fontSize: 13,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
