import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/timer_entity.dart';
import '../providers/timer_notifier.dart';
import '../../../settings/presentation/managers/theme_manager.dart';
import '../../../audio/presentation/widgets/sound_picker_sheet.dart';
import '../widgets/round_indicator.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);
    final theme = Theme.of(context);
    final contentColor = theme.iconTheme.color ?? Colors.black;

    final progress = timerState.initialDuration == 0
        ? 0.0
        : timerState.remainingSeconds / timerState.initialDuration;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header Row (Audio & Theme)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const SoundPickerSheet(),
                      );
                    },
                    icon: Icon(Icons.headphones, color: contentColor),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ColorPickerSheet(),
                      );
                    },
                    icon: Icon(Icons.palette_outlined, color: contentColor),
                  ),
                ],
              ),
            ),
            
            const Spacer(), 

            // Focus Target Display
            if (timerState.currentTaskName != null)
              Padding(
                 padding: const EdgeInsets.only(bottom: 20),
                 child: Chip(
                   label: Text('Focusing on: ${timerState.currentTaskName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                   backgroundColor: contentColor.withOpacity(0.1),
                   deleteIcon: const Icon(Icons.close, size: 18),
                   onDeleted: notifier.clearTask,
                 ),
              ),

            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SegmentedButton<TimerType>(
                segments: const [
                  ButtonSegment(
                    value: TimerType.pomodoro,
                    label: Text('Focus'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment(
                    value: TimerType.shortBreak,
                    label: Text('Short'),
                    icon: Icon(Icons.coffee),
                  ),
                  ButtonSegment(
                    value: TimerType.longBreak,
                    label: Text('Long'),
                    icon: Icon(Icons.bed),
                  ),
                ],
                selected: {timerState.type},
                onSelectionChanged: (Set<TimerType> newSelection) {
                  notifier.setType(newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return contentColor.withOpacity(0.1);
                      }
                      return Colors.transparent;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.all(contentColor),
                  iconColor: MaterialStateProperty.all(contentColor),
                ),
              ),
            ),
            const Spacer(),
            // Circular Timer & Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const SizedBox(width: 40), // Balance space
                 Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 20,
                        backgroundColor: contentColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(timerState.remainingSeconds),
                          style: GoogleFonts.outfit(
                            fontSize: 80,
                            fontWeight: FontWeight.w200,
                            color: contentColor,
                          ),
                        ),
                        Text(
                          timerState.status == TimerStatus.paused
                              ? 'PAUSED'
                              : timerState.status == TimerStatus.running
                                  ? 'RUNNING'
                                  : 'READY',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withOpacity(0.7),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                RoundIndicator(
                  completedRounds: timerState.roundCount,
                  activeColor: contentColor,
                  inactiveColor: contentColor,
                ),
              ],
            ),
            const Spacer(),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timerState.status == TimerStatus.initial)
                   FloatingActionButton.large(
                    onPressed: notifier.start,
                    backgroundColor: contentColor,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    child: const Icon(Icons.play_arrow),
                  )
                else if (timerState.status == TimerStatus.running)
                  FloatingActionButton.large(
                    onPressed: notifier.pause,
                    backgroundColor: contentColor,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    child: const Icon(Icons.pause),
                  )
                else if (timerState.status == TimerStatus.paused)
                    FloatingActionButton.large(
                    onPressed: notifier.start,
                    backgroundColor: contentColor,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    child: const Icon(Icons.play_arrow),
                  ),
                  
                if (timerState.status != TimerStatus.initial) ...[
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: notifier.stop,
                    backgroundColor: contentColor.withOpacity(0.2),
                    foregroundColor: contentColor,
                    elevation: 0,
                    child: const Icon(Icons.stop),
                  ),
                ]
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}

