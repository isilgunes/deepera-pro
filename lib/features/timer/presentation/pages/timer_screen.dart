import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/timer_entity.dart';
import '../providers/timer_notifier.dart';
import '../../../settings/presentation/managers/theme_manager.dart';
import '../../../audio/presentation/widgets/sound_picker_sheet.dart';
import '../../../../features/audio/presentation/providers/sound_notifier.dart';
import '../widgets/round_indicator.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  // Manual lifecycle observation moved to ForegroundService. 
  // We only need to check alarm on resume if desired, but foreground service keeps running so alarm should fire from there?
  // Actually, UI alarm should be handled by listening to state. 
  // Let's keep it simple: Remove the observer. The service handles the background timer.
  
  // Note: If we need "Stop Alarm on App Open", we can do it in init or build by checking state,
  // but let's stick to the plan: "Remove any logic... that pauses or saves timer".

  Future<void> _handleModeChange(TimerType newType) async {
    final state = ref.read(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);
    final theme = Theme.of(context);
    final contentColor = theme.iconTheme.color ?? Colors.black;

    // Prevent switching to same type
    if (state.type == newType) return;

    if (state.status == TimerStatus.running) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Timer is running',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          content: Text(
            'Do you want to stop the current timer and switch modes?',
            style: GoogleFonts.outfit(color: contentColor),
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context, false), // Cancel
               child: Text('Cancel', style: GoogleFonts.outfit(color: contentColor.withOpacity(0.7))),
             ),
             TextButton(
               onPressed: () => Navigator.pop(context, true), // Confirm
               child: Text('Switch', style: GoogleFonts.outfit(color: contentColor, fontWeight: FontWeight.bold)),
             ),
          ],
        ),
      );

      if (shouldSwitch == true) {
        notifier.stopTimer();
        notifier.setType(newType);
      }
    } else {
      notifier.setType(newType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);
    final soundState = ref.watch(soundNotifierProvider);
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
                
                  // HIDE Headphones if Alarm is Playing (Replace with STOP button)
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
            // Focus Target Display
            Consumer(
              builder: (context, ref, child) {
                final currentTitle = ref.watch(timerNotifierProvider.select((s) => s.currentTaskTitle));
                
                if (currentTitle != null && currentTitle.isNotEmpty) {
                  return Column(
                    children: [
                      Text("Focusing on:", style: GoogleFonts.outfit(color: contentColor.withOpacity(0.6), fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(
                        currentTitle,
                        style: GoogleFonts.outfit(
                           color: contentColor,
                           fontSize: 22, 
                           fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
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
                  _handleModeChange(newSelection.first); // New Safe Logic
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
                 // Add explicit Alarm Stop button if alarm is ringing? 
                 // We added it to top left instead.
                 
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
                    onPressed: notifier.stopTimer,
                    backgroundColor: contentColor.withOpacity(0.2),
                    foregroundColor: contentColor,
                    elevation: 0,
                    child: const Icon(Icons.stop),
                  ),
                ]
              ],
            ),
            
            // Explicit Alarm Stop Button (Visible Only When Ringing)
            if (timerState.isAlarmPlaying) ...[
               const SizedBox(height: 20), // Spacing
               SizedBox(
                 width: 200,
                 height: 50,
                 child: ElevatedButton.icon(
                   onPressed: () => notifier.stopAlarm(), // Call stopAlarm explicitly
                   icon: const Icon(Icons.notifications_off, color: Colors.white),
                   label: Text(
                     "ALARMI DURDUR 🔕", 
                     style: GoogleFonts.outfit(
                       color: Colors.white, 
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                     ),
                   ),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.red,
                     elevation: 5,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                   ),
                 ),
               ),
            ],
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

