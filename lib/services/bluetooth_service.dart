import 'dart:async';

import 'package:bluetooth_serial_android/bluetooth_serial_android.dart';

class BluetoothService {
  BluetoothService._();

  static final BluetoothService instance = BluetoothService._();

  final StreamController<void> _cambiosController =
      StreamController<void>.broadcast();

  final List<String> _codigosPendientes = <String>[];

  bool conectado = false;
  bool conectando = false;
  bool leyendo = false;

  bool _detenido = false;

  String? direccionConectada;
  String? ultimoError;

  String ultimoCodigo = 'Todavía no se ha recibido ningún código.';

  Stream<void> get cambios => _cambiosController.stream;

  bool get hayCodigosPendientes => _codigosPendientes.isNotEmpty;

  String? get primerCodigoPendiente =>
      _codigosPendientes.isEmpty ? null : _codigosPendientes.first;

  void _notificarCambio() {
    if (!_cambiosController.isClosed) {
      _cambiosController.add(null);
    }
  }

  // Buscar dispositivos emparejados.
  Future<List<Map<String, String>>> buscarDispositivos() async {
    await FlutterBluetoothSerial.ensurePermissions();

    final resultado =
        await FlutterBluetoothSerial.getPairedDevices();

    return resultado.map<Map<String, String>>((dispositivo) {
      return {
        'nombre':
            dispositivo['name']?.toString() ??
                'Dispositivo sin nombre',
        'direccion':
            dispositivo['address']?.toString() ?? '',
      };
    }).toList();
  }

  // Conectar al ESP32.
  Future<void> conectar(String direccion) async {
    if (conectado || conectando) return;

    conectando = true;
    ultimoError = null;
    _detenido = false;
    _notificarCambio();

    try {
      await FlutterBluetoothSerial.connect(
        direccion,
        uuid: '00001101-0000-1000-8000-00805F9B34FB',
        timeoutMs: 300,
      );

      direccionConectada = direccion;
      conectado = true;

      _notificarCambio();

      unawaited(_leerContinuamente());
    } catch (e) {
      conectado = false;
      direccionConectada = null;
      ultimoError = e.toString();

      _notificarCambio();

      rethrow;
    } finally {
      conectando = false;
      _notificarCambio();
    }
  }

  // Leer continuamente las líneas enviadas por la ESP32.
  // El formato esperado es BARCODE:<código>
  Future<void> _leerContinuamente() async {
    if (leyendo) return;

    leyendo = true;
    _notificarCambio();

    try {
      while (conectado && !_detenido) {
        final linea =
            await FlutterBluetoothSerial.readLine('\n');

        if (!conectado || _detenido) break;

        if (linea == null || linea.trim().isEmpty) {
          continue;
        }

        final texto = linea.trim();

        if (!texto.startsWith('BARCODE:')) {
          continue;
        }

        final codigo =
            texto.substring('BARCODE:'.length).trim();

        if (codigo.isEmpty) continue;

        ultimoCodigo = codigo;
        _codigosPendientes.add(codigo);

        // El controlador global recibirá este aviso y abrirá
        // el formulario aunque estemos en otra pantalla.
        _notificarCambio();
      }
    } catch (e) {
      if (!_detenido) {
        ultimoError = e.toString();
        conectado = false;
        direccionConectada = null;
        _notificarCambio();
      }
    } finally {
      leyendo = false;
      _notificarCambio();
    }
  }

  // Retirar el código que ya fue atendido.
  void marcarCodigoProcesado(String codigo) {
    final indice = _codigosPendientes.indexOf(codigo);

    if (indice != -1) {
      _codigosPendientes.removeAt(indice);
    }

    _notificarCambio();
  }

  // Desconectar solamente cuando el usuario lo solicite.
  Future<void> desconectar() async {
    _detenido = true;
    conectado = false;
    conectando = false;
    direccionConectada = null;

    _notificarCambio();

    try {
      await FlutterBluetoothSerial.disconnect();
    } catch (e) {
      ultimoError = e.toString();
    }

    _notificarCambio();
  }
}