import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository_interface.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreTaskRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  String? get _userId => _authRepository.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _tasksCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final col = _tasksCollection;
    if (col == null) return; // Or throw error
    await col.doc(task.id).set(task.toMap());
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final col = _tasksCollection;
    if (col == null) return;
    await col.doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    final col = _tasksCollection;
    if (col == null) return;
    await col.doc(id).delete();
  }

  @override
  List<TaskEntity> getTasks() {
    // Firestore is async, but this method was sync in Hive.
    // Ideally we switch to Stream or Future based architecture.
    // For now, return empty list and let Stream/Future providers handle data.
    return []; 
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    final col = _tasksCollection;
    if (col == null) return Stream.value([]);
    
    return col
        .orderBy('sortIndex')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskEntity.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    final col = _tasksCollection;
    if (col == null) return;

    final batch = _firestore.batch();

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final newIndex = i; // simple reorder logic
      // We need to update sortIndex in the task object first? 
      // Or just update the DB with new index.
      // Let's assume the passed list is already in desired order
      // but we need to persist "sortIndex" field.
      
      // Ideally we update the entity first, but here we just update field
      final docRef = col.doc(task.id);
      batch.update(docRef, {'sortIndex': newIndex});
    }

    await batch.commit();
  }
}
