import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      _tasks = Task.decodeList(tasksJson);
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', Task.encodeList(_tasks));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].completada = !_tasks[index].completada;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  /// Devuelve las tareas filtradas por sección
  List<Task> tasksBySection(TaskSection section) {
    return _tasks.where((t) => t.seccion == section).toList();
  }

  /// Calcula cuánto tiempo queda hasta la fecha límite
  String timeLeft(Task t) {
    if (t.fechaLimite == null) return "Sin límite";
    final diff = t.fechaLimite!.difference(DateTime.now());
    if (diff.isNegative) return "Vencida";
    if (diff.inDays > 0) return "${diff.inDays} días restantes";
    if (diff.inHours > 0) return "${diff.inHours} horas restantes";
    return "${diff.inMinutes} min restantes";
  }
}
