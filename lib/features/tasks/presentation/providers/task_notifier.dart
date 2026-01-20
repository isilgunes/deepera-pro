import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';

// Interface
import '../../domain/repositories/task_repository_interface.dart';
// Implementations
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/firestore_task_repository.dart';

import '../../domain/entities/task_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'task_notifier.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  if (user != null) {
    return FirestoreTaskRepository(
      authRepository: ref.read(authRepositoryProvider),
    );
  } else {
    final box = Hive.box<TaskEntity>('tasks');
    return HiveTaskRepository(box);
  }
}

@riverpod
class TaskNotifier extends _$TaskNotifier {
  late final TaskRepository _repository;

  @override
  List<TaskEntity> build() {
    _repository = ref.watch(taskRepositoryProvider); // Use watch to rebuild on auth change
    
    // Subscribe to the stream from the repository
    _repository.watchTasks().listen((tasks) {
       final sorted = List<TaskEntity>.from(tasks)
        ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
       state = sorted;
    });

    return _repository.getTasks(); // Initial state (might be empty for Firestore)
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
    
    // Force Schedule Notification
    // We assume the user wants a reminder if time is set, or if explicitly asked? 
    // The previous logic was `if (hasReminder && scheduledTime != null)`.
    // User request says: "Force the call... Add a debug SnackBar/print".
    // I will keep the check but make it robust.
    
    if (scheduledTime != null) { // Even if hasReminder is false? User said "Force". 
       // I'll stick to logic: if scheduledTime exists, we schedule a "start" reminder maybe?
       // Or stick to `hasReminder`. Let's assume `hasReminder` is true for testing or check UI.
       // User said: "Force the call". I will call it regardless of `hasReminder` for now to be safe as per "Force Integration"? 
       // Or better: ensure UI sets `hasReminder = true`.
       // Let's rely on the arguments passed.
       
       if (hasReminder || true) { // FORCE for testing as requested? "Force the call". Ok, I'll force it if time exists.
          final timeParts = scheduledTime.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final datePart = date;
          final taskTime = DateTime(
            datePart.year, datePart.month, datePart.day, hour, minute
          );
          
          await ref.read(notificationServiceProvider).scheduleTaskReminder(taskTime, title);
          print("DEBUG: Notification scheduled for $taskTime");
       }
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
    final taskTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    ref.read(notificationServiceProvider).scheduleTaskReminder(taskTime, task.title);
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
