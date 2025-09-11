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

enum TaskZone {
  nave,
  almacen1,
  almacen2,
  almacen3,
  almacen4,
  almacen5,
  lavado,
  aridos,
  exteriorNave,
  taller
}

enum TaskRepeatType {
  noRepetir,
  diario,
  semanal,
  quincenal,
  mensual,
  trimestral,
  semestral,
  anual
}

class Task {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaVencimiento;
  final TaskPriority prioridad;
  final List<String> responsables; // Lista de IDs de usuarios
  final TaskZone zona;
  final String? vehiculoMaquinaId; // Solo si zona es taller
  final TaskStatus estado;
  final DateTime fechaCreacion;
  final DateTime? fechaCompletada;
  final TaskRepeatType tipoRepeticion;
  final DateTime? proximaRepeticion;

  Task({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.prioridad,
    required this.responsables,
    required this.zona,
    this.vehiculoMaquinaId,
    required this.estado,
    required this.fechaCreacion,
    this.fechaCompletada,
    this.tipoRepeticion = TaskRepeatType.noRepetir,
    this.proximaRepeticion,
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
      responsables: List<String>.from(map['responsables'] ?? []),
      zona: TaskZone.values.firstWhere(
        (z) => z.toString().split('.').last == map['zona'],
        orElse: () => TaskZone.nave,
      ),
      vehiculoMaquinaId: map['vehiculoMaquinaId'],
      estado: TaskStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['estado'],
        orElse: () => TaskStatus.pendiente,
      ),
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      fechaCompletada: map['fechaCompletada'] != null 
          ? (map['fechaCompletada'] as Timestamp).toDate()
          : null,
      tipoRepeticion: TaskRepeatType.values.firstWhere(
        (r) => r.toString().split('.').last == map['tipoRepeticion'],
        orElse: () => TaskRepeatType.noRepetir,
      ),
      proximaRepeticion: map['proximaRepeticion'] != null 
          ? (map['proximaRepeticion'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'prioridad': prioridad.toString().split('.').last,
      'responsables': responsables,
      'zona': zona.toString().split('.').last,
      'vehiculoMaquinaId': vehiculoMaquinaId,
      'estado': estado.toString().split('.').last,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaCompletada': fechaCompletada != null 
          ? Timestamp.fromDate(fechaCompletada!)
          : null,
      'tipoRepeticion': tipoRepeticion.toString().split('.').last,
      'proximaRepeticion': proximaRepeticion != null 
          ? Timestamp.fromDate(proximaRepeticion!)
          : null,
    };
  }

  Task copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaVencimiento,
    TaskPriority? prioridad,
    List<String>? responsables,
    TaskZone? zona,
    String? vehiculoMaquinaId,
    TaskStatus? estado,
    DateTime? fechaCreacion,
    DateTime? fechaCompletada,
    TaskRepeatType? tipoRepeticion,
    DateTime? proximaRepeticion,
  }) {
    return Task(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      prioridad: prioridad ?? this.prioridad,
      responsables: responsables ?? this.responsables,
      zona: zona ?? this.zona,
      vehiculoMaquinaId: vehiculoMaquinaId ?? this.vehiculoMaquinaId,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
      tipoRepeticion: tipoRepeticion ?? this.tipoRepeticion,
      proximaRepeticion: proximaRepeticion ?? this.proximaRepeticion,
    );
  }

  // Métodos helper para obtener texto legible
  String get zonaTexto {
    switch (zona) {
      case TaskZone.nave:
        return 'Nave';
      case TaskZone.almacen1:
        return 'Almacén 1';
      case TaskZone.almacen2:
        return 'Almacén 2';
      case TaskZone.almacen3:
        return 'Almacén 3';
      case TaskZone.almacen4:
        return 'Almacén 4';
      case TaskZone.almacen5:
        return 'Almacén 5';
      case TaskZone.lavado:
        return 'Lavado';
      case TaskZone.aridos:
        return 'Áridos';
      case TaskZone.exteriorNave:
        return 'Exterior Nave';
      case TaskZone.taller:
        return 'Taller';
    }
  }

  String get tipoRepeticionTexto {
    switch (tipoRepeticion) {
      case TaskRepeatType.noRepetir:
        return 'No repetir';
      case TaskRepeatType.diario:
        return 'Diario';
      case TaskRepeatType.semanal:
        return 'Semanal';
      case TaskRepeatType.quincenal:
        return 'Quincenal';
      case TaskRepeatType.mensual:
        return 'Mensual';
      case TaskRepeatType.trimestral:
        return 'Trimestral';
      case TaskRepeatType.semestral:
        return 'Semestral';
      case TaskRepeatType.anual:
        return 'Anual';
    }
  }
}