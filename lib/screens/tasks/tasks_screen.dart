// lib/screens/tasks/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import 'task_detail_screen.dart';
import '../../widgets/task_form.dart';

enum TaskSort { none, fechaLimite, prioridad, estado }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Filtros (null = "todas")
  TaskPriority? _priorityFilter;
  TaskSection? _sectionFilter;
  bool? _completedFilter; // null = todos, false = pendientes, true = completados

  // Ordenamiento
  TaskSort _sortBy = TaskSort.none;
  bool _sortAscending = true;

  // Search (opcional, aumenta productividad)
  String _search = '';

  // Helpers para UI
  final EdgeInsets _chipPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4);

  @override
  Widget build(BuildContext context) {
    // Usamos `watch` para que la pantalla se actualice cuando cambien las tareas
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.tasks;

    // Aplicamos filtros y búsqueda a una lista local (evita mutar la original)
    final List<Task> tasks = _applyFiltersAndSort(List<Task>.from(allTasks));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            tooltip: 'Limpiar filtros',
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllFilters,
          ),
          IconButton(
            tooltip: 'Añadir tarea',
            icon: const Icon(Icons.add),
            onPressed: () => _openTaskForm(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                // Row: Search + small info
                Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 8),
                    _buildSummaryChip(provider),
                  ],
                ),
                const SizedBox(height: 8),
                // Row: Filter chips + sorting chips
                Row(
                  children: [
                    Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildFilterChips())),
                    const SizedBox(width: 8),
                    _buildSortChipsRow(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: tasks.isEmpty
          ? Center(
              child: _emptyState(provider),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 84),
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                final t = tasks[i];
                return _buildTaskTile(context, t, provider);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por título o descripción...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
    );
  }

  Widget _buildSummaryChip(TaskProvider provider) {
    final total = provider.tasks.length;
    final pending = provider.tasks.where((t) => !t.completada).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$pending pendientes / $total total'),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        // Priorities (single-select)
        ...TaskPriority.values.map((p) {
          final selected = _priorityFilter == p;
          return Padding(
            padding: _chipPadding,
            child: FilterChip(
              label: Text(p.name.toUpperCase()),
              selected: selected,
              onSelected: (v) => setState(() => _priorityFilter = v ? p : null),
              selectedColor: _priorityColor(p).withOpacity(0.18),
              side: BorderSide(color: _priorityColor(p).withOpacity(0.5)),
            ),
          );
        }).toList(),

        const SizedBox(width: 6),

        // Sections (single-select)
        ...TaskSection.values.map((s) {
          final selected = _sectionFilter == s;
          return Padding(
            padding: _chipPadding,
            child: FilterChip(
              label: Text(s.name.toUpperCase()),
              selected: selected,
              onSelected: (v) => setState(() => _sectionFilter = v ? s : null),
              selectedColor: Colors.blueGrey.shade100,
            ),
          );
        }).toList(),

        const SizedBox(width: 6),

        // Estado
        Padding(
          padding: _chipPadding,
          child: ChoiceChip(
            label: const Text('Pendientes'),
            selected: _completedFilter == false,
            onSelected: (v) => setState(() => _completedFilter = v ? false : null),
          ),
        ),
        Padding(
          padding: _chipPadding,
          child: ChoiceChip(
            label: const Text('Completadas'),
            selected: _completedFilter == true,
            onSelected: (v) => setState(() => _completedFilter = v ? true : null),
          ),
        ),
      ],
    );
  }

  Widget _buildSortChipsRow() {
    return Row(
      children: [
        _sortChip(label: 'Fecha', value: TaskSort.fechaLimite),
        const SizedBox(width: 6),
        _sortChip(label: 'Prioridad', value: TaskSort.prioridad),
        const SizedBox(width: 6),
        _sortChip(label: 'Estado', value: TaskSort.estado),
      ],
    );
  }

  Widget _sortChip({required String label, required TaskSort value}) {
    final selected = _sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          if (_sortBy == value) {
            // alterna asc/desc
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w600)),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
            ]
          ],
        ),
      ),
    );
  }

  // Construye la lista final aplicando filtros, búsqueda y orden
  List<Task> _applyFiltersAndSort(List<Task> src) {
    // Filtro por prioridad / sección / completada / búsqueda
    final filtered = src.where((t) {
      if (_priorityFilter != null && t.prioridad != _priorityFilter) return false;
      if (_sectionFilter != null && t.seccion != _sectionFilter) return false;
      if (_completedFilter != null && t.completada != _completedFilter) return false;
      if (_search.isNotEmpty) {
        final hay = t.titulo.toLowerCase().contains(_search) ||
            (t.descripcion?.toLowerCase().contains(_search) ?? false);
        if (!hay) return false;
      }
      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case TaskSort.fechaLimite:
        filtered.sort((a, b) {
          final aNull = a.fechaLimite == null;
          final bNull = b.fechaLimite == null;
          if (aNull && bNull) return 0;
          if (aNull) return _sortAscending ? 1 : -1;
          if (bNull) return _sortAscending ? -1 : 1;
          return _sortAscending
              ? a.fechaLimite!.compareTo(b.fechaLimite!)
              : b.fechaLimite!.compareTo(a.fechaLimite!);
        });
        break;
      case TaskSort.prioridad:
        // urgente(index 0) -> baja(index 3). Queremos urgente primero when ascending.
        filtered.sort((a, b) => _sortAscending
            ? a.prioridad.index.compareTo(b.prioridad.index)
            : b.prioridad.index.compareTo(a.prioridad.index));
        break;
      case TaskSort.estado:
        // pendientes (completada=false) primero when ascending
        filtered.sort((a, b) {
          final av = a.completada ? 1 : 0;
          final bv = b.completada ? 1 : 0;
          return _sortAscending ? av.compareTo(bv) : bv.compareTo(av);
        });
        break;
      case TaskSort.none:
        // default: ordenar por prioridad + fecha + creación (similar a provider._sort)
        filtered.sort((a, b) {
          final pa = a.prioridad.index;
          final pb = b.prioridad.index;
          if (pa != pb) return pa.compareTo(pb);
          if (a.fechaLimite != null && b.fechaLimite != null) {
            final cmp = a.fechaLimite!.compareTo(b.fechaLimite!);
            if (cmp != 0) return cmp;
          } else if (a.fechaLimite == null && b.fechaLimite != null) {
            return 1;
          } else if (a.fechaLimite != null && b.fechaLimite == null) {
            return -1;
          }
          return b.fechaCreacion.compareTo(a.fechaCreacion);
        });
        break;
    }

    return filtered;
  }

  Widget _buildTaskTile(BuildContext context, Task t, TaskProvider provider) {
    final color = _priorityColor(t.prioridad);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: t.completada,
              onChanged: (v) => provider.toggleTask(t.id),
            ),
          ],
        ),
        title: Text(
          t.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: t.completada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.descripcion?.isNotEmpty == true) Text(t.descripcion!, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _smallChip(t.prioridad.name.toUpperCase(), color.withOpacity(0.12), color),
                _smallChip(t.seccion.name.toUpperCase(), Colors.blueGrey.shade100, Colors.blueGrey),
                _smallChip(t.fechaLimite != null ? 'Vence: ${_fmtDate(t.fechaLimite!)}' : 'Sin límite', Colors.grey.shade100, Colors.grey),
                if (!t.completada && t.fechaLimite != null && t.fechaLimite!.isBefore(DateTime.now()))
                  _smallChip('VENCIDA', Colors.red.shade100, Colors.red),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (choice) => _onMenuChoice(choice, context, t, provider),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'detail', child: Text('Ver detalle')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  void _onMenuChoice(String choice, BuildContext ctx, Task t, TaskProvider provider) {
    if (choice == 'edit') {
      showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) => TaskForm(existingTask: t),
      );
    } else if (choice == 'detail') {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t)));
    } else if (choice == 'delete') {
      _confirmDelete(ctx, t, provider);
    }
  }

  void _confirmDelete(BuildContext ctx, Task t, TaskProvider provider) {
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Eliminar esta tarea definitivamente?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              provider.deleteTask(t.id);
              Navigator.of(dctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgente:
        return Colors.red.shade600;
      case TaskPriority.alta:
        return Colors.orange.shade700;
      case TaskPriority.media:
        return Colors.amber.shade700;
      case TaskPriority.baja:
        return Colors.green.shade700;
    }
  }

  Widget _smallChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _emptyState(TaskProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.task_alt, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        const Text('No hay tareas registradas', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Crear primera tarea'),
          onPressed: () => _openTaskForm(context),
        ),
      ],
    );
  }

  void _openTaskForm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => const TaskForm(),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _priorityFilter = null;
      _sectionFilter = null;
      _completedFilter = null;
      _search = '';
      _sortBy = TaskSort.none;
      _sortAscending = true;
    });
  }
}
