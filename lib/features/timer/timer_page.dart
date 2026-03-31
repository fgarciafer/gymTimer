import 'package:flutter/material.dart';

import '../../services/timer_service.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _timerService = TimerService();

  @override
  void initState() {
    super.initState();

    _timerService.addListener(_update);
  }

  @override
  void dispose() {
    _timerService.removeListener(_update);

    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;

    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreno'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(
                _timerService.remainingSeconds,
              ),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_timerService.isRunning) {
                  _timerService.stop();
                } else {
                  _timerService.start();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: Text(
                _timerService.isRunning ? 'DETENER' : 'INICIAR DESCANSO',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
