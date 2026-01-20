import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

// Create a single instance of the database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
