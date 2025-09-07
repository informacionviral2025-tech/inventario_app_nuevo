// lib/models/articulo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  final String? id;
  final String? firebaseId;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final String? categoria;
  final double? precio;
  final int stock;
  final int? stockMinimo;
  final String? ubicacion;
  final bool? activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Articulo({
    this.id,
    this.firebaseId,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    this.categoria,
    this.precio,
    required this.stock,
    this.stockMinimo,
    this.ubicacion,
    this.activo,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Factory constructor para crear desde Firestore
  factory Articulo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Articulo(
      id: doc.id,
      firebaseId: doc.id,
      nombre: data['nombre'] ?? '',
      codigo: data['codigo'] ?? '',
      descripcion: data['descripcion'],
      categoria: data['categoria'],
      precio: (data['precio'] as num?)?.toDouble(),
      stock: data['stock'] ?? 0,
      stockMinimo: data['stockMinimo'],
      ubicacion: data['ubicacion'],
      activo: data['activo'] ?? true,
      fechaCreacion: data['fechaCreacion'] != null 
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: data['fechaActualizacion'] != null
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory constructor para crear desde Map
  factory Articulo.fromMap(Map<String, dynamic> map) {
    return Articulo(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nombre: map['nombre'] ?? '',
      codigo: map['codigo'] ?? '',
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      precio: (map['precio'] as num?)?.toDouble(),
      stock: map['stock'] ?? 0,
      stockMinimo: map['stockMinimo'],
      ubicacion: map['ubicacion'],
      activo: map['activo'] ?? true,
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.parse(map['fechaCreacion'])
          : null,
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.parse(map['fechaActualizacion'])
          : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'stockMinimo': stockMinimo,
      'ubicacion': ubicacion,
      'activo': activo ?? true,
      'fechaCreacion': fechaCreacion != null 
          ? Timestamp.fromDate(fechaCreacion!)
          : Timestamp.now(),
      'fechaActualizacion': Timestamp.now(),
    };
  }

  // Convertir a Map genérico
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'stockMinimo': stockMinimo,
      'ubicacion': ubicacion,
      'activo': activo,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Método copyWith para crear copias con cambios
  Articulo copyWith({
    String? id,
    String? firebaseId,
    String? nombre,
    String? codigo,
    String? descripcion,
    String? categoria,
    double? precio,
    int? stock,
    int? stockMinimo,
    String? ubicacion,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Articulo(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      ubicacion: ubicacion ?? this.ubicacion,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Articulo{id: $id, nombre: $nombre, codigo: $codigo, stock: $stock}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Articulo &&
        other.id == id &&
        other.nombre == nombre &&
        other.codigo == codigo;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode ^ codigo.hashCode;
}