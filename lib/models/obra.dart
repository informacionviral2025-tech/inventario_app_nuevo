// lib/models/obra.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Obra {
  final String id;
  final String? firebaseId;
  final String? codigoObra; // AÑADIDO
  final String nombre;
  final String? cliente;
  final String? descripcion;
  final String? clienteId;
  final String empresaId;
  final String estado;
  final String? direccion;
  final String? telefono;
  final String? responsable;
  final double? presupuesto;
  final DateTime fechaCreacion;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? fechaFinPrevista;
  final Map<String, int> stock;

  Obra({
    required this.id,
    this.firebaseId,
    this.codigoObra, // AÑADIDO
    required this.nombre,
    this.cliente,
    this.descripcion,
    this.clienteId,
    required this.empresaId,
    this.estado = 'activa',
    this.direccion,
    this.telefono,
    this.responsable,
    this.presupuesto,
    required this.fechaCreacion,
    this.fechaInicio,
    this.fechaFin,
    this.fechaFinPrevista,
    this.stock = const {},
  });

  bool get estaActiva => estado == 'activa';
  bool get estaPausada => estado == 'pausada';
  bool get estaFinalizada => estado == 'finalizada';

  int getCantidadArticulo(String articuloId) {
    return stock[articuloId] ?? 0;
  }

  Obra copyWith({
    String? id,
    String? firebaseId,
    String? codigoObra, // AÑADIDO
    String? nombre,
    String? cliente,
    String? descripcion,
    String? clienteId,
    String? empresaId,
    String? estado,
    String? direccion,
    String? telefono,
    String? responsable,
    double? presupuesto,
    DateTime? fechaCreacion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? fechaFinPrevista,
    Map<String, int>? stock,
  }) {
    return Obra(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      codigoObra: codigoObra ?? this.codigoObra, // AÑADIDO
      nombre: nombre ?? this.nombre,
      cliente: cliente ?? this.cliente,
      descripcion: descripcion ?? this.descripcion,
      clienteId: clienteId ?? this.clienteId,
      empresaId: empresaId ?? this.empresaId,
      estado: estado ?? this.estado,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      responsable: responsable ?? this.responsable,
      presupuesto: presupuesto ?? this.presupuesto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaFinPrevista: fechaFinPrevista ?? this.fechaFinPrevista,
      stock: stock ?? Map.from(this.stock),
    );
  }

  factory Obra.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Obra(
      id: doc.id,
      firebaseId: doc.id,
      codigoObra: data['codigoObra'], // AÑADIDO
      nombre: data['nombre'] ?? '',
      cliente: data['cliente'],
      descripcion: data['descripcion'],
      clienteId: data['clienteId'],
      empresaId: data['empresaId'] ?? '',
      estado: data['estado'] ?? 'activa',
      direccion: data['direccion'],
      telefono: data['telefono'],
      responsable: data['responsable'],
      presupuesto: data['presupuesto']?.toDouble(),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaInicio: data['fechaInicio'] != null
          ? (data['fechaInicio'] as Timestamp).toDate()
          : null,
      fechaFin: data['fechaFin'] != null
          ? (data['fechaFin'] as Timestamp).toDate()
          : null,
      fechaFinPrevista: data['fechaFinPrevista'] != null
          ? (data['fechaFinPrevista'] as Timestamp).toDate()
          : null,
      stock: Map<String, int>.from(data['stock'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      if (codigoObra != null) 'codigoObra': codigoObra, // AÑADIDO
      if (cliente != null) 'cliente': cliente,
      if (descripcion != null) 'descripcion': descripcion,
      if (clienteId != null) 'clienteId': clienteId,
      'empresaId': empresaId,
      'estado': estado,
      if (direccion != null) 'direccion': direccion,
      if (telefono != null) 'telefono': telefono,
      if (responsable != null) 'responsable': responsable,
      if (presupuesto != null) 'presupuesto': presupuesto,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio!),
      if (fechaFin != null) 'fechaFin': Timestamp.fromDate(fechaFin!),
      if (fechaFinPrevista != null)
        'fechaFinPrevista': Timestamp.fromDate(fechaFinPrevista!),
      'stock': stock,
    };
  }
}