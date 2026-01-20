import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:hive_flutter/hive_flutter.dart';
import 'features/tasks/domain/entities/task_entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/notification_service.dart';
import 'features/settings/presentation/managers/theme_manager.dart';
import 'features/stats/domain/entities/focus_session.dart';
import 'core/router/app_router.dart';
import 'core/services/foreground_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(TaskEntityAdapter());
  Hive.registerAdapter(FocusSessionAdapter());
  await Hive.openBox<TaskEntity>('tasks');
  await Hive.openBox<FocusSession>('focus_sessions');
  await Hive.openBox('settings'); // Open settings box
  
  tz.initializeTimeZones(); // Initialize Timezones
  
  // Platform specific services (Mobile Only)
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
       final notificationService = NotificationService();
       await notificationService.init();
       await notificationService.requestPermissions();
       await notificationService.scheduleDailyQuote(); 
    
      // Init Foreground Service
      await ForegroundServiceManager.init();
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeProvider);
    final isDark = themeColor.computeLuminance() < 0.5;
    final contentColor = isDark ? Colors.white : Colors.black;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Deepera Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: themeColor,
        primaryColor: themeColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        iconTheme: IconThemeData(color: contentColor),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: contentColor,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.outfit(color: contentColor),
          bodyLarge: GoogleFonts.outfit(color: contentColor),
          titleLarge: GoogleFonts.outfit(color: contentColor),
          displayLarge: GoogleFonts.outfit(color: contentColor),
          // Ensure other styles also adapt if used
          headlineMedium: GoogleFonts.outfit(color: contentColor),
        ),
      ),
      routerConfig: router,
    );
  }
}
