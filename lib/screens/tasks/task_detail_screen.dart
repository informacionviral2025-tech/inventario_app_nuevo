// lib/screens/tasks/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_form.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(task.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => TaskForm(existingTask: task),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, provider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Descripción",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.descripcion ?? "Sin descripción"),
            const Divider(height: 32),

            Text(
              "Prioridad",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.prioridad.name.toUpperCase()),
            const Divider(height: 32),

            Text(
              "Sección",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.seccion.name.toUpperCase()),
            const Divider(height: 32),

            Text(
              "Fecha límite",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.fechaLimite != null
                ? "${task.fechaLimite!.day}/${task.fechaLimite!.month}/${task.fechaLimite!.year}"
                : "No asignada"),
            const Divider(height: 32),

            Text(
              "Estado",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.completada ? "Completada ✅" : "Pendiente ⏳"),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(
                task.completada ? Icons.undo : Icons.check_circle,
              ),
              label: Text(
                task.completada ? "Marcar como pendiente" : "Marcar como completada",
              ),
              onPressed: () {
                provider.toggleTaskCompletion(task.id);
                Navigator.of(context).pop(); // Volvemos tras actualizar
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar tarea"),
        content: const Text("¿Seguro que quieres eliminar esta tarea?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text("Eliminar"),
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
