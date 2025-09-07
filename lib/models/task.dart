import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus {
  pendiente,
  enProgreso,
  completada,
  cancelada
}

enum TaskPriority {
  baja,
  media,
  alta,
  critica
}

class Task {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaVencimiento;
  final TaskPriority prioridad;
  final String asignadoA;
  final TaskStatus estado;
  final DateTime fechaCreacion;
  final DateTime? fechaCompletada;

  Task({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.prioridad,
    required this.asignadoA,
    required this.estado,
    required this.fechaCreacion,
    this.fechaCompletada,
  });

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaVencimiento: (map['fechaVencimiento'] as Timestamp).toDate(),
      prioridad: TaskPriority.values.firstWhere(
        (p) => p.toString().split('.').last == map['prioridad'],
        orElse: () => TaskPriority.media,
      ),
      asignadoA: map['asignadoA'] ?? '',
      estado: TaskStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['estado'],
        orElse: () => TaskStatus.pendiente,
      ),
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      fechaCompletada: map['fechaCompletada'] != null 
          ? (map['fechaCompletada'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'prioridad': prioridad.toString().split('.').last,
      'asignadoA': asignadoA,
      'estado': estado.toString().split('.').last,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaCompletada': fechaCompletada != null 
          ? Timestamp.fromDate(fechaCompletada!)
          : null,
    };
  }

  Task copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaVencimiento,
    TaskPriority? prioridad,
    String? asignadoA,
    TaskStatus? estado,
    DateTime? fechaCreacion,
    DateTime? fechaCompletada,
  }) {
    return Task(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      prioridad: prioridad ?? this.prioridad,
      asignadoA: asignadoA ?? this.asignadoA,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
    );
  }
}