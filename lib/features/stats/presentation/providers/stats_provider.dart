import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
// Interface
import '../../domain/repositories/stats_repository.dart';
// Implementations
import '../../data/repositories/firestore_stats_repository.dart';
import '../../data/repositories/drift_stats_repository.dart';
import '../../data/repositories/in_memory_stats_repository.dart'; 
// Models
import '../../domain/entities/focus_session.dart';
// Providers
import '../../../../core/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';


final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  
  if (user != null) {
    return FirestoreStatsRepository(
      authRepository: ref.read(authRepositoryProvider),
    );
  }
  
  if (kIsWeb) {
    return InMemoryStatsRepository();
  }
  
  // Mobile/Desktop Native DB
  final db = ref.watch(databaseProvider);
  return DriftStatsRepository(db);
});

// Provider to hold the events (grouped by day)
final statsEventsProvider = StreamProvider<LinkedHashMap<DateTime, List<FocusSession>>>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  
  return repository.watchSessions().map((sessions) {
      final grouped = LinkedHashMap<DateTime, List<FocusSession>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(_groupSessions(sessions));
      return grouped;
  });
});

// Helper: Normalize date (remove time)
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

Map<DateTime, List<FocusSession>> _groupSessions(List<FocusSession> sessions) {
  final data = <DateTime, List<FocusSession>>{};
  
  for (var session in sessions) {
    // Normalize to midnight
    final date = DateTime(session.completionTime.year, session.completionTime.month, session.completionTime.day);
    if (data[date] == null) {
      data[date] = [];
    }
    data[date]!.add(session);
  }
  return data;
}
