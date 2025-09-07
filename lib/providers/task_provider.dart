import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Obtener todas las tareas
  Future<void> loadTasks(String empresaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('tasks')
          .orderBy('fechaCreacion', descending: true)
          .get();

      _tasks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Task.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar nueva tarea
  Future<bool> addTask(Task task, String empresaId) async {
    try {
      final docRef = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('tasks')
          .add(task.toMap());

      // Crear la tarea con el ID generado
      final newTask = Task(
        id: docRef.id,
        titulo: task.titulo,
        descripcion: task.descripcion,
        fechaVencimiento: task.fechaVencimiento,
        prioridad: task.prioridad,
        asignadoA: task.asignadoA,
        estado: task.estado,
        fechaCreacion: task.fechaCreacion,
      );

      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  // Actualizar tarea existente
  Future<bool> updateTask(Task task, String empresaId) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Alternar completado de tarea
  Future<bool> toggleTaskCompletion(String taskId, String empresaId) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return false;

      final task = _tasks[taskIndex];
      final newStatus = task.estado == TaskStatus.completada 
          ? TaskStatus.pendiente 
          : TaskStatus.completada;

      final updatedTask = Task(
        id: task.id,
        titulo: task.titulo,
        descripcion: task.descripcion,
        fechaVencimiento: task.fechaVencimiento,
        prioridad: task.prioridad,
        asignadoA: task.asignadoA,
        estado: newStatus,
        fechaCreacion: task.fechaCreacion,
        fechaCompletada: newStatus == TaskStatus.completada ? DateTime.now() : null,
      );

      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('tasks')
          .doc(taskId)
          .update(updatedTask.toMap());

      _tasks[taskIndex] = updatedTask;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error toggling task completion: $e');
      return false;
    }
  }

  // Eliminar tarea
  Future<bool> deleteTask(String taskId, String empresaId) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Obtener tareas por estado
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.estado == status).toList();
  }

  // Obtener tareas por prioridad
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.prioridad == priority).toList();
  }

  // Obtener tareas vencidas
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) => 
      task.fechaVencimiento.isBefore(now) && 
      task.estado != TaskStatus.completada
    ).toList();
  }
}