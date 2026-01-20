import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  List<TaskEntity> getTasks();
  Future<void> reorderTasks(List<TaskEntity> tasks);
  Stream<List<TaskEntity>> watchTasks();
}
