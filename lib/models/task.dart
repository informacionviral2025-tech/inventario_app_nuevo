import 'dart:convert';
import 'package:flutter/material.dart';

enum TaskPriority { urgente, alta, media, baja }
enum TaskSection { taller, almacen, obra }

class Task {
  final String id;
  String titulo;
  String? descripcion;
  TaskPriority prioridad;
  TaskSection seccion;
  DateTime fechaCreacion;
  DateTime? fechaLimite;
  bool completada;

  Task({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.prioridad,
    required this.seccion,
    required this.fechaCreacion,
    this.fechaLimite,
    this.completada = false,
  });

  // ======= PERSISTENCIA =======
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      prioridad: TaskPriority.values[json['prioridad'] as int],
      seccion: TaskSection.values[json['seccion'] as int],
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaLimite: json['fechaLimite'] != null ? DateTime.parse(json['fechaLimite'] as String) : null,
      completada: json['completada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'prioridad': prioridad.index,
        'seccion': seccion.index,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaLimite': fechaLimite?.toIso8601String(),
        'completada': completada,
      };

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String source) {
    final list = (jsonDecode(source) as List).cast<Map<String, dynamic>>();
    return list.map((m) => Task.fromJson(m)).toList();
  }

  // ======= PROPIEDADES CALCULADAS =======
  Duration? get tiempoRestante =>
      fechaLimite != null ? fechaLimite!.difference(DateTime.now()) : null;

  String get tiempoRestanteTexto {
    if (fechaLimite == null) return 'Sin fecha límite';
    final diff = tiempoRestante!;
    if (diff.isNegative) return '⏰ Vencida';
    if (diff.inHours < 24) return '⚠️ Menos de 24h';
    return '${diff.inDays} días restantes';
  }

  Color get colorPrioridad {
    switch (prioridad) {
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
