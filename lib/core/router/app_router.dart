import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../widgets/scaffold_with_navbar.dart';
import '../../features/timer/presentation/pages/timer_screen.dart';
import '../../features/tasks/presentation/pages/tasks_screen.dart';
import '../../features/stats/presentation/pages/stats_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasUser = authState.valueOrNull != null;
      final isLogin = state.uri.toString() == '/login';

      if (isLoading) return null; // Wait for auth check

      if (!hasUser) {
        return isLogin ? null : '/login';
      }

      if (isLogin) {
        return '/'; // Already logged in
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ScaffoldWithNavBar(),
        routes: [
           GoRoute(
            path: 'timer',
            redirect: (_, __) => '/',
          ),
           GoRoute(
            path: 'tasks',
            redirect: (_, __) => '/',
          ),
           GoRoute(
            path: 'stats',
             redirect: (_, __) => '/',
          ),
           GoRoute(
            path: 'settings',
             redirect: (_, __) => '/',
          ),
        ]
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
