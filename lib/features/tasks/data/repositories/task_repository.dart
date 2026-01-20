import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository_interface.dart'; // We need to create this interface first

class HiveTaskRepository implements TaskRepository {
  final Box<TaskEntity> _box;

  HiveTaskRepository(this._box);

  List<TaskEntity> getTasks() {
    return _box.values.toList();
  }

  Future<void> addTask(TaskEntity task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    // For Hive, assuming we just save them back with new sort indices?
    // Or just putting them triggers list update if we sort by index.
    for (var task in tasks) {
      await _box.put(task.id, task);
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return _box.watch().map((event) {
      return _box.values.toList();
    });
  }
}
