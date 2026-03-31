import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 0)
enum WorkoutType {
  @HiveField(0)
  legs,

  @HiveField(1)
  upper,
}

@HiveType(typeId: 1)
class Exercise extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final WorkoutType type;

  @HiveField(4)
  final int order;

  Exercise({
    required this.id,
    required this.name,
    required this.weight,
    required this.type,
    required this.order,
  });

}