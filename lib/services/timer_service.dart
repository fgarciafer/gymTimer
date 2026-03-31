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

    remainingSeconds = initialSeconds;

    isRunning = true;

    NotificationService.showRunningTimer(remainingSeconds);

    _notify();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {

        if (remainingSeconds <= 1) {

          timer.cancel();

          remainingSeconds = 0;

          isRunning = false;

          await NotificationService.cancelTimerNotification();

          await NotificationService.showTimerFinished();

        }
        else {

          remainingSeconds--;

          await NotificationService.showRunningTimer(
            remainingSeconds,
          );

        }

        _notify();

      },
    );
  }

  void dispose() {
    _timer?.cancel();
  }

  void stop() {

  _timer?.cancel();

  remainingSeconds = initialSeconds;

  isRunning = false;

  NotificationService.cancelTimerNotification();

  _notify();

}

}