
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;
  String tipoCuenta = 'Hogar';

  static const Color beige = Color(0xFFF0E6B2);
  static const Color verdeOscuro = Color(0xFF12381D);
  static const Color verde = Color(0xFF4CAF50);

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final nombre = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('No se pudo crear el usuario.');
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nombre': nombre,
        'email': email,
        'correo': email,
        'tipoCuenta': tipoCuenta,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensaje;

      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Este correo ya está registrado.';
          break;
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido.';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es demasiado débil.';
          break;
        case 'network-request-failed':
          mensaje = 'No hay conexión a internet.';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Inténtalo más tarde.';
          break;
        default:
          mensaje = 'No se pudo crear la cuenta: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _opcionTipoCuenta({
    required String titulo,
    required IconData icono,
  }) {
    final seleccionado = tipoCuenta == titulo;

    return Expanded(
      child: GestureDetector(
        onTap: loading
            ? null
            : () => setState(() => tipoCuenta = titulo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: seleccionado ? verde : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado ? verde : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: verde.withAlpha(45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 28,
                color: seleccionado ? Colors.white : verdeOscuro,
              ),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: seleccionado ? Colors.white : verdeOscuro,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionCampo({
    required String label,
    required IconData icono,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: verdeOscuro),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: verdeOscuro,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 700;

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              width: esMovil ? double.infinity : 500,
              margin: EdgeInsets.symmetric(
                horizontal: esMovil ? 14 : 25,
              ),
              padding: EdgeInsets.all(esMovil ? 20 : 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: loading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: verdeOscuro,
                        tooltip: 'Regresar',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 85,
                      width: 85,
                      decoration: const BoxDecoration(
                        color: verdeOscuro,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Crear cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: verdeOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a ESSENTIALS y comienza a cuidar tus alimentos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoracionCampo(
                        label: 'Nombre completo',
                        icono: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        if (value.trim().length < 3) {
                          return 'Ingresa un nombre válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoracionCampo(
                        label: 'Correo electrónico',
                        icono: Icons.email_outlined,
                      ),
                      validator: (value) {
                        final correo = value?.trim() ?? '';
                        if (correo.isEmpty) return 'Ingresa tu correo';

                        final formato = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!formato.hasMatch(correo)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: _decoracionCampo(
                        label: 'Contraseña',
                        icono: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          tooltip: obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: verdeOscuro,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'Debe tener mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 26),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '¿Dónde vas a utilizar ESSENTIALS?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selecciona el tipo de cuenta que deseas crear.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        _opcionTipoCuenta(
                          titulo: 'Hogar',
                          icono: Icons.home_outlined,
                        ),
                        _opcionTipoCuenta(
                          titulo: 'Colegio',
                          icono: Icons.school_outlined,
                        ),
                        _opcionTipoCuenta(
                          titulo: 'Empresa',
                          icono: Icons.business_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verdeOscuro,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              verdeOscuro.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Se adapta a pantallas estrechas sin desbordarse.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 0,
                      runSpacing: 0,
                      children: [
                        const Text(
                          '¿Ya tienes una cuenta?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: verdeOscuro,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Al crear una cuenta aceptas nuestras políticas de privacidad.',
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
        ),
      ),
    );
  }
}
