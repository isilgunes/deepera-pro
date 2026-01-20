import '../entities/focus_session.dart';

abstract class StatsRepository {
  Future<void> saveSession(FocusSession session);
  Future<List<FocusSession>> getSessions();
  Stream<List<FocusSession>> watchSessions();
}
