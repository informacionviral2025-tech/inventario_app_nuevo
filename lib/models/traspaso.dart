// lib/models/traspaso.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para tipos de ubicación
enum TipoUbicacion {
  empresa,
  obra,
}

class Traspaso {
  final String? firebaseId;
  final String origenId;
  final String destinoId;
  final String tipoOrigen; // "empresa" o "obra"
  final String tipoDestino; // "empresa" o "obra"
  final Map<String, int> articulos; // { "articuloId": cantidad }
  final String usuario;
  final String? usuarioId;
  final DateTime fecha;
  final String estado; // "pendiente", "completado", "cancelado", "devuelto"
  final String? albaranId;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaDevolucion;
  final String? observaciones;
  final String? origenNombre;
  final String? destinoNombre;
  final Map<String, dynamic>? detallesArticulos; // Información adicional de artículos

  Traspaso({
    this.firebaseId,
    required this.origenId,
    required this.destinoId,
    required this.tipoOrigen,
    required this.tipoDestino,
    required this.articulos,
    required this.usuario,
    this.usuarioId,
    required this.fecha,
    this.estado = 'pendiente',
    this.albaranId,
    this.fechaConfirmacion,
    this.fechaDevolucion,
    this.observaciones,
    this.origenNombre,
    this.destinoNombre,
    this.detallesArticulos,
  });

  // Métodos estáticos para tipos de ubicación
  static const TipoUbicacion obra = TipoUbicacion.obra;
  static const TipoUbicacion almacenEmpresa = TipoUbicacion.empresa;

  // Crear desde Firestore
  factory Traspaso.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Traspaso(
      firebaseId: doc.id,
      origenId: data['origenId'] ?? '',
      destinoId: data['destinoId'] ?? '',
      tipoOrigen: data['tipoOrigen'] ?? 'empresa',
      tipoDestino: data['tipoDestino'] ?? 'obra',
      articulos: Map<String, int>.from(data['articulos'] ?? {}),
      usuario: data['usuario'] ?? '',
      usuarioId: data['usuarioId'],
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? 'pendiente',
      albaranId: data['albaranId'],
      fechaConfirmacion: (data['fechaConfirmacion'] as Timestamp?)?.toDate(),
      fechaDevolucion: (data['fechaDevolucion'] as Timestamp?)?.toDate(),
      observaciones: data['observaciones'],
      origenNombre: data['origenNombre'],
      destinoNombre: data['destinoNombre'],
      detallesArticulos: data['detallesArticulos'] != null 
          ? Map<String, dynamic>.from(data['detallesArticulos']) 
          : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'origenId': origenId,
      'destinoId': destinoId,
      'tipoOrigen': tipoOrigen,
      'tipoDestino': tipoDestino,
      'articulos': articulos,
      'usuario': usuario,
      'usuarioId': usuarioId,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
      'albaranId': albaranId,
      'fechaConfirmacion': fechaConfirmacion != null 
          ? Timestamp.fromDate(fechaConfirmacion!) 
          : null,
      'fechaDevolucion': fechaDevolucion != null 
          ? Timestamp.fromDate(fechaDevolucion!) 
          : null,
      'observaciones': observaciones,
      'origenNombre': origenNombre,
      'destinoNombre': destinoNombre,
      'detallesArticulos': detallesArticulos,
    };
  }

  // Convertir a Map para uso local
  Map<String, dynamic> toMap() {
    return {
      'firebaseId': firebaseId,
      'origenId': origenId,
      'destinoId': destinoId,
      'tipoOrigen': tipoOrigen,
      'tipoDestino': tipoDestino,
      'articulos': articulos,
      'usuario': usuario,
      'usuarioId': usuarioId,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
      'albaranId': albaranId,
      'fechaConfirmacion': fechaConfirmacion?.toIso8601String(),
      'fechaDevolucion': fechaDevolucion?.toIso8601String(),
      'observaciones': observaciones,
      'origenNombre': origenNombre,
      'destinoNombre': destinoNombre,
      'detallesArticulos': detallesArticulos,
    };
  }

  // Crear copia con cambios
  Traspaso copyWith({
    String? firebaseId,
    String? origenId,
    String? destinoId,
    String? tipoOrigen,
    String? tipoDestino,
    Map<String, int>? articulos,
    String? usuario,
    String? usuarioId,
    DateTime? fecha,
    String? estado,
    String? albaranId,
    DateTime? fechaConfirmacion,
    DateTime? fechaDevolucion,
    String? observaciones,
    String? origenNombre,
    String? destinoNombre,
    Map<String, dynamic>? detallesArticulos,
  }) {
    return Traspaso(
      firebaseId: firebaseId ?? this.firebaseId,
      origenId: origenId ?? this.origenId,
      destinoId: destinoId ?? this.destinoId,
      tipoOrigen: tipoOrigen ?? this.tipoOrigen,
      tipoDestino: tipoDestino ?? this.tipoDestino,
      articulos: articulos ?? this.articulos,
      usuario: usuario ?? this.usuario,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      albaranId: albaranId ?? this.albaranId,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      observaciones: observaciones ?? this.observaciones,
      origenNombre: origenNombre ?? this.origenNombre,
      destinoNombre: destinoNombre ?? this.destinoNombre,
      detallesArticulos: detallesArticulos ?? this.detallesArticulos,
    );
  }

  // Validaciones
  bool get esValido {
    if (origenId.isEmpty) return false;
    if (destinoId.isEmpty) return false;
    if (origenId == destinoId) return false;
    if (articulos.isEmpty) return false;
    if (usuario.isEmpty) return false;
    if (!['empresa', 'obra'].contains(tipoOrigen)) return false;
    if (!['empresa', 'obra'].contains(tipoDestino)) return false;
    return true;
  }

  // Getters útiles
  int get totalArticulos => articulos.values.fold(0, (sum, cantidad) => sum + cantidad);
  
  int get cantidadArticulosDiferentes => articulos.length;
  
  bool get isPendiente => estado == 'pendiente';
  bool get isCompletado => estado == 'completado';
  bool get isCancelado => estado == 'cancelado';
  bool get isDevuelto => estado == 'devuelto';
  
  bool get puedeCancelar => isPendiente;
  bool get puedeDevolver => isCompletado;
  bool get puedeConfirmar => isPendiente;

  String get estadoDisplay {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      case 'devuelto':
        return 'Devuelto';
      default:
        return estado;
    }
  }

  String get resumenRuta {
    final origenTipo = tipoOrigen == 'empresa' ? 'Empresa' : 'Obra';
    final destinoTipo = tipoDestino == 'empresa' ? 'Empresa' : 'Obra';
    return '$origenTipo → $destinoTipo';
  }

  String get nombresRuta {
    final origen = origenNombre ?? origenId;
    final destino = destinoNombre ?? destinoId;
    return '$origen → $destino';
  }

  // Métodos para gestionar artículos
  // CORREGIDO: Cambiar el método para que devuelva una nueva instancia
  Traspaso agregarArticulo(String articuloId, int cantidad, {Map<String, dynamic>? detalles}) {
    if (cantidad <= 0) {
      throw ArgumentError('La cantidad debe ser mayor a 0');
    }
    
    final nuevosArticulos = Map<String, int>.from(articulos);
    nuevosArticulos[articuloId] = cantidad;
    
    Map<String, dynamic>? nuevosDetalles = detallesArticulos != null
        ? Map<String, dynamic>.from(detallesArticulos!)
        : null;
    
    if (detalles != null) {
      nuevosDetalles ??= {};
      nuevosDetalles[articuloId] = detalles;
    }
    
    return copyWith(
      articulos: nuevosArticulos,
      detallesArticulos: nuevosDetalles,
    );
  }

  void eliminarArticulo(String articuloId) {
    articulos.remove(articuloId);
    detallesArticulos?.remove(articuloId);
  }

  int obtenerCantidadArticulo(String articuloId) {
    return articulos[articuloId] ?? 0;
  }

  Map<String, dynamic>? obtenerDetallesArticulo(String articuloId) {
    return detallesArticulos?[articuloId];
  }

  // Métodos de estado
  Traspaso marcarComoCompletado({String? albaranId, DateTime? fecha}) {
    return copyWith(
      estado: 'completado',
      albaranId: albaranId ?? this.albaranId,
      fechaConfirmacion: fecha ?? DateTime.now(),
    );
  }

  Traspaso marcarComoCancelado() {
    return copyWith(
      estado: 'cancelado',
      fechaDevolucion: DateTime.now(),
    );
  }

  Traspaso marcarComoDevuelto() {
    return copyWith(
      estado: 'devuelto',
      fechaDevolucion: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Traspaso{id: $firebaseId, origen: $origenId, destino: $destinoId, articulos: $cantidadArticulosDiferentes, estado: $estado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Traspaso &&
        other.firebaseId == firebaseId &&
        other.origenId == origenId &&
        other.destinoId == destinoId &&
        other.fecha == fecha;
  }

  @override
  int get hashCode {
    return Object.hash(
      firebaseId,
      origenId,
      destinoId,
      fecha,
    );
  }
}