import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The entry point must be top-level
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TimerTaskHandler());
}

class TimerTaskHandler extends TaskHandler {
  int _remainingSeconds = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Load initial state if available
    final savedSeconds = await FlutterForegroundTask.getData<int>(key: 'remaining');
    _remainingSeconds = savedSeconds ?? 0;
    print('Foreground Service Started: $_remainingSeconds');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      
       // Calculate explicit time
      final minutes = _remainingSeconds ~/ 60;
      final seconds = _remainingSeconds % 60;
      final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      FlutterForegroundTask.updateService(
        notificationTitle: 'Aktif Sayaç',
        notificationText: '⏳ $timeStr Kaldı',
      );
      
      FlutterForegroundTask.sendDataToMain(_remainingSeconds);
    } else {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Süre Doldu!',
        notificationText: 'Mola vakti geldi.',
      );
      FlutterForegroundTask.sendDataToMain('DONE');
      FlutterForegroundTask.stopService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('Foreground Service Destroyed');
  }
}

class ForegroundServiceManager {
  // Initialization helper
  static Future<void> init() async {
    if (kIsWeb) return;
    
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pomodoro_timer_v9_fixed',
        channelName: 'Aktif Sayaç',
        channelDescription: 'Arka plan sayacı',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
        // FIX: Removed 'iconData' as it is deprecated or moved in v9.2.0 depending on usage.
        // Using default icon behavior (launcher icon)
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions( // FIX: Removed 'const' 
        eventAction: ForegroundTaskEventAction.repeat(1000), // FIX: Correct usage
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService(int durationSeconds) async {
    if (kIsWeb) return;

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Zamanlayıcı Başladı',
        notificationText: 'Hazırlanıyor...',
        callback: startCallback,
      );
    }
    await FlutterForegroundTask.saveData(key: 'remaining', value: durationSeconds);
  }
  
  static Future<void> stopService() async {
    if (kIsWeb) return;
    await FlutterForegroundTask.stopService();
  }
}
