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
  
  // Propiedades faltantes agregadas
  final String? codigo;           // AGREGADO
  final String? sku;             // AGREGADO
  final double? precioCosto;     // AGREGADO
  final String? unidad;          // AGREGADO

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
    // Parámetros agregados
    this.codigo,
    this.sku,
    this.precioCosto,
    this.unidad,
  });

  // Getter para compatibilidad con sincronización
  String get id => localId?.toString() ?? firebaseId ?? '';

  // Getters faltantes agregados
  bool get stockBajo => stockMinimo != null && stock <= stockMinimo!;
  bool get necesitaReabastecimiento => stockBajo;
  bool get tieneStock => stock > 0;
  double get valorInventario => stock * (precioCosto ?? precio);

  // Factory constructor from Firestore
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
          : DateTime.parse(data['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: data['fechaActualizacion'] is Timestamp
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : DateTime.parse(data['fechaActualizacion'] ?? DateTime.now().toIso8601String()),
      // Campos agregados
      codigo: data['codigo'],
      sku: data['sku'],
      precioCosto: data['precioCosto']?.toDouble(),
      unidad: data['unidad'],
    );
  }

  // MÉTODO AGREGADO - fromFirebase
  factory Articulo.fromFirebase(String id, Map<String, dynamic> data) {
    return Articulo(
      firebaseId: id,
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
          : DateTime.parse(data['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: data['fechaActualizacion'] is Timestamp
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : DateTime.parse(data['fechaActualizacion'] ?? DateTime.now().toIso8601String()),
      codigo: data['codigo'],
      sku: data['sku'],
      precioCosto: data['precioCosto']?.toDouble(),
      unidad: data['unidad'],
    );
  }

  // Factory constructor from Map (for SQLite)
  factory Articulo.fromMap(Map<String, dynamic> map) {
    return Articulo(
      localId: map['id'],
      firebaseId: map['firebase_id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      precio: (map['precio'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      codigoBarras: map['codigo_barras'],
      categoria: map['categoria'],
      empresaId: map['empresa_id'] ?? '',
      unidadMedida: map['unidad_medida'],
      stockMinimo: map['stock_minimo']?.toDouble(),
      stockMaximo: map['stock_maximo']?.toDouble(),
      activo: (map['activo'] ?? 1) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion'] ?? DateTime.now().toIso8601String()),
      codigo: map['codigo'],
      sku: map['sku'],
      precioCosto: map['precio_costo']?.toDouble(),
      unidad: map['unidad'],
    );
  }

  // Convert to Firestore document
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

  // MÉTODO AGREGADO - toFirebase
  Map<String, dynamic> toFirebase() {
    return toFirestore();
  }

  // Convert to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': localId,
      'firebase_id': firebaseId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'codigo_barras': codigoBarras,
      'categoria': categoria,
      'empresa_id': empresaId,
      'unidad_medida': unidadMedida,
      'stock_minimo': stockMinimo,
      'stock_maximo': stockMaximo,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
      'codigo': codigo,
      'sku': sku,
      'precio_costo': precioCosto,
      'unidad': unidad,
    };
  }

  // Copy with method
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

  // Validation methods
  bool get tieneStockBajo => stockMinimo != null && stock <= stockMinimo!;
  bool get tieneStockAlto => stockMaximo != null && stock >= stockMaximo!;
  bool get tieneCodigoBarras => codigoBarras != null && codigoBarras!.isNotEmpty;

  @override
  String toString() {
    return 'Articulo{id: $id, nombre: $nombre, precio: $precio, stock: $stock}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Articulo &&
          runtimeType == other.runtimeType &&
          firebaseId == other.firebaseId &&
          localId == other.localId &&
          nombre == other.nombre;

  @override
  int get hashCode => firebaseId.hashCode ^ localId.hashCode ^ nombre.hashCode;
}