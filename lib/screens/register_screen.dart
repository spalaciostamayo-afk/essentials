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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  String tipoCuenta = 'Hogar';

  // COLORES DE ESSENTIALS
  final Color beige = const Color.fromARGB(255, 240, 230, 178);
  final Color verdeOscuro = const Color(0xFF12381D);
  final Color verde = const Color(0xFF4CAF50);

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('No se pudo crear el usuario.');
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nombre': nameController.text.trim(),
        'email': emailController.text.trim(),
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

      String mensaje = 'No se pudo crear la cuenta.';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo electrónico no es válido.';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil.';
      } else if (e.code == 'network-request-failed') {
        mensaje = 'No hay conexión a internet.';
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
        setState(() {
          loading = false;
        });
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
    final bool seleccionado = tipoCuenta == titulo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            tipoCuenta = titulo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 8,
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
            children: [
              Icon(
                icono,
                size: 30,
                color: seleccionado ? Colors.white : verdeOscuro,
              ),
              const SizedBox(height: 7),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : verdeOscuro,
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
      prefixIcon: Icon(
        icono,
        color: verdeOscuro,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: verdeOscuro,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Container(
              width: isMobile ? double.infinity : 500,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
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
                    // BOTÓN REGRESAR
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: loading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: verdeOscuro,
                        ),
                        tooltip: 'Regresar',
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ICONO
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: verdeOscuro,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TITULO
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 32,
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
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // NOMBRE
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

                    // CORREO
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampo(
                        label: 'Correo electrónico',
                        icono: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu correo';
                        }

                        if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'Ingresa un correo válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CONTRASEÑA
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: _decoracionCampo(
                        label: 'Contraseña',
                        icono: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
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

                    const SizedBox(height: 28),

                    // TIPO DE CUENTA
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '¿Dónde vas a utilizar ESSENTIALS?',
                        style: TextStyle(
                          fontSize: 17,
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

                    const SizedBox(height: 15),

                    // HOGAR / COLEGIO / EMPRESA
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

                    const SizedBox(height: 30),

                    // CREAR CUENTA
                    SizedBox(
                      width: double.infinity,
                      height: 55,
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
                          elevation: 3,
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

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 15),

                    // YA TENGO CUENTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: verdeOscuro,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

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