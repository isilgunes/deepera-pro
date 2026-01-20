import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_notifier.dart';
import '../managers/theme_manager.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Draft State
  late int _tempFocusDuration;
  late int _tempShortBreak;
  late int _tempLongBreak;
  late bool _tempAutoStart;
  late bool _tempAlarmEnabled;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    _tempFocusDuration = settings.focusDuration;
    _tempShortBreak = settings.shortBreakDuration;
    _tempLongBreak = settings.longBreakDuration;
    _tempAutoStart = settings.autoStartBreaks;
    _tempAlarmEnabled = settings.isAlarmEnabled;
  }

  void _saveSettings() {
    ref.read(settingsNotifierProvider.notifier).saveSettings(
          focusDuration: _tempFocusDuration,
          shortBreakDuration: _tempShortBreak,
          longBreakDuration: _tempLongBreak,
          autoStartBreaks: _tempAutoStart,
          isAlarmEnabled: _tempAlarmEnabled,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings Saved',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Card & Text Colors
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final contentColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: themeColor, // Colored background as requested
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Let themeColor show through
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('TIMER CONFIG'),
                
                // Focus Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                     _buildInputRow(
                        title: 'Focus Duration',
                        valueLabel: '$_tempFocusDuration min',
                        contentColor: contentColor,
                        onTap: () => _showDurationPicker(
                          context: context,
                          title: 'Focus Duration',
                          min: 5,
                          max: 90,
                          initialValue: _tempFocusDuration,
                          onChanged: (val) => setState(() => _tempFocusDuration = val),
                          step: 5,
                        ),
                     ),
                  ]
                ),

                // Breaks Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                    _buildInputRow(
                      title: 'Short Break',
                      valueLabel: '$_tempShortBreak min',
                      contentColor: contentColor,
                      onTap: () => _showDurationPicker(
                        context: context,
                        title: 'Short Break',
                        min: 1,
                        max: 30,
                        initialValue: _tempShortBreak,
                        onChanged: (val) => setState(() => _tempShortBreak = val),
                      ),
                    ),
                    Divider(height: 32, color: contentColor.withOpacity(0.1)),
                    _buildInputRow(
                      title: 'Long Break',
                      valueLabel: '$_tempLongBreak min',
                      contentColor: contentColor,
                      onTap: () => _showDurationPicker(
                        context: context,
                        title: 'Long Break',
                        min: 5,
                        max: 60,
                        initialValue: _tempLongBreak,
                        onChanged: (val) => setState(() => _tempLongBreak = val),
                        step: 5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('AUTOMATION'),
                
                // Automation Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-start Breaks',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start break automatically',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: contentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _tempAutoStart,
                          activeColor: themeColor,
                          inactiveTrackColor: Colors.grey.shade300,
                          inactiveThumbColor: Colors.grey.shade700,
                          onChanged: (val) => setState(() => _tempAutoStart = val),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Alarm Sound Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sound Alarm',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Play sound when timer ends',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: contentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _tempAlarmEnabled,
                          activeColor: themeColor,
                          inactiveTrackColor: Colors.grey.shade300,
                          inactiveThumbColor: Colors.grey.shade700,
                          onChanged: (val) => setState(() => _tempAlarmEnabled = val),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('APPEARANCE'),
                
                // Theme Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                         showModalBottomSheet(
                           context: context,
                           backgroundColor: Colors.transparent,
                           builder: (context) => const ColorPickerSheet(),
                         );
                      },
                      title: Text(
                        'Accents Color',
                         style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                         ),
                      ),
                      trailing: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: contentColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('ACCOUNT'),

                // Account Card
                _buildCard(
                  cardColor: cardColor,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        ref.read(authRepositoryProvider).currentUser?.email ?? 'User',
                         style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                         ),
                      ),
                      subtitle: Text(
                        'Tap to Sign Out',
                         style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: contentColor.withOpacity(0.7),
                         ),
                      ),
                      trailing: Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: cardColor,
                            title: Text(
                              'Sign Out',
                              style: GoogleFonts.outfit(color: contentColor, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              'Are you sure you want to sign out?',
                              style: GoogleFonts.outfit(color: contentColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.outfit(color: contentColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context); // Close dialog
                                  await ref.read(authRepositoryProvider).signOut();
                                },
                                child: Text(
                                  'Sign Out',
                                  style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Save Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardColor, // White/Black
                    foregroundColor: themeColor, // Text is Theme Color
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'SAVE SETTINGS',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w900, // Bold
          color: Colors.white, // White on flavored background
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Color cardColor, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputRow({
    required String title,
    required String valueLabel,
    required Color contentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: contentColor, width: 2), // Visible border
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              valueLabel,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: contentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker({
    required BuildContext context,
    required String title,
    required int min,
    required int max,
    required int initialValue,
    required ValueChanged<int> onChanged,
    int step = 1,
  }) {
    final values = <int>[];
    for (int i = min; i <= max; i += step) values.add(i);
    int selectedValue = initialValue;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(
                    initialItem: values.indexOf(initialValue) != -1 ? values.indexOf(initialValue) : 0,
                  ),
                  onSelectedItemChanged: (index) {
                    selectedValue = values[index];
                    onChanged(selectedValue);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: values.length,
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          '${values[index]} min',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            color: Colors.black, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
