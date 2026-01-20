import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart'; // This will be generated

// Define the table
class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // When did it finish?
  IntColumn get durationSeconds => integer()(); // How long (usually 1500)
  TextColumn get taskTitle => text().nullable()(); // What was the task?
  TextColumn get type => text()(); // 'Focus', 'Short Break', 'Long Break'
}

@DriftDatabase(tables: [PomodoroSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 1;

  // Insert a new session
  Future<int> insertSession(PomodoroSessionsCompanion session) {
    return into(pomodoroSessions).insert(session);
  }

  // Get all sessions (for stats)
  Future<List<PomodoroSession>> getAllSessions() {
    return select(pomodoroSessions).get();
  }
}
