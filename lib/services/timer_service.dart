import 'dart:async';

import 'package:flutter/foundation.dart';

import 'notification_service.dart';

class TimerService {

  static final TimerService _instance =
      TimerService._internal();

  factory TimerService() => _instance;

  TimerService._internal();

  static const int initialSeconds = 60;

  Timer? _timer;

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

    _endTime =
        DateTime.now().add(
          const Duration(seconds: initialSeconds),
        );

    isRunning = true;

    _tick();

    _timer =
        Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() async {

    if (_endTime == null) return;

    final diff =
        _endTime!
            .difference(DateTime.now())
            .inSeconds;

    remainingSeconds =
        diff.clamp(0, initialSeconds);

    if (remainingSeconds == 0) {

      _timer?.cancel();

      isRunning = false;

      await NotificationService
          .cancelTimerNotification();

      await NotificationService
          .showTimerFinished();
    }
    else {

      await NotificationService
          .showRunningTimer(
            remainingSeconds,
          );
    }

    _notify();
  }

  void stop() {

    _timer?.cancel();

    remainingSeconds =
        initialSeconds;

    isRunning = false;

    NotificationService
        .cancelTimerNotification();

    _notify();
  }

  void dispose() {
    _timer?.cancel();
  }

}