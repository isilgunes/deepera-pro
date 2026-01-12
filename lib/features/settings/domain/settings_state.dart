import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(25) int focusDuration,
    @Default(5) int shortBreakDuration,
    @Default(15) int longBreakDuration,
    @Default(false) bool autoStartBreaks,
    @Default(true) bool isAlarmEnabled,
  }) = _SettingsState;
}
