import 'package:drift/drift.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    throw UnsupportedError('Drift (SQLite) is not supported on Web in this configuration. Use InMemory or Firestore.');
  });
}
