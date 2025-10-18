import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';

class AddExerciseScreen extends StatefulWidget {
  static const route = '/add-exercise';
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _form = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String name = '';
  int sets = 3;
  int reps = 10;
  int duration = 0;
  String equipment = '';
  String notes = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        actions: [
          TextButton(
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              _form.currentState!.save();
              final ex = Exercise(
                id: _uuid.v4(),
                name: name,
                sets: sets,
                reps: reps,
                durationSeconds: duration,
                equipment: equipment,
                notes: notes,
                description: description,
              );
              Navigator.pop(context, {'exercise': ex});
            },
            child: const Text('Save'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Form(
                key: _form,
                child: Column(children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Exercise Name *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onSaved: (v) => name = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Sets'),
                        initialValue: '3',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => sets = int.tryParse(v ?? '3') ?? 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Reps'),
                        initialValue: '10',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => reps = int.tryParse(v ?? '10') ?? 10,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Duration (seconds)'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => duration = int.tryParse(v ?? '0') ?? 0,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Equipment'),
                    onSaved: (v) => equipment = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Exercise Description',
                      hintText: 'How to perform this exercise...',
                    ),
                    minLines: 2, maxLines: 3,
                    onSaved: (v) => description = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                    minLines: 2, maxLines: 5,
                    onSaved: (v) => notes = v?.trim() ?? '',
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}