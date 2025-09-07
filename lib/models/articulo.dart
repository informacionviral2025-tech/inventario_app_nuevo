// lib/models/articulo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  final String? id;
  final String? firebaseId;
  final String nombre;
  final String? descripcion;
  final String codigo;
  final String? categoria;
  final int stock;
  final int? stockMinimo;
  final double precio;
  final String? codigoBarras;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;
  final DateTime? fechaActualizacion;
  final bool? pendienteSincronizacion;
  final bool? sincronizado;

  Articulo({
    this.id,
    this.firebaseId,
    required this.nombre,
    this.descripcion,
    required this.codigo,
    this.categoria,
    this.stock = 0,
    this.stockMinimo,
    this.precio = 0.0,
    this.codigoBarras,
    this.activo = true,
    this.fechaCreacion,
    this.fechaModificacion,
    this.fechaActualizacion,
    this.pendienteSincronizacion,
    this.sincronizado,
  });

  // Constructor desde Map (para Firestore)
  factory Articulo.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return Articulo(
      id: documentId ?? map['id'],
      firebaseId: documentId,
      nombre: map['nombre'] ?? map['descripcion'] ?? '',
      descripcion: map['descripcion'] ?? map['nombre'],
      codigo: map['codigo'] ?? map['codigoBarras'] ?? '',
      categoria: map['categoria'],
      stock: (map['stock'] ?? 0) is int ? map['stock'] : int.tryParse(map['stock'].toString()) ?? 0,
      stockMinimo: map['stockMinimo'] != null ? int.tryParse(map['stockMinimo'].toString()) : null,
      precio: (map['precio'] ?? 0.0) is double ? map['precio'] : double.tryParse(map['precio'].toString()) ?? 0.0,
      codigoBarras: map['codigoBarras'] ?? map['codigo'],
      activo: map['activo'] ?? true,
      fechaCreacion: map['fechaCreacion'] is Timestamp 
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : map['fechaCreacion'],
      fechaModificacion: map['fechaModificacion'] is Timestamp
          ? (map['fechaModificacion'] as Timestamp).toDate()
          : map['fechaModificacion'],
      fechaActualizacion: map['fechaActualizacion'] is Timestamp
          ? (map['fechaActualizacion'] as Timestamp).toDate()
          : map['fechaActualizacion'],
      pendienteSincronizacion: map['pendienteSincronizacion'],
      sincronizado: map['sincronizado'],
    );
  }

  // Constructor desde Firestore
  factory Articulo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Articulo.fromMap(data, doc.id);
  }

  // Constructor fromFirebase (para compatibilidad)
  factory Articulo.fromFirebase(String firebaseId, Map<String, dynamic> data) {
    return Articulo.fromMap(data, firebaseId);
  }

  // Convertir a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion ?? nombre,
      'codigo': codigo,
      'categoria': categoria,
      'stock': stock,
      'stockMinimo': stockMinimo,
      'precio': precio,
      'codigoBarras': codigoBarras ?? codigo,
      'activo': activo,
      'fechaCreacion': fechaCreacion ?? FieldValue.serverTimestamp(),
      'fechaModificacion': fechaModificacion ?? FieldValue.serverTimestamp(),
      'fechaActualizacion': fechaActualizacion ?? FieldValue.serverTimestamp(),
      'pendienteSincronizacion': pendienteSincronizacion ?? false,
      'sincronizado': sincronizado ?? false,
    };
  }

  // toFirebase (para compatibilidad con sync_service)
  Map<String, dynamic> toFirebase() {
    return toMap();
  }

  // Método copyWith para crear copias con cambios
  Articulo copyWith({
    String? id,
    String? firebaseId,
    String? nombre,
    String? descripcion,
    String? codigo,
    String? categoria,
    int? stock,
    int? stockMinimo,
    double? precio,
    String? codigoBarras,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    DateTime? fechaActualizacion,
    bool? pendienteSincronizacion,
    bool? sincronizado,
  }) {
    return Articulo(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      codigo: codigo ?? this.codigo,
      categoria: categoria ?? this.categoria,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      precio: precio ?? this.precio,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      pendienteSincronizacion: pendienteSincronizacion ?? this.pendienteSincronizacion,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  @override
  String toString() {
    return 'Articulo(id: $id, nombre: $nombre, stock: $stock, precio: $precio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Articulo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}