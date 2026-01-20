import 'package:hive/hive.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 2)
class FocusSession extends HiveObject {
  @HiveField(0)
  final DateTime completionTime;

  @HiveField(1)
  final int durationInMinutes;

  @HiveField(2)
  final String? taskName;

  FocusSession({
    required this.completionTime,
    required this.durationInMinutes,
    this.taskName,
  });

  // JSON Serialization
  Map<String, dynamic> toMap() {
    return {
      'completionTime': completionTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'taskName': taskName,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      completionTime: DateTime.parse(map['completionTime']),
      durationInMinutes: map['durationInMinutes'] as int,
      taskName: map['taskName'] as String?,
    );
  }
}
