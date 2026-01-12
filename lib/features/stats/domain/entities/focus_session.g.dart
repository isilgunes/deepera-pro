// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 2;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      completionTime: fields[0] as DateTime,
      durationInMinutes: fields[1] as int,
      taskName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.completionTime)
      ..writeByte(1)
      ..write(obj.durationInMinutes)
      ..writeByte(2)
      ..write(obj.taskName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
