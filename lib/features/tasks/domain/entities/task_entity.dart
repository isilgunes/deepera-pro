import 'package:hive/hive.dart';

part 'task_entity.g.dart';

@HiveType(typeId: 0)
class TaskEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final int estimatedPomodoros;

  @HiveField(4)
  final DateTime? date;

  @HiveField(5)
  final String? scheduledTime; // Store as "HH:mm"

  @HiveField(6)
  final bool hasReminder;

  @HiveField(7, defaultValue: 0)
  final int sortIndex;

  TaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.estimatedPomodoros = 1,
    this.date,
    this.scheduledTime,
    this.hasReminder = false,
    this.sortIndex = 0,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? estimatedPomodoros,
    DateTime? date,
    String? scheduledTime,
    bool? hasReminder,
    int? sortIndex,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      hasReminder: hasReminder ?? this.hasReminder,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  // JSON Serialization for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'estimatedPomodoros': estimatedPomodoros,
      'date': date?.toIso8601String(),
      'scheduledTime': scheduledTime,
      'hasReminder': hasReminder,
      'sortIndex': sortIndex,
    };
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      estimatedPomodoros: map['estimatedPomodoros'] as int? ?? 1,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      scheduledTime: map['scheduledTime'] as String?,
      hasReminder: map['hasReminder'] as bool? ?? false,
      sortIndex: map['sortIndex'] as int? ?? 0,
    );
  }
}
