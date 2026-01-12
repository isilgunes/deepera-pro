import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/focus_session.dart';
import '../../../../features/settings/presentation/managers/theme_manager.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Card Color: White in Light Mode, Dark Surface in Dark Mode
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final cardTextColor = isDark ? Colors.white : Colors.black87;
    
    // Content Color (for background Text)
    final backgroundTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    // Smart Contrast for Extreme Themes
    // If theme is too dark/bright, override for visibility
    Color effectiveColor = themeColor;
    final luminance = themeColor.computeLuminance();
    
    if (luminance < 0.1) {
       effectiveColor = Colors.white; // Force White on Black
    } else if (luminance > 0.9) {
       effectiveColor = Colors.black; // Force Black on White
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Statistics', style: GoogleFonts.outfit(color: backgroundTextColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FocusSession>('focus_sessions').listenable(),
        builder: (context, Box<FocusSession> box, _) {
          final sessions = box.values.toList();
          
          if (sessions.isEmpty) {
             return Center(
               child: Text('No stats yet. Focus!', style: GoogleFonts.outfit(color: backgroundTextColor.withOpacity(0.5))),
             );
          }

          // Calculate Summary
          final totalMinutes = sessions.fold(0, (sum, item) => sum + item.durationInMinutes);
          final totalHours = (totalMinutes / 60).toStringAsFixed(1);
          final totalSessions = sessions.length;

          // Prepare Chart Data
          // Group by day (Last 7 days)
          final today = DateTime.now();
          final startOfToday = DateTime(today.year, today.month, today.day);
          final days = List.generate(7, (index) => startOfToday.subtract(Duration(days: 6 - index))); // Mon -> Sun
          
          Map<int, double> dayMinutes = {};
          
          for (var i = 0; i < 7; i++) {
             final dayStart = days[i];
             final dayEnd = dayStart.add(const Duration(days: 1));
             
             final dailySessions = sessions.where((s) {
               return s.completionTime.isAfter(dayStart) && s.completionTime.isBefore(dayEnd);
             });
             
             final dailyMin = dailySessions.fold(0, (sum, item) => sum + item.durationInMinutes);
             dayMinutes[i] = dailyMin.toDouble();
          }

          final maxY = dayMinutes.values.reduce((a, b) => a > b ? a : b);
          final safeMaxY = maxY <= 0 ? 50.0 : maxY * 1.2;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Hours',
                        '$totalHours h',
                        cardTextColor,
                        effectiveColor, // Use smart contrast color
                        cardColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Sessions',
                        '$totalSessions',
                        cardTextColor,
                        effectiveColor, // Use smart contrast color
                        cardColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Chart Title
                Text(
                  'Focus History', 
                  style: GoogleFonts.outfit(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: backgroundTextColor
                  )
                ),
                const SizedBox(height: 12),
                
                // Chart Card
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                       alignment: BarChartAlignment.spaceAround,
                       maxY: safeMaxY,
                       barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                             getTooltipColor: (_) => effectiveColor, // Use smart contrast color
                             tooltipRoundedRadius: 8,
                             getTooltipItem: (group, groupIndex, rod, rodIndex) {
                               return BarTooltipItem(
                                 '${rod.toY.toInt()} m',
                                 TextStyle(
                                     color: luminance > 0.9 ? Colors.white : Colors.black, // Invert tooltip text too
                                     fontWeight: FontWeight.bold
                                 ),
                               );
                             }
                          )
                       ),
                       titlesData: FlTitlesData(
                         show: true,
                         bottomTitles: AxisTitles(
                           sideTitles: SideTitles(
                             showTitles: true,
                             getTitlesWidget: (value, meta) {
                               final date = days[value.toInt()];
                               return Padding(
                                 padding: const EdgeInsets.only(top: 12.0),
                                 child: Text(
                                   DateFormat.E().format(date)[0], // M, T, W...
                                   style: GoogleFonts.outfit(
                                     color: cardTextColor.withOpacity(0.6), 
                                     fontWeight: FontWeight.bold,
                                     fontSize: 14, 
                                   ),
                                 ),
                               );
                             },
                             reservedSize: 40,
                           ),
                         ),
                         leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       ),
                       gridData: const FlGridData(show: false),
                       borderData: FlBorderData(show: false),
                       barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dayMinutes[index] ?? 0,
                                color: effectiveColor, // Use smart contrast color
                                width: 20, 
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: safeMaxY, 
                                  color: Colors.transparent, 
                                ),
                              ),
                            ],
                          );
                       }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Project Breakdown Title
                Text(
                  'Project Breakdown',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: backgroundTextColor
                  )
                ),
                const SizedBox(height: 12),

                // Breakdown Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                       // Pie Chart
                       SizedBox(
                         height: 200,
                         child: PieChart(
                           PieChartData(
                             sectionsSpace: 2,
                             centerSpaceRadius: 40,
                             sections: _getSections(sessions, effectiveColor),
                           ),
                         ),
                       ),
                       const SizedBox(height: 24),
                       // Task List
                       ..._buildTaskList(sessions, backgroundTextColor),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const ColorPickerSheet(),
          );
        },
        backgroundColor: cardColor, // Match card bg (contrast against scaffold)
        child: Icon(Icons.palette_outlined, color: effectiveColor), // Use effective color
      ),
    );
  }

  List<PieChartSectionData> _getSections(List<FocusSession> sessions, Color themeColor) {
    if (sessions.isEmpty) return [];
    
    // Aggregate data
    Map<String, int> taskDuration = {};
    int total = 0;
    
    for (var s in sessions) {
      final name = s.taskName ?? 'Unspecified';
      taskDuration[name] = (taskDuration[name] ?? 0) + s.durationInMinutes;
      total += s.durationInMinutes;
    }
    
    // Sort by duration desc
    final sortedKeys = taskDuration.keys.toList()
      ..sort((a, b) => taskDuration[b]!.compareTo(taskDuration[a]!));
      
    // Generate sections
    return List.generate(sortedKeys.length, (i) {
      final key = sortedKeys[i];
      final value = taskDuration[key]!;
      final double percentage = value / total * 100;
      final isLarge = percentage > 10;
      
      // Generate color based on index or hash
      // Use themeColor as base but vary opacity or hue?
      // Simple palette:
      final colors = [
         themeColor,
         themeColor.withOpacity(0.7),
         themeColor.withOpacity(0.4),
         Colors.grey,
         Colors.blueGrey,
         Colors.teal,
         Colors.amber,
      ];
      final color = colors[i % colors.length];

      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: '${percentage.toInt()}%',
        radius: isLarge ? 60 : 50,
        titleStyle: GoogleFonts.outfit(
          fontSize: isLarge ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildTaskList(List<FocusSession> sessions, Color textColor) {
    Map<String, int> taskDuration = {};
    for (var s in sessions) {
      final name = s.taskName ?? 'Unspecified';
      taskDuration[name] = (taskDuration[name] ?? 0) + s.durationInMinutes;
    }
    
     final sortedKeys = taskDuration.keys.toList()
      ..sort((a, b) => taskDuration[b]!.compareTo(taskDuration[a]!));

    return sortedKeys.map((key) {
       final minutes = taskDuration[key]!;
       return Padding(
         padding: const EdgeInsets.symmetric(vertical: 8.0),
         child: Row(
           children: [
             Icon(Icons.circle, size: 10, color: textColor.withOpacity(0.5)),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 key, 
                 style: GoogleFonts.outfit(
                   fontSize: 16, 
                   color: textColor.withOpacity(0.8),
                   fontWeight: FontWeight.w500
                 )
               ),
             ),
             Text(
               '${minutes}m', 
               style: GoogleFonts.outfit(
                 fontSize: 16, 
                 fontWeight: FontWeight.bold, 
                 color: textColor
               )
             ),
           ],
         ),
       );
    }).toList();
  }

  Widget _buildSummaryCard(String title, String value, Color textColor, Color themeColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: GoogleFonts.outfit(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.6)
            )
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: GoogleFonts.outfit(
              fontSize: 26, 
              fontWeight: FontWeight.bold,
              color: themeColor, 
            )
          ),
        ],
      ),
    );
  }
}
