import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/settings/presentation/managers/theme_manager.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: themeColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Name
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Deepera Pro',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Focus, Track, Succeed.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 60),
              
              // Google Sign In Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(authRepositoryProvider).signInWithGoogle();
                      // Navigation handled by Router listening to stream
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Failed: $e')),
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/icon/google_logo.png', // Ensure this asset exists or use Icon(Icons.login) for now if not available
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.black), 
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Google button usually white with black text
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              // Optional: Skip for offline use (if we want to support it)
              TextButton(
                 onPressed: () {
                   // Logic to continue anonymously or offline? 
                   // For now, let's keep it required as per user request to sync.
                   // Or user can skip and use local? Let's assume strict login for sync roadmap.
                 },
                 child: Text(
                   'Offline Mode (Coming Soon)',
                   style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5)),
                 ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
