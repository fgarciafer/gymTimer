import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'exercise_model.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  WorkoutType _selected = WorkoutType.legs;

  Box<Exercise>? _box;

  List<Exercise> _exercises = [];

  final Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    final box = await Hive.openBox<Exercise>('exercises');

    setState(() {
      _box = box;

      _exercises = box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_box == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _exercises.where((e) => e.type == _selected).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpiar checks',
            onPressed: _clearChecks,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openExerciseModal(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSelector(),
          _buildProgress(filtered),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: filtered.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;

                final item = filtered.removeAt(oldIndex);

                filtered.insert(newIndex, item);

                for (int i = 0; i < filtered.length; i++) {
                  final updated = Exercise(
                    id: filtered[i].id,
                    name: filtered[i].name,
                    weight: filtered[i].weight,
                    type: filtered[i].type,
                    order: i,
                  );

                  _box!.put(updated.id, updated);
                }

                setState(() {
                  _exercises = _box!.values.toList();
                });
              },
              itemBuilder: (context, index) {
                final exercise = filtered[index];

                final isDone = _completed.contains(exercise.id);

                return ListTile(
                  key: ValueKey(exercise.id),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    '${exercise.weight} kg',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isDone,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _completed.add(exercise.id);
                            } else {
                              _completed.remove(exercise.id);
                            }
                          });
                        },
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_handle,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _openExerciseModal(exercise),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearChecks() {
    setState(() {
      _completed.clear();
    });
  }

  Widget _buildSelector() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildOption('🦵 Piernas', WorkoutType.legs),
          const SizedBox(width: 12),
          _buildOption('💪 Superior', WorkoutType.upper),
        ],
      ),
    );
  }

  Widget _buildOption(String label, WorkoutType value) {
    final isSelected = _selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurple[600]
                : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _openExerciseModal([Exercise? exercise]) {
    final isEditing = exercise != null;

    final nameController = TextEditingController(text: exercise?.name ?? '');

    final weightController =
        TextEditingController(text: exercise?.weight.toString() ?? '');

    WorkoutType selectedType = exercise?.type ?? _selected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Editar ejercicio' : 'Añadir ejercicio',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          '🦵 Piernas',
                          WorkoutType.legs,
                          selectedType,
                          (val) => setModalState(() => selectedType = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeOption(
                          '💪 Superior',
                          WorkoutType.upper,
                          selectedType,
                          (val) => setModalState(() => selectedType = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();

                      final weight = double.tryParse(weightController.text);

                      if (name.isEmpty || weight == null) return;

                      final updated = Exercise(
                        id: exercise?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        name: name,
                        weight: weight,
                        type: selectedType,
                        order: exercise?.order ?? _exercises.length,
                      );

                      await _box!.put(updated.id, updated);

                      setState(() {
                        _exercises = _box!.values.toList();
                      });

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(isEditing ? 'Guardar cambios' : 'Guardar'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await _box!.delete(exercise.id);

                        setState(() {
                          _exercises = _box!.values.toList();

                          _completed.remove(exercise.id);
                        });

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Eliminar ejercicio',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeOption(
    String label,
    WorkoutType value,
    WorkoutType selected,
    Function(WorkoutType) onTap,
  ) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple[600]!
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(label),
      ),
    );
  }

  Widget _buildProgress(List<Exercise> list) {
    final completedCount = list.where((e) => _completed.contains(e.id)).length;

    final total = list.length;

    final progress = total == 0 ? 0.0 : completedCount / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso: $completedCount / $total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
