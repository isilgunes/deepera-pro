import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task_entity.dart';

class TaskRepository {
  final Box<TaskEntity> _box;

  TaskRepository(this._box);

  List<TaskEntity> getTasks() {
    return _box.values.toList();
  }

  Future<void> addTask(TaskEntity task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
