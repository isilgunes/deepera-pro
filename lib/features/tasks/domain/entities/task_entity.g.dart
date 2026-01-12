// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskEntityAdapter extends TypeAdapter<TaskEntity> {
  @override
  final int typeId = 0;

  @override
  TaskEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskEntity(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      estimatedPomodoros: fields[3] as int,
      date: fields[4] as DateTime?,
      scheduledTime: fields[5] as String?,
      hasReminder: fields[6] as bool,
      sortIndex: fields[7] == null ? 0 : fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TaskEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.estimatedPomodoros)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.scheduledTime)
      ..writeByte(6)
      ..write(obj.hasReminder)
      ..writeByte(7)
      ..write(obj.sortIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
