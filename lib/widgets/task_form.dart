// lib/widgets/task_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final String empresaId;

  const TaskForm({
    super.key,
    this.task,
    required this.empresaId,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _asignadoAController = TextEditingController();
  
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 1));
  TaskPriority _prioridad = TaskPriority.media;
  TaskStatus _estado = TaskStatus.pendiente;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeWithTask(widget.task!);
    }
  }

  void _initializeWithTask(Task task) {
    _tituloController.text = task.titulo;
    _descripcionController.text = task.descripcion;
    _asignadoAController.text = task.asignadoA;
    _fechaVencimiento = task.fechaVencimiento;
    _prioridad = task.prioridad;
    _estado = task.estado;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _asignadoAController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaVencimiento),
      );
      
      if (time != null) {
        setState(() {
          _fechaVencimiento = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      
      final task = Task(
        id: widget.task?.id ?? '',
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaVencimiento: _fechaVencimiento,
        prioridad: _prioridad,
        asignadoA: _asignadoAController.text.trim(),
        estado: _estado,
        fechaCreacion: widget.task?.fechaCreacion ?? DateTime.now(),
        fechaCompletada: widget.task?.fechaCompletada,
      );

      bool success;
      if (widget.task != null) {
        success = await provider.updateTask(task, widget.empresaId);
      } else {
        success = await provider.addTask(task, widget.empresaId);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task != null 
                ? 'Tarea actualizada exitosamente'
                : 'Tarea creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Editar Tarea' : 'Nueva Tarea'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _handleSubmit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _asignadoAController,
              decoration: const InputDecoration(
                labelText: 'Asignado a',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de vencimiento'),
              subtitle: Text(
                '${_fechaVencimiento.day}/${_fechaVencimiento.month}/${_fechaVencimiento.year} '
                '${_fechaVencimiento.hour.toString().padLeft(2, '0')}:'
                '${_fechaVencimiento.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _prioridad = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (widget.task != null) ...[
              DropdownButtonFormField<TaskStatus>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: Text(widget.task != null ? 'Actualizar' : 'Crear Tarea'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.baja:
        return 'Baja';
      case TaskPriority.media:
        return 'Media';
      case TaskPriority.alta:
        return 'Alta';
      case TaskPriority.critica:
        return 'Crítica';
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProgreso:
        return 'En Progreso';
      case TaskStatus.completada:
        return 'Completada';
      case TaskStatus.cancelada:
        return 'Cancelada';
    }
  }
}