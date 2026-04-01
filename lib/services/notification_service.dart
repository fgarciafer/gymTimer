import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_service.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static const _runningChannelId = 'gym_timer_running_v2';
  static const _finishedChannelId = 'gym_timer_finished_v2';

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(android: androidSettings);

await _notifications.initialize(
  settings,

  onDidReceiveNotificationResponse:
      _handleNotificationResponse,

  onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
);

    /// Canal silencioso para el temporizador en curso
    const runningChannel = AndroidNotificationChannel(
      _runningChannelId,
      'Gym Timer running',
      description: 'Temporizador activo',
      importance: Importance.defaultImportance,
      sound: null,
      playSound: false,
    );

    /// Canal con sonido para el final del temporizador
    const finishedChannel = AndroidNotificationChannel(
      _finishedChannelId,
      'Gym Timer finished',
      description: 'Fin del descanso',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('beep'),
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(runningChannel);
    await androidPlugin?.createNotificationChannel(finishedChannel);
  }

  static Future<void> showRunningTimer(int seconds) async {
    final androidDetails = AndroidNotificationDetails(
      _runningChannelId,
      'Gym Timer running',
      channelDescription: 'Temporizador activo',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      visibility: NotificationVisibility.public,
      showProgress: true,
      maxProgress: 60,
      progress: seconds,
      icon: 'ic_notification',
      actions: [
        AndroidNotificationAction(
          'action_cancel',
          'Cancelar',
          showsUserInterface: false,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'Descanso',
      _formatTime(seconds),
      notificationDetails,
    );
  }

  static Future<void> showTimerFinished() async {
    const androidDetails = AndroidNotificationDetails(
      _finishedChannelId,
      'Gym Timer finished',
      channelDescription: 'Fin del descanso',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('beep'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      icon: 'ic_notification',
      actions: [
        AndroidNotificationAction(
          'action_restart',
          'Reiniciar',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'action_dismiss',
          'Cerrar',
          showsUserInterface: false,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'Tiempo cumplido',
      'Ya puedes empezar la siguiente serie 💪',
      notificationDetails,
    );
  }

  static Future<void> cancelTimerNotification() async {
    await _notifications.cancel(1);
  }

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')} restantes';
  }

  static Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId == 'action_restart') {
      await cancelTimerNotification();
      TimerService().start();
    } else if (response.actionId == 'action_dismiss') {
      await cancelTimerNotification();
    } else if (response.actionId == 'action_cancel') {
      await cancelTimerNotification();
      TimerService().stop();
    }
  }

  static Future<void> requestPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.requestNotificationsPermission();

    if (granted == false) {
      print('Permiso de notificaciones denegado');
    }
  }
}


@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse response) async {

  final prefs =
      await SharedPreferences.getInstance();

  if (response.actionId == 'action_cancel') {

    await prefs.setBool(
      'cancel_timer',
      true,
    );

    await NotificationService
        .cancelTimerNotification();
  }

}