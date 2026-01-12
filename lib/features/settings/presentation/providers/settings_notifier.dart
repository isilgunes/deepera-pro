import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/settings_state.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  Box? _box;

  @override
  SettingsState build() {
    // Attempt to load synchronously if box is already open (should be from main.dart)
    if (Hive.isBoxOpen('settings')) {
      _box = Hive.box('settings');
      return SettingsState(
        focusDuration: _box!.get('focusDuration', defaultValue: 25),
        shortBreakDuration: _box!.get('shortBreakDuration', defaultValue: 5),
        longBreakDuration: _box!.get('longBreakDuration', defaultValue: 15),
        autoStartBreaks: _box!.get('autoStartBreaks', defaultValue: false),
        isAlarmEnabled: _box!.get('isAlarmEnabled', defaultValue: true),
      );
    }
    
    // Fallback: Init async and update state later
    _initAsync();
    return const SettingsState();
  }

  Future<void> _initAsync() async {
    _box = await Hive.openBox('settings');
    state = SettingsState(
      focusDuration: _box!.get('focusDuration', defaultValue: 25),
      shortBreakDuration: _box!.get('shortBreakDuration', defaultValue: 5),
      longBreakDuration: _box!.get('longBreakDuration', defaultValue: 15),
      autoStartBreaks: _box!.get('autoStartBreaks', defaultValue: false),
      isAlarmEnabled: _box!.get('isAlarmEnabled', defaultValue: true),
    );
  }

  void updateFocusDuration(int minutes) {
    state = state.copyWith(focusDuration: minutes);
    _box?.put('focusDuration', minutes);
  }

  void updateShortBreakDuration(int minutes) {
    state = state.copyWith(shortBreakDuration: minutes);
    _box?.put('shortBreakDuration', minutes);
  }

  void updateLongBreakDuration(int minutes) {
    state = state.copyWith(longBreakDuration: minutes);
    _box?.put('longBreakDuration', minutes);
  }

  void toggleAutoStart(bool value) {
    state = state.copyWith(autoStartBreaks: value);
    _box?.put('autoStartBreaks', value);
  }

  void toggleAlarm(bool value) {
    state = state.copyWith(isAlarmEnabled: value);
    _box?.put('isAlarmEnabled', value);
  }

  void saveSettings({
    required int focusDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
    required bool autoStartBreaks,
    required bool isAlarmEnabled,
  }) {
    state = state.copyWith(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      autoStartBreaks: autoStartBreaks,
      isAlarmEnabled: isAlarmEnabled,
    );
    _box?.put('focusDuration', focusDuration);
    _box?.put('shortBreakDuration', shortBreakDuration);
    _box?.put('longBreakDuration', longBreakDuration);
    _box?.put('autoStartBreaks', autoStartBreaks);
    _box?.put('isAlarmEnabled', isAlarmEnabled);
  }
}
