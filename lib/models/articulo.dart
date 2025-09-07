// lib/models/articulo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  String? firebaseId;
  final String codigo;
  final String descripcion;
  final String unidad;
  final num stock;
  final num precio;
  final String categoria;
  final String? ubicacion;
  final num stockMinimo;
  final String? proveedor;
  final String? observaciones;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Articulo({
    this.firebaseId,
    required this.codigo,
    required this.descripcion,
    required this.unidad,
    required this.stock,
    required this.precio,
    required this.categoria,
    this.ubicacion,
    this.stockMinimo = 0,
    this.proveedor,
    this.observaciones,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Constructor desde Firestore
  factory Articulo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Articulo(
      firebaseId: doc.id,
      codigo: data['codigo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      unidad: data['unidad'] ?? 'und',
      stock: data['stock'] ?? 0,
      precio: data['precio'] ?? 0.0,
      categoria: data['categoria'] ?? '',
      ubicacion: data['ubicacion'],
      stockMinimo: data['stockMinimo'] ?? 0,
      proveedor: data['proveedor'],
      observaciones: data['observaciones'],
      fechaCreacion: data['fechaCreacion'] != null 
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: data['fechaActualizacion'] != null
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  // Constructor desde Map
  factory Articulo.fromMap(Map<String, dynamic> map) {
    return Articulo(
      firebaseId: map['firebaseId'],
      codigo: map['codigo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      unidad: map['unidad'] ?? 'und',
      stock: map['stock'] ?? 0,
      precio: map['precio'] ?? 0.0,
      categoria: map['categoria'] ?? '',
      ubicacion: map['ubicacion'],
      stockMinimo: map['stockMinimo'] ?? 0,
      proveedor: map['proveedor'],
      observaciones: map['observaciones'],
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.parse(map['fechaCreacion'])
          : null,
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.parse(map['fechaActualizacion'])
          : null,
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'codigo': codigo,
      'descripcion': descripcion,
      'unidad': unidad,
      'stock': stock,
      'precio': precio,
      'categoria': categoria,
      'ubicacion': ubicacion,
      'stockMinimo': stockMinimo,
      'proveedor': proveedor,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'firebaseId': firebaseId,
      'codigo': codigo,
      'descripcion': descripcion,
      'unidad': unidad,
      'stock': stock,
      'precio': precio,
      'categoria': categoria,
      'ubicacion': ubicacion,
      'stockMinimo': stockMinimo,
      'proveedor': proveedor,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // CopyWith para crear copias modificadas
  Articulo copyWith({
    String? firebaseId,
    String? codigo,
    String? descripcion,
    String? unidad,
    num? stock,
    num? precio,
    String? categoria,
    String? ubicacion,
    num? stockMinimo,
    String? proveedor,
    String? observaciones,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Articulo(
      firebaseId: firebaseId ?? this.firebaseId,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      unidad: unidad ?? this.unidad,
      stock: stock ?? this.stock,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      ubicacion: ubicacion ?? this.ubicacion,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      proveedor: proveedor ?? this.proveedor,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Articulo{firebaseId: $firebaseId, codigo: $codigo, descripcion: $descripcion, stock: $stock}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Articulo &&
          runtimeType == other.runtimeType &&
          firebaseId == other.firebaseId &&
          codigo == other.codigo;

  @override
  int get hashCode => firebaseId.hashCode ^ codigo.hashCode;

  // Métodos de utilidad
  bool get tieneStockBajo => stock <= stockMinimo;
  bool get tieneStock => stock > 0;
  double get valorInventario => (precio * stock).toDouble();
}