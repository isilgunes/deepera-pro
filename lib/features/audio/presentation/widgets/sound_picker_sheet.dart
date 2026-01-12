import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/sound_notifier.dart';
import '../../domain/entities/sound_track.dart';

class SoundPickerSheet extends ConsumerWidget {
  const SoundPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soundNotifierProvider);
    final notifier = ref.read(soundNotifierProvider.notifier);
    
    return Container(
      height: 550, // Increased height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FOCUS SOUNDS',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                ),
              ),
              if (state.isPlaying)
                TextButton.icon(
                  onPressed: () => notifier.stop(),
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  label: Text('Stop', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Now Playing Indicator
          if (state.isPlaying && state.currentSound != null)
             Container(
               width: double.infinity,
               margin: const EdgeInsets.only(bottom: 16),
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               decoration: BoxDecoration(
                 color: Colors.black,
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Row(
                 children: [
                   const Icon(Icons.graphic_eq, color: Colors.white, size: 20),
                   const SizedBox(width: 12),
                   Text(
                     'Now Playing: ${state.currentSound!.name}',
                     style: GoogleFonts.outfit(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ],
               ),
             ),

          // Shuffle Card
          _buildShuffleCard(state, notifier),
          
          const SizedBox(height: 16),
          
          // Grid of Sounds
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: notifier.tracks.length,
              itemBuilder: (context, index) {
                final track = notifier.tracks[index];
                // In shuffle mode, we might want to highlight the current playing track too?
                // But shuffle card is already highlighted. 
                // Let's just highlight specific card if IsLoop or if it happens to be the current random one.
                // User requirement: "Random Mix Feedback... update currentSound... ensures UI shows exactly which sound is active".
                // So yes, we should highlight the card even in shuffle mode if we want to show it's playing?
                // OR just rely on "Now Playing" text. 
                // Let's highlight the card if it matches currentSound AND isPlaying.
                final isSelected = state.currentSound == track && state.isPlaying;
                return _buildSoundCard(track, isSelected, notifier);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Volume Control
          Row(
            children: [
              const Icon(Icons.volume_mute, color: Colors.grey),
              Expanded(
                child: Slider(
                  value: state.volume,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey[200],
                  onChanged: (val) => notifier.setVolume(val),
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.black),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShuffleCard(SoundState state, SoundNotifier notifier) {
    // Only highlight if Shuffle Mode is explicitly active logic
    final isShuffleActive = state.isShuffleMode && state.isPlaying;
    return InkWell(
      onTap: () => notifier.playShuffle(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isShuffleActive ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isShuffleActive ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shuffle,
              color: isShuffleActive ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              'Random Mix',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isShuffleActive ? Colors.white : Colors.black,
              ),
            ),
            if (isShuffleActive) ...[
               const SizedBox(width: 8),
               const Icon(Icons.equalizer, color: Colors.white, size: 16),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(SoundTrack track, bool isSelected, SoundNotifier notifier) {
    return InkWell(
      onTap: () => notifier.playLoop(track),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              track.icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              track.name,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
