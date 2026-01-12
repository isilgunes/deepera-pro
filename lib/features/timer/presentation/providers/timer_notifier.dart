import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/timer_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../features/stats/domain/entities/focus_session.dart';
import '../../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../../../features/settings/domain/settings_state.dart';
import '../../../../features/audio/presentation/providers/sound_notifier.dart';
import 'dart:math';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  Box<FocusSession>? _box;

  @override
  TimerEntity build() {
    _initHive();
    
    final settings = ref.watch(settingsNotifierProvider);
    
    // Listen for settings changes to update timer if stopped
    ref.listen(settingsNotifierProvider, (previous, next) {
      if (state.status == TimerStatus.initial) {
         final newDuration = _getDurationForType(state.type, next);
         state = state.copyWith(
           initialDuration: newDuration,
           remainingSeconds: newDuration,
         );
      }
    });

    final duration = _getDurationForType(TimerType.pomodoro, settings);
    
    return TimerEntity(
      type: TimerType.pomodoro,
      status: TimerStatus.initial,
      initialDuration: duration,
      remainingSeconds: duration,
      roundCount: 0,
    );
  }

  Future<void> _initHive() async {
    if (Hive.isBoxOpen('focus_sessions')) {
      _box = Hive.box<FocusSession>('focus_sessions');
    } else {
      _box = await Hive.openBox<FocusSession>('focus_sessions');
    }
  }

  int _getDurationForType(TimerType type, SettingsState settings) {
    switch (type) {
      case TimerType.pomodoro:
        return settings.focusDuration * 60;
      case TimerType.shortBreak:
        return settings.shortBreakDuration * 60;
      case TimerType.longBreak:
        return settings.longBreakDuration * 60;
    }
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _ticker?.cancel();
        _handleTimerComplete();
      }
    });
  }

  void _startTicker() {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
           if (state.remainingSeconds > 0) {
            state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
          } else {
            _ticker?.cancel();
            _handleTimerComplete();
          }
      });
  }
  
  void _handleTimerComplete() {
      _triggerAlarm(); 

      final settings = ref.read(settingsNotifierProvider);
      
      // Auto-Switch Logic
      if (state.type == TimerType.pomodoro) {
        _saveFocusSession();

        final sessionsDone = state.roundCount + 1;
        final autoStart = settings.autoStartBreaks;

        TimerType nextType;
        int nextDuration;

        // Check for Long Break (Every 4th session)
        if (sessionsDone % 4 == 0) {
           nextType = TimerType.longBreak;
           nextDuration = settings.longBreakDuration * 60;
        } else {
           nextType = TimerType.shortBreak;
           nextDuration = settings.shortBreakDuration * 60;
        }

        state = state.copyWith(
          status: autoStart ? TimerStatus.running : TimerStatus.initial,
          type: nextType,
          initialDuration: nextDuration,
          remainingSeconds: nextDuration,
          roundCount: sessionsDone,
        );
        
        if (autoStart) {
           _startTicker();
        }

      } else if (state.type == TimerType.longBreak) {
        // Long Break Finished -> STOP CYCLE
        final nextType = TimerType.pomodoro;
        final nextDuration = settings.focusDuration * 60; 
        
        state = state.copyWith(
           status: TimerStatus.initial, // FORCE STOP
           type: nextType,
           initialDuration: nextDuration,
           remainingSeconds: nextDuration,
           roundCount: 0, // Reset Cycle
         );
         
      } else {
        // Short Break Finished -> Back to Focus
        final nextType = TimerType.pomodoro;
        final nextDuration = settings.focusDuration * 60;
        final autoResume = settings.autoStartBreaks; 
        
        state = state.copyWith(
           status: autoResume ? TimerStatus.running : TimerStatus.initial,
           type: nextType,
           initialDuration: nextDuration,
           remainingSeconds: nextDuration,
           // roundCount persists
         );
         
         if (autoResume) {
            _startTicker();
         }
      }
  }

  void _triggerAlarm() {
      final settings = ref.read(settingsNotifierProvider);
      if (settings.isAlarmEnabled) {
          ref.read(soundNotifierProvider.notifier).playAlarm();
      }
  }
  
  void _playAlarm() {
     _triggerAlarm();
  }

  Future<void> _saveFocusSession() async {
     try {
       // Use actual duration from state
       final durationMin = state.initialDuration ~/ 60;
       
       final session = FocusSession(
         completionTime: DateTime.now(),
         durationInMinutes: durationMin > 0 ? durationMin : 1, 
         taskName: state.currentTaskName,
       );
       
       debugPrint('DEBUG: Attempting to save session: Task=${session.taskName}, Duration=${session.durationInMinutes}m');
       await _box?.add(session);
       debugPrint('DEBUG: Session Saved Successfully to Hive!');
     } catch (e) {
       debugPrint('DEBUG: Failed to save session: $e');
     }
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void stop() {
    _ticker?.cancel();
    state = state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: state.initialDuration,
    );
  }

  void setType(TimerType type) {
    _ticker?.cancel();
    final settings = ref.read(settingsNotifierProvider);
    final duration = _getDurationForType(type, settings);
    
    state = state.copyWith(
      type: type,
      initialDuration: duration,
      remainingSeconds: duration,
      status: TimerStatus.initial,
    );
  }

  void setTask(String taskName) {
    state = state.copyWith(currentTaskName: taskName);
  }
  
  void clearTask() {
    state = state.copyWith(currentTaskName: null);
  }
}
