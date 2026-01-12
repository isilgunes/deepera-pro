import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/task_notifier.dart';
import '../../domain/entities/task_entity.dart';
import '../../../settings/presentation/managers/theme_manager.dart';
import '../../../../core/app_providers.dart';
import '../../../../features/timer/presentation/providers/timer_notifier.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allTasks = ref.watch(taskNotifierProvider);
    final themeColor = ref.watch(themeProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);
    
    // Sort and Filter logic
    final tasksForDate = allTasks.where((task) {
      final taskDate = task.date ?? DateTime.now();
      return isSameDay(taskDate, selectedDate);
    }).toList();

    // Split for sorting
    final timedTasks = tasksForDate.where((t) => t.scheduledTime != null).toList();
    final untimedTasks = tasksForDate.where((t) => t.scheduledTime == null).toList();

    // 1. Sort Timed by time
    timedTasks.sort((a, b) {
       // Simple string comparison for "HH:mm" works for sorting
       return (a.scheduledTime ?? "").compareTo(b.scheduledTime ?? "");
    });

    // 2. Sort Untimed by sortIndex
    untimedTasks.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    // Combine
    final displayList = [...timedTasks, ...untimedTasks];

    // Determine content color (Smart Contrast) to match Calendar
    final contentColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Planner', style: GoogleFonts.outfit(color: contentColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
            // Theme button moved to FAB row as requested, but keeping here as backup? 
            // User asked: "Add Theme Button to Tasks Screen" (previously) -> Done.
            // New request: "Bottom Right: Row of FABs (Theme + Add)".
            // So I should remove it from here ideally, or keep both? 
            // "Add an action icon... When clicked... (Note: Do NOT use a FloatingActionButton...)" -> previous request.
            // "Layout Refinement: Ensure the "Theme Picker" FAB and "Add Plan" FAB are positioned at the bottom right" -> NEW request.
            // I will follow the NEW request and remove it from AppBar to avoid clutter, or maybe keep it?
            // Let's remove sort of, or stick to the latest instruction which explicitly asks for FAB position.
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            color: Colors.transparent,
            margin: const EdgeInsets.only(bottom: 8),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                  ref.read(selectedDateProvider.notifier).state = selectedDay;
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) setState(() => _calendarFormat = format);
              },
              onHeaderTapped: (focusedDay) async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: focusedDay,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: themeColor, 
                          onPrimary: Colors.white, 
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(foregroundColor: themeColor),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                   ref.read(selectedDateProvider.notifier).state = picked;
                }
              },
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  return Center(
                    child: InkWell(
                      onTap: () {
                         // Trigger custom logic or just fallback to onHeaderTapped logic if exposed
                         // Since inkwell traps tap, we must trigger picker here manualy
                         _showDatePicker(context, day, themeColor); 
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: contentColor.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat.yMMMM().format(day),
                          style: GoogleFonts.outfit(
                            color: contentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: contentColor, // Smart contrast
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false, // We customize header so we can hide default navs if title is center, or keep them?
                // Visual Cue request: "Clickable Header... Wrapper... Date Text".
                // Default arrows are fine to keep for month nav.
                // But headerTitleBuilder replaces the title part.
                rightChevronVisible: false, 
                // Wait, if arrows are hidden, user can only jump? No, default behavior is nice.
                // Let's keep arrows visible but custom builder only affects title.
                // Actually, builder replaces the whole header widget usually? No, title builder replaces title.
              ),
              // We need to re-add arrows if we want them, or checking docs...
              // headerTitleBuilder replaces the central text.
              // So we should verify if arrows disappear. They shouldn't if we don't hide them.
              // Let's explicitly keep chevrons but style them.
              calendarStyle: CalendarStyle(
                defaultTextStyle: GoogleFonts.outfit(color: contentColor),
                weekendTextStyle: GoogleFonts.outfit(color: contentColor),
                outsideTextStyle: GoogleFonts.outfit(color: contentColor.withOpacity(0.3)),
                
                selectedDecoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                
                todayDecoration: BoxDecoration(
                  color: themeColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.outfit(
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                ),
                
                // transform markerDecoration -> custom markerBuilder used above
                markersMaxCount: 1, 
              ),
              eventLoader: (day) {
                return allTasks.where((task) {
                   final taskDate = task.date ?? DateTime.now();
                   return isSameDay(taskDate, day);
                }).toList();
              },
            ),
          ),
          
          // Task List (Reorderable)
          Expanded(
            child: displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No plans for this day.',
                          style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Bottom padding for FABs
                    itemCount: displayList.length,
                    onReorder: (oldIndex, newIndex) {
                       if (oldIndex < newIndex) newIndex -= 1;
                       
                       // Logic: Only allow reordering UNTIMED tasks within UNTIMED section
                       final item = displayList[oldIndex];
                       
                       // 1. Cannot move Timed tasks (they are sorted by time)
                       if (item.scheduledTime != null) {
                         // Optional: Show message "Cannot reorder timed tasks"
                         return; 
                       }
                       
                       // 2. Calculate indices relative to Untimed list
                       final timedCount = timedTasks.length;
                       
                       // Cannot move INTO timed section
                       if (newIndex < timedCount) return;
                       
                       // Perform reorder on Untimed List
                       final localOld = oldIndex - timedCount;
                       final localNew = newIndex - timedCount;
                       
                       final itemToMove = untimedTasks.removeAt(localOld);
                       untimedTasks.insert(localNew, itemToMove);
                       
                       // Persist new order
                       notifier.reorderTasks(untimedTasks);
                    },
                    itemBuilder: (context, index) {
                      final task = displayList[index];
                      // Different visual for Timed vs Untimed?
                      // Timed tasks are not draggable (conceptually), but ListView makes them so.
                      // We effectively disable the logic, but visual drag handle remains unless we customize.
                      
                      return Dismissible(
                        key: Key(task.id),
                        background: Container(
                          decoration: BoxDecoration(
                             color: Colors.redAccent.withOpacity(0.8),
                             borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          notifier.deleteTask(task.id);
                        },
                        child: Card(
                          key: ValueKey(task.id), // Important for ReorderableListView
                          elevation: 0,
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Checkbox(
                              value: task.isCompleted,
                              activeColor: themeColor,
                              shape: const CircleBorder(),
                              onChanged: (_) => notifier.toggleTask(task.id),
                            ),
                            title: Text(
                              task.title,
                              style: GoogleFonts.outfit(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                color: task.isCompleted ? Colors.grey : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: task.scheduledTime != null
                                ? Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(task.scheduledTime!, style: GoogleFonts.outfit(color: Colors.grey)),
                                      if (task.hasReminder) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.notifications_active, size: 14, color: themeColor),
                                      ]
                                    ],
                                  )
                                : null,
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                       // Play Button
                                       IconButton(
                                         icon: Icon(Icons.play_circle_outline, color: themeColor, size: 28),
                                         onPressed: () {
                                            ref.read(timerNotifierProvider.notifier).setTask(task.title);
                                            ref.read(bottomNavIndexProvider.notifier).state = 0; // Switch to Timer
                                         },
                                       ),
                                       // Delete Button
                                       IconButton(
                                         icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                         onPressed: () {
                                             // Confirm? or just delete. Dismissible also deletes.
                                             notifier.deleteTask(task.id); 
                                         },
                                       ),
                                   if (task.estimatedPomodoros > 1)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                                        child: Text('${task.estimatedPomodoros}'),
                                      )
                                ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Compact Theme Picker FAB
           FloatingActionButton(
             heroTag: 'theme_fab',
             mini: true,
             onPressed: () {
               showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const ColorPickerSheet(),
              );
             },
             backgroundColor: Colors.white,
             foregroundColor: Colors.black87,
             child: const Icon(Icons.palette_outlined),
           ),
           const SizedBox(width: 16),
           // Add Task FAB
           FloatingActionButton.extended(
            heroTag: 'add_task_fab',
            onPressed: () => _showAddTaskSheet(context, ref, selectedDate),
            icon: Icon(Icons.add, color: _getFabContentColor(themeColor)),
            label: Text('Add Plan', style: TextStyle(color: _getFabContentColor(themeColor))),
            backgroundColor: themeColor,
          ),
        ],
      ),
    );
  }
  
  Color _getFabContentColor(Color themeColor) {
      if (themeColor == Colors.white) return Colors.black;
      if (themeColor.computeLuminance() > 0.7) return Colors.black;
      return Colors.white;
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref, DateTime initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddTaskSheet(initialDate: initialDate),
    );
  }

  Future<void> _showDatePicker(BuildContext context, DateTime focus, Color themeColor) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: focus,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeColor, 
              onPrimary: Colors.white, 
              onSurface: Colors.black, // Dark text on light background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: themeColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
        ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const _AddTaskSheet({required this.initialDate});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Plan',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: Colors.black87), // Force visible text
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Date Picker
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM d').format(_selectedDate)),
                style: TextButton.styleFrom(foregroundColor: Colors.black87),
              ),
              // Time Picker
              TextButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                      // Auto-enable reminder if time is set
                      _hasReminder = true; 
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(_selectedTime?.format(context) ?? 'Time'),
                style: TextButton.styleFrom(
                  foregroundColor: _selectedTime != null ? themeColor : Colors.grey,
                ),
              ),
            ],
          ),
          if (_selectedTime != null)
            SwitchListTile(
              title: Text('Remind me 5 mins before', style: GoogleFonts.outfit(color: Colors.black87)),
              value: _hasReminder,
              activeColor: themeColor,
              onChanged: (val) => setState(() => _hasReminder = val),
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final scheduledTimeString = _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : null;
                  
                  ref.read(taskNotifierProvider.notifier).addTask(
                    title: _titleController.text,
                    date: _selectedDate,
                    scheduledTime: scheduledTimeString,
                    hasReminder: _hasReminder,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Plan'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
