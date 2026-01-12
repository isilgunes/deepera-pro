import 'package:flutter/material.dart';

class RoundIndicator extends StatelessWidget {
  final int completedRounds;
  final int totalRounds;
  final Color activeColor;
  final Color inactiveColor;

  const RoundIndicator({
    super.key,
    required this.completedRounds,
    this.totalRounds = 4,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalRounds, (index) {
        // Index 0 represents the 1st round.
        // If completedRounds is 1, it means we finished 1 round, so index 0 should be filled?
        // Let's interpret "visual logic":
        // "If roundCount is 1, the bottom box is filled."
        // We are stacking vertically. Usually round progress goes bottom-up or top-down.
        // Let's do Bottom-Up as requested ("bottom box is filled").
        // So index 0 (top) is the last round (4th).
        // Index 3 (bottom) is the first round (1st).
        
        final roundNumber = totalRounds - index; 
        final isCompleted = completedRounds >= roundNumber;

        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? activeColor : inactiveColor.withOpacity(0.3),
            border: Border.all(
              color: isCompleted ? activeColor : inactiveColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}
