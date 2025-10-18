// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      sets: fields[2] as int,
      reps: fields[3] as int,
      durationSeconds: fields[4] as int,
      equipment: fields[5] as String,
      notes: fields[6] as String,
      description: fields[7] as String,
      completedSets: fields[8] as int,
    )..howTo = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.completedSets)
      ..writeByte(9)
      ..write(obj.howTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
