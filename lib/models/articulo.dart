// lib/models/articulo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  final String id;
  final String nombre;
  final String codigo;
  final String categoria;
  final double precio;
  final int stock;
  final String? descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  Articulo({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.categoria,
    required this.precio,
    required this.stock,
    this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  factory Articulo.fromMap(Map<String, dynamic> map, String id) {
    return Articulo(
      id: id,
      nombre: map['nombre'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      descripcion: map['descripcion'],
      fechaCreacion: map['fechaCreacion'] is Timestamp
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaModificacion: map['fechaModificacion'] is Timestamp
          ? (map['fechaModificacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': Timestamp.fromDate(fechaModificacion),
    };
  }

  Articulo copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? categoria,
    double? precio,
    int? stock,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return Articulo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }
}