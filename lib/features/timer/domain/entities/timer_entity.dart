import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_entity.freezed.dart';

enum TimerStatus {
  initial,
  running,
  paused,
  finished,
}

enum TimerType {
  pomodoro(25 * 60),
  shortBreak(5 * 60),
  longBreak(15 * 60);

  final int durationSeconds;
  const TimerType(this.durationSeconds);
}

@freezed
class TimerEntity with _$TimerEntity {
  const factory TimerEntity({
    required int remainingSeconds,
    required int initialDuration,
    required TimerStatus status,
    required TimerType type,
    @Default(0) int roundCount,
    String? currentTaskName,
  }) = _TimerEntity;

  factory TimerEntity.initial() => const TimerEntity(
        remainingSeconds: 25 * 60,
        initialDuration: 25 * 60,
        status: TimerStatus.initial,
        type: TimerType.pomodoro,
        roundCount: 0,
        currentTaskName: null,
      );
}
