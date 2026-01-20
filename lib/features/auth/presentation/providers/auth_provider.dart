import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// A simple notifier to handle login actions if needed, though StreamProvider is efficient for state
// We can use this to expose methods like signIn calls easily
final authControllerProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryProvider);
});
