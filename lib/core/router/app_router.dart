import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../widgets/scaffold_with_navbar.dart';
import '../../features/timer/presentation/pages/timer_screen.dart';
import '../../features/tasks/presentation/pages/tasks_screen.dart';
import '../../features/stats/presentation/pages/stats_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorTimerKey = GlobalKey<NavigatorState>(debugLabel: 'shellTimer');
final _shellNavigatorTasksKey = GlobalKey<NavigatorState>(debugLabel: 'shellTasks');
final _shellNavigatorStatsKey = GlobalKey<NavigatorState>(debugLabel: 'shellStats');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/timer',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Timer
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTimerKey,
            routes: [
              GoRoute(
                path: '/timer',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TimerScreen(),
                ),
              ),
            ],
          ),
          // Branch 2: Tasks
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTasksKey,
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksScreen(),
                ),
              ),
            ],
          ),
          // Branch 3: Stats
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStatsKey,
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: StatsScreen(),
                ),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
