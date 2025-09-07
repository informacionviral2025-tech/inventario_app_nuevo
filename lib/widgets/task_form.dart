// lib/widgets/task_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskForm extends StatefulWidget {
  final Task? existingTask;

  const TaskForm({super.key, this.existingTask});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();

  late String _titulo;
  String? _descripcion;
  TaskPriority _prioridad = TaskPriority.media;
  TaskSection _seccion = TaskSection.almacen;
  DateTime? _fechaLimite;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titulo = task.titulo;
      _descripcion = task.descripcion;
      _prioridad = task.prioridad;
      _seccion = task.seccion;
      _fechaLimite = task.fechaLimite;
    } else {
      _titulo = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              initialValue: _titulo,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "El título es obligatorio";
                }
                return null;
              },
              onSaved: (value) => _titulo = value!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _descripcion,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _descripcion = value?.trim(),
            ),
            const SizedBox(height: 12),

            // Prioridad
            DropdownButtonFormField<TaskPriority>(
              value: _prioridad,
              decoration: const InputDecoration(
                labelText: "Prioridad",
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _prioridad = val!),
            ),
            const SizedBox(height: 12),

            // Sección
            DropdownButtonFormField<TaskSection>(
              value: _seccion,
              decoration: const InputDecoration(
                labelText: "Sección",
                border: OutlineInputBorder(),
              ),
              items: TaskSection.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _seccion = val!),
            ),
            const SizedBox(height: 12),

            // Fecha límite
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _fechaLimite == null
                    ? "Sin fecha límite"
                    : "Fecha límite: ${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(widget.existingTask == null ? "Crear tarea" : "Actualizar tarea"),
              onPressed: _saveForm,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _fechaLimite = picked;
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.existingTask == null) {
      // Nueva tarea
      provider.addTask(
        titulo: _titulo,
        descripcion: _descripcion,
        prioridad: _prioridad,
        seccion: _seccion,
        fechaLimite: _fechaLimite,
      );
    } else {
      // Actualizar existente
      provider.updateTask(
        widget.existingTask!.id,
        titulo: _titulo,
        descripcion: _descripcion,
        prioridad: _prioridad,
        seccion: _seccion,
        fechaLimite: _fechaLimite,
      );
    }

    Navigator.of(context).pop();
  }
}
