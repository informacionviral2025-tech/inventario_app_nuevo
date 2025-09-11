// lib/widgets/tasks_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TasksStatsWidget extends StatelessWidget {
  final String empresaId;

  const TasksStatsWidget({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.tasks;
        final pendingTasks = provider.getTasksByStatus(TaskStatus.pendiente);
        final inProgressTasks = provider.getTasksByStatus(TaskStatus.enProgreso);
        final completedTasks = provider.getTasksByStatus(TaskStatus.completada);
        final overdueTasks = provider.getOverdueTasks();

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task_alt, color: Colors.teal),
                    const SizedBox(width: 8),
                    const Text(
                      'Gestión de Tareas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.loadTasks(empresaId),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Estadísticas principales
                _buildStatsGrid(tasks, pendingTasks, inProgressTasks, completedTasks, overdueTasks),
                const SizedBox(height: 16),
                
                // Tareas vencidas (si las hay)
                if (overdueTasks.isNotEmpty) ...[
                  _buildOverdueSection(overdueTasks),
                  const SizedBox(height: 16),
                ],
                
                // Acceso rápido
                _buildQuickActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    List<Task> allTasks,
    List<Task> pendingTasks,
    List<Task> inProgressTasks,
    List<Task> completedTasks,
    List<Task> overdueTasks,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(
          'Total',
          '${allTasks.length}',
          Icons.list_alt,
          Colors.blue,
        ),
        _buildStatCard(
          'Pendientes',
          '${pendingTasks.length}',
          Icons.pending,
          Colors.orange,
        ),
        _buildStatCard(
          'En Progreso',
          '${inProgressTasks.length}',
          Icons.play_circle,
          Colors.blue,
        ),
        _buildStatCard(
          'Completadas',
          '${completedTasks.length}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Vencidas',
          '${overdueTasks.length}',
          Icons.warning,
          Colors.red,
        ),
        _buildStatCard(
          'Progreso',
          '${allTasks.isNotEmpty ? ((completedTasks.length / allTasks.length) * 100).round() : 0}%',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueSection(List<Task> overdueTasks) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(
                'Tareas Vencidas (${overdueTasks.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...overdueTasks.take(3).map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${task.titulo}',
              style: const TextStyle(fontSize: 12),
            ),
          )),
          if (overdueTasks.length > 3)
            Text(
              '... y ${overdueTasks.length - 3} más',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/tasks',
                  arguments: {'empresaId': empresaId},
                ),
                icon: const Icon(Icons.list),
                label: const Text('Ver Todas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implementar creación rápida de tarea
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función en desarrollo')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Tarea'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



