// lib/models/articulo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  final String? firebaseId;
  final int? localId;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String? codigoBarras;
  final String? categoria;
  final String empresaId;
  final String? unidadMedida;
  final double? stockMinimo;
  final double? stockMaximo;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  // Campos adicionales
  final String? codigo;
  final String? sku;
  final double? precioCosto;
  final String? unidad;

  Articulo({
    this.firebaseId,
    this.localId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.codigoBarras,
    this.categoria,
    required this.empresaId,
    this.unidadMedida,
    this.stockMinimo,
    this.stockMaximo,
    this.activo = true,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.codigo,
    this.sku,
    this.precioCosto,
    this.unidad,
  });

  // Getter para compatibilidad
  String get id => localId?.toString() ?? firebaseId ?? '';

  // Getters de conveniencia
  bool get stockBajo => stockMinimo != null && stock <= stockMinimo!;
  bool get necesitaReabastecimiento => stockBajo;
  bool get tieneStock => stock > 0;
  double get valorInventario => stock * (precioCosto ?? precio);

  // Factory desde Firestore
  factory Articulo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Articulo(
      firebaseId: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'],
      precio: (data['precio'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      codigoBarras: data['codigoBarras'],
      categoria: data['categoria'],
      empresaId: data['empresaId'] ?? '',
      unidadMedida: data['unidadMedida'],
      stockMinimo: data['stockMinimo']?.toDouble(),
      stockMaximo: data['stockMaximo']?.toDouble(),
      activo: data['activo'] ?? true,
      fechaCreacion: data['fechaCreacion'] is Timestamp
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaActualizacion: data['fechaActualizacion'] is Timestamp
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : DateTime.now(),
      codigo: data['codigo'],
      sku: data['sku'],
      precioCosto: data['precioCosto']?.toDouble(),
      unidad: data['unidad'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'codigoBarras': codigoBarras,
      'categoria': categoria,
      'empresaId': empresaId,
      'unidadMedida': unidadMedida,
      'stockMinimo': stockMinimo,
      'stockMaximo': stockMaximo,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
      'codigo': codigo,
      'sku': sku,
      'precioCosto': precioCosto,
      'unidad': unidad,
    };
  }

  // CopyWith
  Articulo copyWith({
    String? firebaseId,
    int? localId,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? codigoBarras,
    String? categoria,
    String? empresaId,
    String? unidadMedida,
    double? stockMinimo,
    double? stockMaximo,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? codigo,
    String? sku,
    double? precioCosto,
    String? unidad,
  }) {
    return Articulo(
      firebaseId: firebaseId ?? this.firebaseId,
      localId: localId ?? this.localId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoria: categoria ?? this.categoria,
      empresaId: empresaId ?? this.empresaId,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      stockMaximo: stockMaximo ?? this.stockMaximo,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      codigo: codigo ?? this.codigo,
      sku: sku ?? this.sku,
      precioCosto: precioCosto ?? this.precioCosto,
      unidad: unidad ?? this.unidad,
    );
  }
}
