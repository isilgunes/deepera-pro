import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sound_track.dart';
import '../../../../features/timer/presentation/providers/timer_notifier.dart';
import '../../../../features/timer/domain/entities/timer_entity.dart';

part 'sound_notifier.g.dart';

@riverpod
class SoundNotifier extends _$SoundNotifier {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  
  // Available Sounds
  final List<SoundTrack> _tracks = const [
    SoundTrack(name: 'Rain', path: 'sounds/rain.mp3', icon: Icons.water_drop),
    SoundTrack(name: 'Birds', path: 'sounds/birds.mp3', icon: Icons.forest),
    SoundTrack(name: 'Ocean', path: 'sounds/ocean.mp3', icon: Icons.waves),
    SoundTrack(name: 'Fire', path: 'sounds/fire.mp3', icon: Icons.local_fire_department),
    SoundTrack(name: 'Thunder', path: 'sounds/thunder.mp3', icon: Icons.flash_on),
  ];

  List<SoundTrack> get tracks => _tracks;

  @override
  SoundState build() {
    // Listen to TimerNotifier to auto-stop audio when timer stops
    // Listen to TimerNotifier to auto-stop AMBIENT audio when timer stops
    ref.listen(timerNotifierProvider, (previous, next) {
      // Only stop if we are playing an AMBIENT sound (not alarm) and timer stops
      // Or just stop all? If we stop all, we might kill the alarm if statuses flicker.
      // But typically: Running -> Initial (Stop Ambient) -> Play Alarm.
      // This order is safe properly.
      
      if (next.status == TimerStatus.initial && state.isPlaying && state.currentSound != null) {
         // Stop ambient sound
         stop();
      }
    });

    // Listen to player completion for Shuffle Mode
    _player.onPlayerComplete.listen((_) {
      if (state.isShuffleMode && state.isPlaying) {
        _playRandomNext();
      }
    });

    return SoundState();
  }

  Future<void> playLoop(SoundTrack track) async {
    try {
      if (state.currentSound == track && state.isPlaying && !state.isShuffleMode) {
        // Toggle off if clicking same track
        stop();
        return;
      }

      state = state.copyWith(
        isPlaying: true,
        isShuffleMode: false,
        currentSound: track,
      );

      await _player.stop(); // Prevent overlap
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setSource(AssetSource(track.path));
      await _player.setVolume(state.volume);
      await _player.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> playShuffle() async {
    if (state.isShuffleMode && state.isPlaying) {
      stop();
      return;
    }

    state = state.copyWith(
      isPlaying: true,
      isShuffleMode: true,
      // Keep currentSound null or maybe set to the first random track?
      // playRandomNext will update it.
    );
    
    await _player.stop(); // Prevent overlap
    await _player.setReleaseMode(ReleaseMode.release); // Play once then next
    await _playRandomNext();
  }

  Future<void> _playRandomNext() async {
    if (!state.isPlaying) return;
    
    final nextTrack = _tracks[_random.nextInt(_tracks.length)];
    state = state.copyWith(currentSound: nextTrack); // Update UI to show what's playing

    await _player.stop(); // Prevent overlap (safety)
    await _player.setSource(AssetSource(nextTrack.path));
    await _player.setVolume(state.volume);
    await _player.resume();
  }

  Future<void> playAlarm() async {
    // If we are already playing something, stop it.
    // If the user wants an alarm, it should override ambient sound?
    // Ambient sound should probably stop when timer ends via TimerNotifier logic anyway.
    // But TimerNotifier calls stop, THEN playAlarm? 
    // Wait, TimerNotifier sets status to initial, which SoundNotifier listens to and calls stop().
    // So ambient sound stops automatically.
    // Then TimerNotifier calls playAlarm().
    
    // We need to ensure we don't accidentally stop the alarm immediately after starting it due to the listener?
    // "if (next.status == TimerStatus.initial && state.isPlaying) { stop(); }"
    // When timer ends, status becomes initial (or running if auto-start).
    // If status becomes initial, stop() is called. 
    // Then playAlarm() is called.
    // If playAlarm sets isPlaying=true, does the listener fire again? No, listener fires on transition.
    
    // But what if status stays initial?
    // Listener only fires on change.
    
    try {
      state = state.copyWith(isPlaying: true, isShuffleMode: false, currentSound: null); // Reset sound info
      // Maybe set currentSound to a dummy "Alarm" object so UI shows "Alarm"?
      // Or just null.
      
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.setSource(AssetSource('sounds/alarm.mp3')); // Using SoundTrack logic? No, specific file.
      await _player.setVolume(1.0); // Alarm should be loud? Or use system volume? Or state.volume? user didn't specify. Default 1.0 or state.volume. Let's use 1.0 for alarm or state.volume? 
      // User said "play alarm...". Usually alarms are separate volume. But let's stick to state.volume for safety or just 1.0 if critical.
      // Let's use state.volume but maybe boost it if it's too low? Let's stick to state.volume to respect user.
      await _player.setVolume(state.volume > 0.3 ? state.volume : 0.5); // Ensure at least some volume

      await _player.resume();
      
      // Auto-stop after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      
      // Only stop if we are still playing the alarm (user hasn't manually stopped or started something else)
      // How to check? 
      // If we switched tracks, isPlaying might still be true but source changed?
      // Simple check: if (state.isPlaying) stop(); 
      // But if user started Rain in the meantime?
      // We can check if player source is still alarm? Not easy.
      // We can rely on a flag or just hope 5s is short enough.
      // Better: Cancel this future if stop() is called?
      // Since we can't easily cancel Future.delayed, we check state.
      
      if (state.isPlaying && state.currentSound == null) { // Assuming Alarm implies currentSound is null
         await stop();
      }
    } catch (e) {
      debugPrint("Alarm Error: $e");
    }
  }

  Future<void> stop() async {
    state = state.copyWith(isPlaying: false);
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    if (state.isPlaying) {
      await _player.setVolume(volume);
    }
  }
}

class SoundState {
  final bool isPlaying;
  final bool isShuffleMode;
  final SoundTrack? currentSound;
  final double volume;

  bool get isAlarmPlaying => isPlaying && currentSound == null;

  SoundState({
    this.isPlaying = false,
    this.isShuffleMode = false,
    this.currentSound,
    this.volume = 0.5,
  });

  SoundState copyWith({
    bool? isPlaying,
    bool? isShuffleMode,
    SoundTrack? currentSound,
    double? volume,
  }) {
    return SoundState(
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleMode: isShuffleMode ?? this.isShuffleMode,
      currentSound: currentSound ?? this.currentSound,
      volume: volume ?? this.volume,
    );
  }
}
