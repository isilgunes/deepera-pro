import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_notifier.dart';
import '../../timer/presentation/providers/timer_notifier.dart';
import '../../../../core/providers/nav_provider.dart';

class TaskListWidget extends ConsumerWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);
    final textController = TextEditingController();

    void showAddTaskDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Focus Task', style: GoogleFonts.outfit()),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What are you working on?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  notifier.addTask(textController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet.\nAdd one to stay focused.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Dismissible(
                    key: Key(task.id),
                    background: Container(
                      color: Colors.redAccent.withOpacity(0.8),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      notifier.deleteTask(task.id);
                    },
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: Colors.black87,
                          shape: const CircleBorder(),
                          onChanged: (_) {
                            notifier.toggleTask(task.id);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: GoogleFonts.outfit(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isCompleted ? Colors.grey : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.estimatedPomodoros > 1)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Badge(
                                  label: Text('${task.estimatedPomodoros}'),
                                  backgroundColor: Colors.grey.shade200,
                                  textColor: Colors.black,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.orangeAccent, size: 32),
                              onPressed: () {
                                // 1. Set the Task in TimerNotifier
                                ref.read(timerNotifierProvider.notifier).setFocusedTask(task.title);

                                // 2. Switch Tab to Home (Index 0)
                                ref.read(bottomNavProvider.notifier).state = 0;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
