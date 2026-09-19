
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Solicitar permiso para notificaciones en Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> programarAlerta({
    required int id,
    required String nombreAlimento,
    required DateTime fechaVencimiento,
  }) async {
    // Alertar 5 días antes
    final fechaAlerta = fechaVencimiento.subtract(
      const Duration(days: 5),
    );

    // Si ya pasó la fecha de alerta, no programamos nada.
    if (fechaAlerta.isBefore(DateTime.now())) {
      return;
    }

    final fechaProgramada = tz.TZDateTime.from(
      fechaAlerta,
      tz.local,
    );

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'alimentos_vencimiento',
        'Vencimiento de alimentos',
        channelDescription:
            'Alertas sobre alimentos próximos a vencer',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      '⚠️ Alimento próximo a vencer',
      '$nombreAlimento vence en 5 días',
      fechaProgramada,
      detalles,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelarAlerta(int id) async {
    await _notifications.cancel(id);
  }
}
