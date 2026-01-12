import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';

part 'task_notifier.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final box = Hive.box<TaskEntity>('tasks');
  return TaskRepository(box);
}

@riverpod
class TaskNotifier extends _$TaskNotifier {
  late final TaskRepository _repository;

  @override
  List<TaskEntity> build() {
    _repository = ref.read(taskRepositoryProvider);
    return _repository.getTasks();
  }

  Future<void> addTask({
    required String title,
    required DateTime date,
    String? scheduledTime,
    bool hasReminder = false,
  }) async {
    // Determine sortIndex (append to end)
    final allTasks = _repository.getTasks();
    final maxIndex = allTasks.isNotEmpty 
        ? allTasks.map((e) => e.sortIndex).reduce((a, b) => a > b ? a : b) 
        : 0;

    final task = TaskEntity(
      id: const Uuid().v4(),
      title: title,
      date: date,
      scheduledTime: scheduledTime,
      hasReminder: hasReminder,
      sortIndex: maxIndex + 1,
    );
    await _repository.addTask(task);
    
    if (hasReminder && scheduledTime != null) {
      _scheduleReminder(task);
    }
    
    state = _repository.getTasks();
  }
  
  Future<void> reorderTasks(List<TaskEntity> reorderedList) async {
    // Update sortIndex based on new list order
    for (int i = 0; i < reorderedList.length; i++) {
      final task = reorderedList[i];
      if (task.sortIndex != i) {
        final updated = task.copyWith(sortIndex: i);
        await _repository.updateTask(updated);
      }
    }
    // Refresh state
    state = _repository.getTasks();
  }

  void _scheduleReminder(TaskEntity task) {
    if (task.scheduledTime == null) return;
    
    final timeParts = task.scheduledTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final date = task.date ?? DateTime.now();
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    ).subtract(const Duration(minutes: 5)); // 5 mins before

    if (scheduledDate.isAfter(DateTime.now())) {
      ref.read(notificationServiceProvider).scheduleNotification(
        id: task.id.hashCode,
        title: 'Upcoming Session',
        body: '${task.title} starts in 5 minutes!',
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> toggleTask(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _repository.updateTask(updatedTask);
    state = _repository.getTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    ref.read(notificationServiceProvider).cancelNotification(id.hashCode);
    state = _repository.getTasks();
  }
}
