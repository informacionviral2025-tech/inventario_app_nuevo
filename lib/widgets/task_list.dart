// lib/widgets/task_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final TaskSection? filterSection;

  const TaskList({super.key, this.filterSection});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = filterSection == null
            ? taskProvider.tasks
            : taskProvider.tasksBySection(filterSection!);

        if (tasks.isEmpty) {
          return const Center(
            child: Text("No hay tareas"),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: task.completada,
                  onChanged: (_) {
                    taskProvider.toggleTask(task.id);
                  },
                ),
                title: Text(
                  task.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.completada
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.descripcion != null && task.descripcion!.isNotEmpty)
                      Text(task.descripcion!),
                    Text(
                      "Prioridad: ${task.prioridad.name.toUpperCase()}",
                      style: TextStyle(
                        color: _priorityColor(task.prioridad),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Sección: ${task.seccion.name}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "⏳ ${taskProvider.timeLeft(task)}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    taskProvider.deleteTask(task.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgente:
        return Colors.red;
      case TaskPriority.alta:
        return Colors.orange;
      case TaskPriority.media:
        return Colors.blue;
      case TaskPriority.baja:
        return Colors.green;
    }
  }
}
