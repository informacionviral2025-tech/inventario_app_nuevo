// lib/models/traspaso.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoTraspaso {
  pendiente,
  enviado,
  recibido,
  completado,
  cancelado
}

extension EstadoTraspasoExtension on EstadoTraspaso {
  String toUpperCase() {
    switch (this) {
      case EstadoTraspaso.pendiente:
        return 'PENDIENTE';
      case EstadoTraspaso.enviado:
        return 'ENVIADO';
      case EstadoTraspaso.recibido:
        return 'RECIBIDO';
      case EstadoTraspaso.completado:
        return 'COMPLETADO';
      case EstadoTraspaso.cancelado:
        return 'CANCELADO';
    }
  }

  String get displayName {
    switch (this) {
      case EstadoTraspaso.pendiente:
        return 'Pendiente';
      case EstadoTraspaso.enviado:
        return 'Enviado';
      case EstadoTraspaso.recibido:
        return 'Recibido';
      case EstadoTraspaso.completado:
        return 'Completado';
      case EstadoTraspaso.cancelado:
        return 'Cancelado';
    }
  }
}

class Traspaso {
  String? id;
  final String empresaId;
  final String tipoOrigen;  // 'almacen' o 'obra'
  final String origenId;
  final String tipoDestino; // 'almacen' o 'obra'
  final String destinoId;
  final Map<String, int> articulos; // articuloId -> cantidad
  final EstadoTraspaso estado;
  final String usuario;
  final DateTime fecha;
  final DateTime? fechaConfirmacion;
  final String? albaranId;
  final String? observaciones;

  Traspaso({
    this.id,
    required this.empresaId,
    required this.tipoOrigen,
    required this.origenId,
    required this.tipoDestino,
    required this.destinoId,
    required this.articulos,
    this.estado = EstadoTraspaso.pendiente,
    required this.usuario,
    required this.fecha,
    this.fechaConfirmacion,
    this.albaranId,
    this.observaciones,
  });

  // Constructor desde Firestore
  factory Traspaso.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convertir el mapa de artículos
    Map<String, int> articulos = {};
    if (data['articulos'] != null) {
      final articulosData = data['articulos'] as Map<String, dynamic>;
      articulos = articulosData.map((key, value) => MapEntry(key, value as int));
    }

    // Convertir el estado
    EstadoTraspaso estado = EstadoTraspaso.pendiente;
    if (data['estado'] != null) {
      final estadoString = data['estado'] as String;
      switch (estadoString.toLowerCase()) {
        case 'pendiente':
          estado = EstadoTraspaso.pendiente;
          break;
        case 'enviado':
          estado = EstadoTraspaso.enviado;
          break;
        case 'recibido':
          estado = EstadoTraspaso.recibido;
          break;
        case 'completado':
          estado = EstadoTraspaso.completado;
          break;
        case 'cancelado':
          estado = EstadoTraspaso.cancelado;
          break;
      }
    }

    return Traspaso(
      id: doc.id,
      empresaId: data['empresaId'] ?? '',
      tipoOrigen: data['tipoOrigen'] ?? '',
      origenId: data['origenId'] ?? '',
      tipoDestino: data['tipoDestino'] ?? '',
      destinoId: data['destinoId'] ?? '',
      articulos: articulos,
      estado: estado,
      usuario: data['usuario'] ?? '',
      fecha: data['fecha'] != null 
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      fechaConfirmacion: data['fechaConfirmacion'] != null
          ? (data['fechaConfirmacion'] as Timestamp).toDate()
          : null,
      albaranId: data['albaranId'],
      observaciones: data['observaciones'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'empresaId': empresaId,
      'tipoOrigen': tipoOrigen,
      'origenId': origenId,
      'tipoDestino': tipoDestino,
      'destinoId': destinoId,
      'articulos': articulos,
      'estado': estado.name,
      'usuario': usuario,
      'fecha': Timestamp.fromDate(fecha),
      'fechaConfirmacion': fechaConfirmacion != null
          ? Timestamp.fromDate(fechaConfirmacion!)
          : null,
      'albaranId': albaranId,
      'observaciones': observaciones,
    };
  }

  // CopyWith para crear copias modificadas
  Traspaso copyWith({
    String? id,
    String? empresaId,
    String? tipoOrigen,
    String? origenId,
    String? tipoDestino,
    String? destinoId,
    Map<String, int>? articulos,
    EstadoTraspaso? estado,
    String? usuario,
    DateTime? fecha,
    DateTime? fechaConfirmacion,
    String? albaranId,
    String? observaciones,
  }) {
    return Traspaso(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      tipoOrigen: tipoOrigen ?? this.tipoOrigen,
      origenId: origenId ?? this.origenId,
      tipoDestino: tipoDestino ?? this.tipoDestino,
      destinoId: destinoId ?? this.destinoId,
      articulos: articulos ?? Map.from(this.articulos),
      estado: estado ?? this.estado,
      usuario: usuario ?? this.usuario,
      fecha: fecha ?? this.fecha,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      albaranId: albaranId ?? this.albaranId,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  // Propiedades computadas
  bool get isPendiente => estado == EstadoTraspaso.pendiente;
  bool get isEnviado => estado == EstadoTraspaso.enviado;
  bool get isRecibido => estado == EstadoTraspaso.recibido;
  bool get isCompletado => estado == EstadoTraspaso.completado;
  bool get isCancelado => estado == EstadoTraspaso.cancelado;

  int get totalArticulos => articulos.values.fold(0, (sum, cantidad) => sum + cantidad);

  @override
  String toString() {
    return 'Traspaso{id: $id, estado: $estado, totalArticulos: $totalArticulos}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Traspaso &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}