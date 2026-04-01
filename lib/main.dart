import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/exercises/exercise_model.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();

    Hive.registerAdapter(WorkoutTypeAdapter());
    Hive.registerAdapter(ExerciseAdapter());

    await NotificationService.init();
    await NotificationService.requestPermission();
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }

  runApp(const MyApp());
}