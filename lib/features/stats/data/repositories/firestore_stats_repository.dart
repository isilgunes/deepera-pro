import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class FirestoreStatsRepository implements StatsRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreStatsRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  String? get _userId => _authRepository.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _sessionsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('sessions');
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    final col = _sessionsCollection;
    if (col == null) return;
    await col.add(session.toMap());
  }

  @override
  Future<List<FocusSession>> getSessions() async {
    final col = _sessionsCollection;
    if (col == null) return [];
    
    final snapshot = await col.orderBy('completionTime', descending: true).get();
    return snapshot.docs.map((doc) => FocusSession.fromMap(doc.data())).toList();
  }

  @override
  Stream<List<FocusSession>> watchSessions() {
    final col = _sessionsCollection;
    if (col == null) return Stream.value([]);

    return col
        .orderBy('completionTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FocusSession.fromMap(doc.data())).toList());
  }
}
