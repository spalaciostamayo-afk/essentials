
import 'dart:async';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color verde = Color(0xFF12381D);
  static const Color beige = Color(0xFFF3EED8);
  static const Color verdeClaro = Color(0xFF3F7048);

  late final AnimationController _entrada;
  late final AnimationController _flotacion;

  late final Animation<double> _opacidad;
  late final Animation<double> _escala;
  late final Animation<Offset> _desplazamiento;

  Timer? _temporizador;
  bool _navegando = false;

  @override
  void initState() {
    super.initState();

    _entrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _opacidad = CurvedAnimation(
      parent: _entrada,
      curve: const Interval(
        0.1,
        0.8,
        curve: Curves.easeIn,
      ),
    );

    _escala = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entrada,
        curve: Curves.elasticOut,
      ),
    );

    _desplazamiento = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrada,
        curve: Curves.easeOutCubic,
      ),
    );

    _flotacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _entrada.forward();

    _temporizador = Timer(
      const Duration(milliseconds: 3800),
      _abrirLogin,
    );
  }

  void _abrirLogin() {
    if (!mounted || _navegando) return;

    _navegando = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _entrada.dispose();
    _flotacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: verde,
      body: Stack(
        children: [
          // Círculos decorativos de fondo
          Positioned(
            top: -55,
            right: -45,
            child: _circuloDecorativo(
              190,
              verdeClaro.withAlpha(65),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -60,
            child: _circuloDecorativo(
              220,
              verdeClaro.withAlpha(55),
            ),
          ),

          // Hojas decorativas
          Positioned(
            top: 110,
            left: 35,
            child: _hoja(
              Icons.eco_outlined,
              30,
              75,
            ),
          ),
          Positioned(
            bottom: 145,
            right: 35,
            child: _hoja(
              Icons.eco,
              25,
              -35,
            ),
          ),

          // Logo animado: ahora es una hoja, no una imagen
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _entrada,
                _flotacion,
              ]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _opacidad,
                  child: SlideTransition(
                    position: _desplazamiento,
                    child: Transform.scale(
                      scale: _escala.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          5 * _flotacion.value - 2.5,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: beige,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(150),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(45),
                            blurRadius: 35,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.eco_rounded,
                          color: verde,
                          size: 75,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'ESSENTIALS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: beige,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: beige,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Lo esencial es cuidarte,\naprovecha lo que compras.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: beige,
                        fontSize: 15,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón para entrar inmediatamente
          Positioned(
            bottom: 34,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _opacidad,
              child: TextButton(
                onPressed: _abrirLogin,
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: beige,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circuloDecorativo(
    double tamano,
    Color color,
  ) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _hoja(
    IconData icono,
    double tamano,
    double rotacion,
  ) {
    return Transform.rotate(
      angle: rotacion * 3.141592653589793 / 180,
      child: Icon(
        icono,
        size: tamano,
        color: beige.withAlpha(90),
      ),
    );
  }
}
