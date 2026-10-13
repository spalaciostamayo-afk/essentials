import 'dart:async';

import 'package:flutter/material.dart';

import 'services/bluetooth_service.dart';

const Color verdePrincipal = Color(0xFF12381D);
const Color verdeSecundario = Color(0xFF3F7048);
const Color beigeFondo = Color(0xFFF3EED8);

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothService bluetooth = BluetoothService.instance;

  StreamSubscription<void>? suscripcionBluetooth;

  List<Map<String, String>> dispositivos = [];

  bool cargando = false;
  bool conectado = false;

  String mensaje = 'Busca tu ESP32 para comenzar.';
  String ultimoCodigo = 'Todavía no se ha recibido ningún código.';

  @override
  void initState() {
    super.initState();

    _actualizarEstado();

    suscripcionBluetooth = bluetooth.cambios.listen((_) {
      if (!mounted) return;

      setState(_actualizarEstado);
    });
  }

  void _actualizarEstado() {
    conectado = bluetooth.conectado;
    ultimoCodigo = bluetooth.ultimoCodigo;

    if (bluetooth.ultimoError != null && !bluetooth.conectado) {
      mensaje = 'Error de Bluetooth: ${bluetooth.ultimoError}';
    } else if (bluetooth.conectado) {
      mensaje = 'Conectado. Puedes escanear códigos desde cualquier '
          'pantalla de ESSENTIALS.';
    }
  }

  Future<void> buscarDispositivos() async {
    if (cargando || bluetooth.conectado || bluetooth.conectando) {
      return;
    }

    setState(() {
      cargando = true;
      mensaje = 'Buscando dispositivos emparejados...';
      dispositivos = [];
    });

    try {
      final resultado = await bluetooth.buscarDispositivos();

      if (!mounted) return;

      setState(() {
        dispositivos = resultado;

        mensaje = dispositivos.isEmpty
            ? 'No hay dispositivos emparejados. Empareja primero '
                'la ESP32 desde los ajustes Bluetooth de Android.'
            : 'Selecciona tu ESP32 para conectarte.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensaje = 'No se pudieron buscar dispositivos: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> conectar(String direccion) async {
    if (cargando || bluetooth.conectado || bluetooth.conectando) {
      return;
    }

    setState(() {
      cargando = true;
      mensaje = 'Conectando con la ESP32...';
    });

    try {
      await bluetooth.conectar(direccion);

      if (!mounted) return;

      setState(() {
        conectado = bluetooth.conectado;
        mensaje = 'Conectado. Escanea un código de barras desde '
            'cualquier pantalla.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        conectado = bluetooth.conectado;
        mensaje = 'No se pudo conectar con la ESP32: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> desconectar() async {
    setState(() {
      cargando = true;
    });

    try {
      await bluetooth.desconectar();

      if (!mounted) return;

      setState(() {
        conectado = false;
        mensaje = 'Desconectado de la ESP32.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensaje = 'No se pudo desconectar: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // No desconectar la ESP32 al salir de esta pantalla.
    unawaited(suscripcionBluetooth?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conectadoAhora = bluetooth.conectado;

    return Scaffold(
      backgroundColor: beigeFondo,
      appBar: AppBar(
        backgroundColor: verdePrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bluetooth ESSENTIALS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Icon(
                    conectadoAhora
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    size: 72,
                    color: conectadoAhora
                        ? verdeSecundario
                        : verdePrincipal,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Conecta tu ESSENTIALS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: verdePrincipal,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: cargando ||
                              conectadoAhora ||
                              bluetooth.conectando
                          ? null
                          : buscarDispositivos,
                      icon: cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        cargando
                            ? 'Procesando...'
                            : 'Buscar dispositivos emparejados',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdePrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Dispositivos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: verdePrincipal,
              ),
            ),
            const SizedBox(height: 10),
            if (dispositivos.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Aquí aparecerán los dispositivos que ya estén '
                  'emparejados con tu celular.',
                  textAlign: TextAlign.center,
                ),
              ),
            ...dispositivos.map((dispositivo) {
              final nombre = dispositivo['nombre']!;
              final direccion = dispositivo['direccion']!;

              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: beigeFondo,
                    child: Icon(
                      Icons.memory,
                      color: verdePrincipal,
                    ),
                  ),
                  title: Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(direccion),
                  trailing: conectadoAhora
                      ? const Icon(
                          Icons.check_circle,
                          color: verdeSecundario,
                        )
                      : const Icon(
                          Icons.link,
                          color: verdePrincipal,
                        ),
                  onTap: conectadoAhora ||
                          cargando ||
                          bluetooth.conectando
                      ? null
                      : () => conectar(direccion),
                ),
              );
            }),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: verdeSecundario.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: verdePrincipal,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Último código recibido',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: verdePrincipal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: SelectableText(
                      ultimoCodigo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: verdeSecundario,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (conectadoAhora)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: cargando ? null : desconectar,
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('Desconectar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: verdePrincipal,
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}