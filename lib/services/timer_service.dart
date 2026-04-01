import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();

  factory TimerService() => _instance;

  TimerService._internal() {
    _startHeartbeat();
  }

  static const int initialSeconds = 60;

  Timer? _timer;

  Timer? _heartbeat;

  DateTime? _endTime;

  int remainingSeconds = initialSeconds;

  bool isRunning = false;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void start() {
    _timer?.cancel();

    _endTime = DateTime.now().add(
      const Duration(seconds: initialSeconds),
    );

    isRunning = true;

    _tick();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void stop() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('cancel_timer');
    await prefs.remove('restart_timer');

    _timer?.cancel();

    _endTime = null;

    remainingSeconds = initialSeconds;

    isRunning = false;

    await NotificationService.cancelTimerNotification();

    _notify();
  }

  void _tick() async {
    if (_endTime == null) return;

    final diff = _endTime!.difference(DateTime.now()).inSeconds;

    remainingSeconds = diff.clamp(
      0,
      initialSeconds,
    );

    if (remainingSeconds == 0) {
      _timer?.cancel();

      isRunning = false;

      await NotificationService.cancelTimerNotification();

      await NotificationService.showTimerFinished();
    } else {
      await NotificationService.showRunningTimer(
        remainingSeconds,
      );
    }

    _notify();
  }

  void _startHeartbeat() {
    _heartbeat ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkPendingActions(),
    );
  }

  Future<void> _checkPendingActions() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.reload();

    final restart = prefs.getBool(
          'restart_timer',
        ) ??
        false;

    if (restart) {
      await prefs.remove(
        'restart_timer',
      );

      start();

      return;
    }

    final cancel = prefs.getBool(
          'cancel_timer',
        ) ??
        false;

    if (cancel) {
      await prefs.remove(
        'cancel_timer',
      );

      stop();

      return;
    }
  }

  void dispose() {
    _timer?.cancel();

    _heartbeat?.cancel();
  }
}
