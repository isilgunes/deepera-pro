import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/focus_session.dart';
import '../providers/stats_provider.dart';
import '../../../../features/settings/presentation/managers/theme_manager.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeProvider);
    final eventsAsync = ref.watch(statsEventsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent, // Or use theme scaffold background
      appBar: AppBar(
        title: Text('History', style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: textColor))),
        data: (events) {
          final selectedEvents = _selectedDay != null ? events[_selectedDay] ?? [] : [];

          return Column(
            children: [
              // Calendar View
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                   color: isDark ? Colors.grey[900] : Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                   ]
                ),
                child: TableCalendar<FocusSession>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  eventLoader: (day) {
                    return events[day] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: themeColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: GoogleFonts.outfit(color: textColor),
                    weekendTextStyle: GoogleFonts.outfit(color: textColor.withOpacity(0.6)),
                  ),
                  headerStyle: HeaderStyle(
                     titleCentered: true,
                     formatButtonVisible: false,
                     titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                     leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                     rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Session List
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No sessions on this day.',
                          style: GoogleFonts.outfit(color: textColor.withOpacity(0.5), fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final session = selectedEvents[index];
                          // Simple check, FocusSession doesn't have 'type' yet in our refactor?
                          // Let's assume all saved are Focus type for now or add Type to FocusSession
                          const isWork = true; 

                          return Card(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isWork ? themeColor : Colors.green).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isWork ? Icons.timer : Icons.coffee,
                                  color: isWork ? themeColor : Colors.green,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                session.taskName ?? 'No Task',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textColor),
                              ),
                              subtitle: Text(
                                '${DateFormat('HH:mm').format(session.completionTime)} • ${session.durationInMinutes} min',
                                style: GoogleFonts.outfit(color: textColor.withOpacity(0.6)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
