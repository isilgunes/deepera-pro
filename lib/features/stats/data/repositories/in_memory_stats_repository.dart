import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/stats_repository.dart';

class InMemoryStatsRepository implements StatsRepository {
  final List<FocusSession> _sessions = [];

  @override
  Future<void> saveSession(FocusSession session) async {
    _sessions.add(session);
  }

  @override
  Future<List<FocusSession>> getSessions() async {
    return List.from(_sessions);
  }
  
  @override
  Stream<List<FocusSession>> watchSessions() {
    return Stream.value(List.from(_sessions));
  }
}
