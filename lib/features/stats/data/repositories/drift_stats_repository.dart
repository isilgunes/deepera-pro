import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/stats_repository.dart';

class DriftStatsRepository implements StatsRepository {
  final AppDatabase _db;

  DriftStatsRepository(this._db);

  @override
  Future<void> saveSession(FocusSession session) async {
    await _db.insertSession(
      PomodoroSessionsCompanion(
        date: Value(session.completionTime),
        durationSeconds: Value(session.durationInMinutes * 60),
        taskTitle: Value(session.taskName),
        type: const Value('Focus'), // Default type for now
      ),
    );
  }

  @override
  Future<List<FocusSession>> getSessions() async {
    final sessions = await _db.getAllSessions();
    // Map Drift Entity to Domain Entity
    return sessions.map((s) => FocusSession(
      completionTime: s.date,
      durationInMinutes: (s.durationSeconds / 60).round(),
      taskName: s.taskTitle,
    )).toList();
  }

  @override
  Stream<List<FocusSession>> watchSessions() {
    // Drift supports streams, but getAllSessions returns Future.
    // We can use select().watch()
    return (_db.select(_db.pomodoroSessions)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) {
      return rows.map((s) => FocusSession(
        completionTime: s.date,
        durationInMinutes: (s.durationSeconds / 60).round(),
        taskName: s.taskTitle,
      )).toList();
    });
  }
}
