import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Define distinct nice-looking colors
const List<Color> appThemeColors = [
  Color(0xFFE57373), // Red (Default)
  Color(0xFF81C784), // Green
  Color(0xFF64B5F6), // Blue
  Color(0xFFFFB74D), // Orange
  Color(0xFFBA68C8), // Purple
  Color(0xFF4DB6AC), // Teal
  Color(0xFFFFD54F), // Amber
  Color(0xFFA1887F), // Brown
  Color(0xFF90A4AE), // Blue Grey
  Color(0xFFF06292), // Pink
  Colors.black,      // Black
  Color(0xFF424242), // Dark Grey
  Colors.white,      // White
];

// 2. StateProvider for selected color
final themeProvider = StateProvider<Color>((ref) => appThemeColors[0]);

// 3. ColorPickerSheet Widget
class ColorPickerSheet extends ConsumerWidget {
  const ColorPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // More items per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: appThemeColors.length,
            itemBuilder: (context, index) {
              final color = appThemeColors[index];
              final isSelected = ref.read(themeProvider) == color;
              
              return InkWell(
                onTap: () {
                  ref.read(themeProvider.notifier).state = color;
                  // Don't close immediately, let user experiment? Or close?
                  // Providing immediate feedback is better, maybe no close logic needed here if they want to try multiple
                  // But user requested "Mini Sheet", implying quick selection.
                  // Let's keep it open or close? Standard behavior is usually one tap close.
                  // But "Compact" might mean "less intrusive".
                  // Let's just update state.
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isSelected) 
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
