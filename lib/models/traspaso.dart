// lib/models/traspaso.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoTraspaso {
  pendiente,
  enProceso,
  completado,
  cancelado
}

class ItemTraspaso {
  final String articuloId;
  final String nombreArticulo;
  final String codigoArticulo;
  final int cantidad;

  ItemTraspaso({
    required this.articuloId,
    required this.nombreArticulo,
    required this.codigoArticulo,
    required this.cantidad,
  });

  factory ItemTraspaso.fromMap(Map<String, dynamic> map) {
    return ItemTraspaso(
      articuloId: map['articuloId'] ?? '',
      nombreArticulo: map['nombreArticulo'] ?? '',
      codigoArticulo: map['codigoArticulo'] ?? '',
      cantidad: map['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articuloId': articuloId,
      'nombreArticulo': nombreArticulo,
      'codigoArticulo': codigoArticulo,
      'cantidad': cantidad,
    };
  }
}

class Traspaso {
  final String id;
  final String numeroTraspaso;
  final String almacenOrigen;
  final String almacenDestino;
  final List<ItemTraspaso> items;
  final EstadoTraspaso estado;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime? fechaCompletado;
  final String creadoPor;
  final String? completadoPor;

  Traspaso({
    required this.id,
    required this.numeroTraspaso,
    required this.almacenOrigen,
    required this.almacenDestino,
    required this.items,
    required this.estado,
    this.observaciones,
    required this.fechaCreacion,
    this.fechaCompletado,
    required this.creadoPor,
    this.completadoPor,
  });

  factory Traspaso.fromMap(Map<String, dynamic> map, String id) {
    return Traspaso(
      id: id,
      numeroTraspaso: map['numeroTraspaso'] ?? '',
      almacenOrigen: map['almacenOrigen'] ?? '',
      almacenDestino: map['almacenDestino'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => ItemTraspaso.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      estado: EstadoTraspaso.values.firstWhere(
        (e) => e.toString().split('.').last == map['estado'],
        orElse: () => EstadoTraspaso.pendiente,
      ),
      observaciones: map['observaciones'],
      fechaCreacion: map['fechaCreacion'] is Timestamp
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaCompletado: map['fechaCompletado'] is Timestamp
          ? (map['fechaCompletado'] as Timestamp).toDate()
          : null,
      creadoPor: map['creadoPor'] ?? '',
      completadoPor: map['completadoPor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numeroTraspaso': numeroTraspaso,
      'almacenOrigen': almacenOrigen,
      'almacenDestino': almacenDestino,
      'items': items.map((item) => item.toMap()).toList(),
      'estado': estado.toString().split('.').last,
      'observaciones': observaciones,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaCompletado': fechaCompletado != null
          ? Timestamp.fromDate(fechaCompletado!)
          : null,
      'creadoPor': creadoPor,
      'completadoPor': completadoPor,
    };
  }

  Traspaso copyWith({
    String? id,
    String? numeroTraspaso,
    String? almacenOrigen,
    String? almacenDestino,
    List<ItemTraspaso>? items,
    EstadoTraspaso? estado,
    String? observaciones,
    DateTime? fechaCreacion,
    DateTime? fechaCompletado,
    String? creadoPor,
    String? completadoPor,
  }) {
    return Traspaso(
      id: id ?? this.id,
      numeroTraspaso: numeroTraspaso ?? this.numeroTraspaso,
      almacenOrigen: almacenOrigen ?? this.almacenOrigen,
      almacenDestino: almacenDestino ?? this.almacenDestino,
      items: items ?? this.items,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      creadoPor: creadoPor ?? this.creadoPor,
      completadoPor: completadoPor ?? this.completadoPor,
    );
  }

  String get estadoString {
    switch (estado) {
      case EstadoTraspaso.pendiente:
        return 'Pendiente';
      case EstadoTraspaso.enProceso:
        return 'En Proceso';
      case EstadoTraspaso.completado:
        return 'Completado';
      case EstadoTraspaso.cancelado:
        return 'Cancelado';
    }
  }
}