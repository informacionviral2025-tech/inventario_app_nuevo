// lib/screens/tasks/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_form_restructured.dart';

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
                builder: (_) => TaskFormRestructured(task: task, empresaId: ''),
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
            Text(task.descripcion.isNotEmpty ? task.descripcion : "Sin descripción"),
            const Divider(height: 32),

            Text(
              "Prioridad",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.prioridad.name.toUpperCase()),
            const Divider(height: 32),

            Text(
              "Zona",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.zonaTexto),
            const Divider(height: 32),

            if (task.zona == TaskZone.taller && task.vehiculoMaquinaId != null) ...[
              Text(
                "Vehículo/Máquina",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(task.vehiculoMaquinaId!),
              const Divider(height: 32),
            ],

            Text(
              "Responsables",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.responsables.isNotEmpty ? "${task.responsables.length} responsables asignados" : "Sin responsables asignados"),
            const Divider(height: 32),

            if (task.tipoRepeticion != TaskRepeatType.noRepetir) ...[
              Text(
                "Repetición",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(task.tipoRepeticionTexto),
              const Divider(height: 32),
            ],

            Text(
              "Fecha límite",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text("${task.fechaVencimiento.day}/${task.fechaVencimiento.month}/${task.fechaVencimiento.year}"),
            const Divider(height: 32),

            Text(
              "Estado",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(task.estado == TaskStatus.completada ? "Completada ✅" : "Pendiente ⏳"),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(
                task.estado == TaskStatus.completada ? Icons.undo : Icons.check_circle,
              ),
              label: Text(
                task.estado == TaskStatus.completada ? "Marcar como pendiente" : "Marcar como completada",
              ),
              onPressed: () {
                provider.toggleTaskCompletion(task.id, '');
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
              provider.deleteTask(task.id, '');
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
