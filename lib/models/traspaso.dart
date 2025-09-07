// lib/models/traspaso.dart
class Traspaso {
  final String? id;
  final String empresaId;
  final String ubicacionOrigen;
  final String ubicacionDestino;
  final Map<String, int> articulos; // articuloId -> cantidad
  final String? observaciones;
  final String estado; // 'pendiente', 'en_transito', 'completado', 'cancelado'
  final DateTime fecha;
  final DateTime? fechaModificacion;
  final DateTime? fechaRecepcion;
  final DateTime? fechaCancelacion;
  final Map<String, int>? cantidadesRecibidas;
  final String? motivoCancelacion;
  final String? usuarioCreador;
  final String? usuarioReceptor;

  Traspaso({
    this.id,
    required this.empresaId,
    required this.ubicacionOrigen,
    required this.ubicacionDestino,
    required this.articulos,
    this.observaciones,
    this.estado = 'pendiente',
    required this.fecha,
    this.fechaModificacion,
    this.fechaRecepcion,
    this.fechaCancelacion,
    this.cantidadesRecibidas,
    this.motivoCancelacion,
    this.usuarioCreador,
    this.usuarioReceptor,
  });

  // Método toMap para Firestore
  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'ubicacionOrigen': ubicacionOrigen,
      'ubicacionDestino': ubicacionDestino,
      'articulos': articulos,
      'observaciones': observaciones,
      'estado': estado,
      'fecha': fecha.millisecondsSinceEpoch,
      'fechaModificacion': fechaModificacion?.millisecondsSinceEpoch,
      'fechaRecepcion': fechaRecepcion?.millisecondsSinceEpoch,
      'fechaCancelacion': fechaCancelacion?.millisecondsSinceEpoch,
      'cantidadesRecibidas': cantidadesRecibidas,
      'motivoCancelacion': motivoCancelacion,
      'usuarioCreador': usuarioCreador,
      'usuarioReceptor': usuarioReceptor,
    };
  }

  // Factory constructor desde Map
  factory Traspaso.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Traspaso(
      id: docId ?? map['id'],
      empresaId: map['empresaId'] ?? '',
      ubicacionOrigen: map['ubicacionOrigen'] ?? '',
      ubicacionDestino: map['ubicacionDestino'] ?? '',
      articulos: Map<String, int>.from(map['articulos'] ?? {}),
      observaciones: map['observaciones'],
      estado: map['estado'] ?? 'pendiente',
      fecha: map['fecha'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha'])
          : DateTime.now(),
      fechaModificacion: map['fechaModificacion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaModificacion'])
          : null,
      fechaRecepcion: map['fechaRecepcion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaRecepcion'])
          : null,
      fechaCancelacion: map['fechaCancelacion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaCancelacion'])
          : null,
      cantidadesRecibidas: map['cantidadesRecibidas'] != null 
          ? Map<String, int>.from(map['cantidadesRecibidas'])
          : null,
      motivoCancelacion: map['motivoCancelacion'],
      usuarioCreador: map['usuarioCreador'],
      usuarioReceptor: map['usuarioReceptor'],
    );
  }

  // Método copyWith
  Traspaso copyWith({
    String? id,
    String? empresaId,
    String? ubicacionOrigen,
    String? ubicacionDestino,
    Map<String, int>? articulos,
    String? observaciones,
    String? estado,
    DateTime? fecha,
    DateTime? fechaModificacion,
    DateTime? fechaRecepcion,
    DateTime? fechaCancelacion,
    Map<String, int>? cantidadesRecibidas,
    String? motivoCancelacion,
    String? usuarioCreador,
    String? usuarioReceptor,
  }) {
    return Traspaso(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      ubicacionOrigen: ubicacionOrigen ?? this.ubicacionOrigen,
      ubicacionDestino: ubicacionDestino ?? this.ubicacionDestino,
      articulos: articulos ?? this.articulos,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      cantidadesRecibidas: cantidadesRecibidas ?? this.cantidadesRecibidas,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      usuarioCreador: usuarioCreador ?? this.usuarioCreador,
      usuarioReceptor: usuarioReceptor ?? this.usuarioReceptor,
    );
  }

  // Getters de utilidad
  int get totalArticulos => articulos.length;
  
  int get totalCantidad => articulos.values.fold(0, (sum, cantidad) => sum + cantidad);
  
  bool get estaCompletado => estado == 'completado';
  
  bool get estaCancelado => estado == 'cancelado';
  
  bool get estaPendiente => estado == 'pendiente';
  
  bool get estaEnTransito => estado == 'en_transito';

  // Método para obtener el color según el estado
  String get colorEstado {
    switch (estado) {
      case 'pendiente':
        return 'orange';
      case 'en_transito':
        return 'blue';
      case 'completado':
        return 'green';
      case 'cancelado':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Método para obtener el texto del estado
  String get textoEstado {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_transito':
        return 'En Tránsito';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  @override
  String toString() {
    return 'Traspaso(id: $id, origen: $ubicacionOrigen, destino: $ubicacionDestino, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Traspaso && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}