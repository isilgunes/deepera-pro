import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:pomodoro_timer/features/timer/domain/entities/timer_entity.dart';
import 'package:pomodoro_timer/features/timer/presentation/providers/timer_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is correct', () {
    final state = container.read(timerNotifierProvider);
    expect(state.status, TimerStatus.initial);
    expect(state.type, TimerType.pomodoro);
    expect(state.remainingSeconds, 25 * 60);
  });

  test('start changes status to running', () {
    final notifier = container.read(timerNotifierProvider.notifier);
    notifier.start();
    expect(container.read(timerNotifierProvider).status, TimerStatus.running);
  });

  test('pause changes status to paused', () {
    final notifier = container.read(timerNotifierProvider.notifier);
    notifier.start();
    notifier.pause();
    expect(container.read(timerNotifierProvider).status, TimerStatus.paused);
  });

  test('stop resets state', () {
    final notifier = container.read(timerNotifierProvider.notifier);
    notifier.start();
    notifier.stop();
    expect(container.read(timerNotifierProvider).status, TimerStatus.initial);
    expect(container.read(timerNotifierProvider).remainingSeconds, 25 * 60);
  });

  test('setType updates duration and type', () {
    final notifier = container.read(timerNotifierProvider.notifier);
    notifier.setType(TimerType.shortBreak);
    
    final state = container.read(timerNotifierProvider);
    expect(state.type, TimerType.shortBreak);
    expect(state.initialDuration, 5 * 60);
    expect(state.remainingSeconds, 5 * 60);
    expect(state.status, TimerStatus.initial);
  });
}
