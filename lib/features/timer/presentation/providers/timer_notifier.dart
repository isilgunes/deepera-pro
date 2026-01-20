import 'dart:async';
import 'dart:isolate';
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
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/foreground_service.dart';
import '../../../../core/services/foreground_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/database/app_database.dart';
import '../../../../features/stats/presentation/providers/stats_provider.dart';
import '../../../../features/stats/domain/entities/focus_session.dart';

part 'timer_notifier.g.dart';

@riverpod
@riverpod
class TimerNotifier extends _$TimerNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Create instance
  Timer? _uiTimer; // Local timer for UI updates
  Box<FocusSession>? _box;
  ReceivePort? _receivePort;

  @override
  TimerEntity build() {
    _initHive();
    
    // Use ref.read to prevent rebuilding the entire notifier when settings change.
    final settings = ref.read(settingsNotifierProvider);
    
    // Listen for settings changes to update timer ONLY if stopped/initial
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
    
    // CRITICAL: Sync immediately on load to prevent state reset
    _initSync();

    return TimerEntity(
      type: TimerType.pomodoro,
      status: TimerStatus.initial,
      initialDuration: duration,
      remainingSeconds: duration,
      roundCount: 0,
      isAlarmPlaying: false,
    );
  }

  Future<void> _initSync() async {
    if (kIsWeb) return;
    
    // 1. Check if service is actually running
    if (await FlutterForegroundTask.isRunningService) {
      // 2. Re-connect the listener
      _receivePort = FlutterForegroundTask.receivePort;
      _receivePort?.listen((data) {
        if (data is int) {
          // Sync state with live data
          state = state.copyWith(remainingSeconds: data, status: TimerStatus.running);
        }
      });
      // 3. Prevent UI from showing "25:00" momentarily
      // We set status to running immediately if service is running
      state = state.copyWith(status: TimerStatus.running);
    }
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

  // Lifecycle Methods (Background State legacy methods kept if needed, but simplified)
  Future<void> saveBackgroundState() async {
    // Legacy support or fallback
  }

  Future<void> restoreBackgroundState() async {
      // Logic could be added here to sync from Service preference storage if needed on resume
  }

  // Sync UI with Background Service (Optional backup)
  // Sync UI with Background Service
  void _onReceiveTaskData(dynamic data) {
    if (data is int) {
      // FORCE UI update to exact second from service (No Lag)
      state = state.copyWith(
        remainingSeconds: data, 
        status: TimerStatus.running
      );
    } else if (data == 'DONE') {
      _uiTimer?.cancel();
      _handleTimerComplete();
    }
  }

  // 1. Start Timer (Hybrid: Start Service + Start Local Timer)
  void start() async {
    if (state.status == TimerStatus.running) return;

    // A. Start Foreground Service (Keep alive & Notification) - MOBILE ONLY
    if (!kIsWeb) {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.restartService();
      } else {
        await FlutterForegroundTask.startService(
          notificationTitle: 'Odaklanma Modu',
          notificationText: 'Sayaç Aktif',
          callback: startCallback, 
        );
      }
      // Save initial data 
      await FlutterForegroundTask.saveData(key: 'remaining', value: state.remainingSeconds);
    }
    
    // B. Start Local UI Timer (Guarantees UI updates)
    _startLocalTicker();

    // C. Listen to Service (DIRECT SYNC) - MOBILE ONLY
    if (!kIsWeb) {
      _receivePort = FlutterForegroundTask.receivePort;
      _receivePort?.listen((data) {
        if (data is int) {
          // DIRECT SYNC: Overwrite local state immediately.
          // This removes the drift between UI and Notification.
          state = state.copyWith(remainingSeconds: data, status: TimerStatus.running);
        } else if (data == 'DONE') {
          _uiTimer?.cancel();
          _handleTimerComplete();
        }
      });
    }

    state = state.copyWith(status: TimerStatus.running);
  }

  // 2. Local Ticker Logic
  void _startLocalTicker() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        // Time is up
        _uiTimer?.cancel();
        _handleTimerComplete();
      }
    });
  }

  Future<void> _handleTimerComplete() async {
      _uiTimer?.cancel();
      // Ensure service also stops if not already done
      await FlutterForegroundTask.stopService(); // Await ensures we are clean
      _receivePort?.close();
      _receivePort = null;

      ref.read(notificationServiceProvider).cancelTimerNotification();
      
      // 1. Play Alarm Explicitly (with robust setup)
      await _playAlarm();
      
      final settings = ref.read(settingsNotifierProvider);

      // Save Session to Database
      _saveSessionToDb();
      
      // Auto-Switch Logic
       if (state.type == TimerType.pomodoro) {
        final sessionsDone = state.roundCount + 1;
        final autoStart = settings.autoStartBreaks;

        TimerType nextType;
        int nextDuration;

        if (sessionsDone % 4 == 0) {
           nextType = TimerType.longBreak;
           nextDuration = settings.longBreakDuration * 60;
        } else {
           nextType = TimerType.shortBreak;
           nextDuration = settings.shortBreakDuration * 60;
        }

        state = state.copyWith(
          status: TimerStatus.initial, 
          type: nextType,
          initialDuration: nextDuration,
          remainingSeconds: nextDuration,
          roundCount: sessionsDone,
        );
        
        if (autoStart) start(); 

      } else if (state.type == TimerType.longBreak) {
        final nextType = TimerType.pomodoro;
        final nextDuration = settings.focusDuration * 60; 
        
        state = state.copyWith(
           status: TimerStatus.initial, 
           type: nextType,
           initialDuration: nextDuration,
           remainingSeconds: nextDuration,
           roundCount: 0, 
         );
         
      } else {
        final nextType = TimerType.pomodoro;
        final nextDuration = settings.focusDuration * 60;
        final autoResume = settings.autoStartBreaks; 
        
        state = state.copyWith(
           status: TimerStatus.initial,
           type: nextType,
           initialDuration: nextDuration,
           remainingSeconds: nextDuration,
         );
         
         if (autoResume) start(); 
      }
  }

  Future<void> _playAlarm() async {
     try {
       debugPrint('DEBUG: Attempting to play alarm');
       // Set flag BEFORE playing
       state = state.copyWith(isAlarmPlaying: true);

       await _audioPlayer.stop(); 
       await _audioPlayer.setReleaseMode(ReleaseMode.stop); 
       await _audioPlayer.setVolume(1.0); 
       await _audioPlayer.setSource(AssetSource('sounds/alarm.mp3'));
       await _audioPlayer.resume();
       debugPrint('DEBUG: Alarm playback started successfully');
     } catch (e) {
       debugPrint('DEBUG: FAILED to play alarm: $e');
        state = state.copyWith(isAlarmPlaying: false); // Revert if failed
     }
  }

  Future<void> _saveSessionToDb() async {
     try {
       // Use StatsRepository for saving (supports Cloud/Local/Web)
       final repo = ref.read(statsRepositoryProvider);
       
       final session = FocusSession(
         completionTime: DateTime.now(),
         durationInMinutes: (state.initialDuration / 60).round(),
         taskName: state.currentTaskTitle,
       );

       await repo.saveSession(session);
       debugPrint('DEBUG: Session saved via Repository: ${state.type.name}');

     } catch (e) {
       debugPrint('DEBUG: Failed to save session: $e');
     }
  }

  Future<void> pause() async {
    if (!kIsWeb) {
      await _audioPlayer.stop(); // <--- STOP SOUND
      await FlutterForegroundTask.stopService();
      _receivePort?.close();
      _receivePort = null;
    } else {
      await _audioPlayer.stop();
    }
    
    _uiTimer?.cancel();
    state = state.copyWith(status: TimerStatus.paused, isAlarmPlaying: false); // Stop sound flag
  }

  Future<void> stopAlarm() async {
    debugPrint('DEBUG: stopAlarm called - Stopping sound only');
    await _audioPlayer.stop(); 
    state = state.copyWith(isAlarmPlaying: false); // Turn off alarm flag, keep timer state
  }

  Future<void> stopTimer() async {
    debugPrint('DEBUG: stopTimer called');
    await _audioPlayer.stop(); // <--- STOP SOUND

    // 1. KILL the Background Service (Stops the notification loop & sound)
    if (!kIsWeb) {
      if (await FlutterForegroundTask.isRunningService) {
        debugPrint('DEBUG: Stopping Foreground Service...');
        await FlutterForegroundTask.stopService();
      }
       _receivePort?.close();
       _receivePort = null;
    }

    // 2. KILL the Listener (Stops UI updates)
    _uiTimer?.cancel();

    // 3. RESET UI State to Initial
    final settings = ref.read(settingsNotifierProvider);
    final newDuration = _getDurationForType(state.type, settings);

    state = state.copyWith(
      status: TimerStatus.initial,
      initialDuration: newDuration,
      remainingSeconds: newDuration,
      isAlarmPlaying: false, // Turn off alarm flag
    );
     debugPrint('DEBUG: Timer stopped and reset.');
  }

  void setType(TimerType type) {
    _uiTimer?.cancel();
    stopTimer(); // Ensure everything stops
    
    final settings = ref.read(settingsNotifierProvider);
    final duration = _getDurationForType(type, settings);
    
    state = state.copyWith(
      type: type,
      initialDuration: duration,
      remainingSeconds: duration,
      status: TimerStatus.initial,
    );
  }

  void setFocusedTask(String title) {
    state = state.copyWith(currentTaskTitle: title);
  }
  
  void clearTask() {
    state = state.copyWith(currentTaskTitle: null);
  }
}
