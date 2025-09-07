import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  Color _priorityColor(TaskPriority p, BuildContext ctx) {
    switch (p) {
      case TaskPriority.urgente: return Colors.red.shade600;
      case TaskPriority.alta:    return Colors.orange.shade600;
      case TaskPriority.media:   return Colors.amber.shade700;
      case TaskPriority.baja:    return Colors.green.shade600;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgente: return 'Urgente';
      case TaskPriority.alta:    return 'Alta';
      case TaskPriority.media:   return 'Media';
      case TaskPriority.baja:    return 'Baja';
    }
  }

  String _sectionLabel(TaskSection s) {
    switch (s) {
      case TaskSection.taller:  return 'Taller';
      case TaskSection.almacen: return 'Almacén';
      case TaskSection.obra:    return 'Obra';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(task.prioridad, context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.4), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.completada,
                onChanged: (v) => onToggle?.call(v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: [
                        _Chip(label: _priorityLabel(task.prioridad), color: color),
                        _Chip(label: _sectionLabel(task.seccion), color: Colors.blueGrey),
                        if (task.fechaLimite != null)
                          _Chip(
                            label: 'Límite: ${_humanDate(task.fechaLimite!)}',
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.completada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.descripcion?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.descripcion!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          decoration: task.completada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Eliminar',
                    ),
                  const SizedBox(height: 8),
                  if (!task.completada)
                    Text(
                      _timeLeftShort(task),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: task.fechaLimite != null && task.fechaLimite!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.grey.shade800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _timeLeftShort(Task t) {
    if (t.fechaLimite == null) return '—';
    final now = DateTime.now();
    final diff = t.fechaLimite!.difference(now);
    if (diff.inSeconds <= 0) return 'Vencida';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.shade900OrThis(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Tiny extension to avoid specifying Colors.black etc.
extension on Color {
  Color shade900OrThis() {
    // Best-effort readable color (no fancy theme logic)
    return this.computeLuminance() < 0.35 ? Colors.white : Colors.black87;
  }
}
