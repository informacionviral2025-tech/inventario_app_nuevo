import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoVehiculo {
  coche,
  furgoneta,
  camion,
  maquinaria;

  String get displayName {
    switch (this) {
      case TipoVehiculo.coche:
        return 'Coche';
      case TipoVehiculo.furgoneta:
        return 'Furgoneta';
      case TipoVehiculo.camion:
        return 'Camión';
      case TipoVehiculo.maquinaria:
        return 'Maquinaria';
    }
  }
}

enum EstadoVehiculo {
  activo,
  inactivo,
  mantenimiento,
  reparacion;

  String get displayName {
    switch (this) {
      case EstadoVehiculo.activo:
        return 'Activo';
      case EstadoVehiculo.inactivo:
        return 'Inactivo';
      case EstadoVehiculo.mantenimiento:
        return 'Mantenimiento';
      case EstadoVehiculo.reparacion:
        return 'Reparación';
    }
  }
}

class Vehiculo {
  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final TipoVehiculo tipo;
  final EstadoVehiculo estado;
  final int kilometraje;
  final int nivelCombustible;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final String? obraAsignada;
  final String? conductorAsignado;
  final DateTime? proximoMantenimiento;
  final DateTime? fechaSeguro;
  final DateTime? fechaItv;
  final double? latitud;
  final double? longitud;
  final DateTime? ultimaUbicacion;

  Vehiculo({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.tipo,
    required this.estado,
    required this.kilometraje,
    required this.nivelCombustible,
    required this.fechaCreacion,
    required this.fechaModificacion,
    this.obraAsignada,
    this.conductorAsignado,
    this.proximoMantenimiento,
    this.fechaSeguro,
    this.fechaItv,
    this.latitud,
    this.longitud,
    this.ultimaUbicacion,
  });

  factory Vehiculo.fromMap(Map<String, dynamic> map, String id) {
    return Vehiculo(
      id: id,
      matricula: map['matricula'] ?? '',
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      tipo: TipoVehiculo.values.firstWhere(
        (t) => t.toString().split('.').last == map['tipo'],
        orElse: () => TipoVehiculo.coche,
      ),
      estado: EstadoVehiculo.values.firstWhere(
        (e) => e.toString().split('.').last == map['estado'],
        orElse: () => EstadoVehiculo.activo,
      ),
      kilometraje: map['kilometraje'] ?? 0,
      nivelCombustible: map['nivelCombustible'] ?? 100,
      fechaCreacion: map['fechaCreacion'] is Timestamp
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaModificacion: map['fechaModificacion'] is Timestamp
          ? (map['fechaModificacion'] as Timestamp).toDate()
          : DateTime.now(),
      obraAsignada: map['obraAsignada'],
      conductorAsignado: map['conductorAsignado'],
      proximoMantenimiento: map['proximoMantenimiento'] is Timestamp
          ? (map['proximoMantenimiento'] as Timestamp).toDate()
          : null,
      fechaSeguro: map['fechaSeguro'] is Timestamp
          ? (map['fechaSeguro'] as Timestamp).toDate()
          : null,
      fechaItv: map['fechaItv'] is Timestamp
          ? (map['fechaItv'] as Timestamp).toDate()
          : null,
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      ultimaUbicacion: map['ultimaUbicacion'] is Timestamp
          ? (map['ultimaUbicacion'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'tipo': tipo.toString().split('.').last,
      'estado': estado.toString().split('.').last,
      'kilometraje': kilometraje,
      'nivelCombustible': nivelCombustible,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': Timestamp.fromDate(fechaModificacion),
      'obraAsignada': obraAsignada,
      'conductorAsignado': conductorAsignado,
      'proximoMantenimiento': proximoMantenimiento != null
          ? Timestamp.fromDate(proximoMantenimiento!)
          : null,
      'fechaSeguro': fechaSeguro != null
          ? Timestamp.fromDate(fechaSeguro!)
          : null,
      'fechaItv': fechaItv != null
          ? Timestamp.fromDate(fechaItv!)
          : null,
      'latitud': latitud,
      'longitud': longitud,
      'ultimaUbicacion': ultimaUbicacion != null
          ? Timestamp.fromDate(ultimaUbicacion!)
          : null,
    };
  }

  Vehiculo copyWith({
    String? id,
    String? matricula,
    String? marca,
    String? modelo,
    TipoVehiculo? tipo,
    EstadoVehiculo? estado,
    int? kilometraje,
    int? nivelCombustible,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    String? obraAsignada,
    String? conductorAsignado,
    DateTime? proximoMantenimiento,
    DateTime? fechaSeguro,
    DateTime? fechaItv,
    double? latitud,
    double? longitud,
    DateTime? ultimaUbicacion,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      kilometraje: kilometraje ?? this.kilometraje,
      nivelCombustible: nivelCombustible ?? this.nivelCombustible,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      obraAsignada: obraAsignada ?? this.obraAsignada,
      conductorAsignado: conductorAsignado ?? this.conductorAsignado,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      fechaSeguro: fechaSeguro ?? this.fechaSeguro,
      fechaItv: fechaItv ?? this.fechaItv,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      ultimaUbicacion: ultimaUbicacion ?? this.ultimaUbicacion,
    );
  }

  // Métodos de utilidad
  bool get necesitaMantenimiento {
    if (proximoMantenimiento == null) return false;
    return proximoMantenimiento!.isBefore(DateTime.now().add(const Duration(days: 7)));
  }

  bool get seguroVencido {
    if (fechaSeguro == null) return false;
    return fechaSeguro!.isBefore(DateTime.now());
  }

  bool get itvVencida {
    if (fechaItv == null) return false;
    return fechaItv!.isBefore(DateTime.now());
  }

  bool get combustibleBajo {
    return nivelCombustible < 25;
  }

  bool get disponibleParaAsignar {
    return estado == EstadoVehiculo.activo && obraAsignada == null;
  }

  String get ubicacionTexto {
    if (latitud != null && longitud != null) {
      return 'Lat: ${latitud!.toStringAsFixed(4)}, Lng: ${longitud!.toStringAsFixed(4)}';
    }
    return 'Ubicación no disponible';
  }

  Duration? get tiempoSinActualizar {
    if (ultimaUbicacion == null) return null;
    return DateTime.now().difference(ultimaUbicacion!);
  }
}