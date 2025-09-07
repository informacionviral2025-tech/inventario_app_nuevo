// lib/models/articulo.dart
class Articulo {
  final String? id;
  final String? firebaseId;
  final String codigo;
  final String descripcion;
  final int stock;
  final double? precio;
  final String? categoria;
  final int? stockMinimo;
  final String? ubicacion;
  final bool? activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;
  final String? empresaId;

  Articulo({
    this.id,
    this.firebaseId,
    required this.codigo,
    required this.descripcion,
    required this.stock,
    this.precio,
    this.categoria,
    this.stockMinimo,
    this.ubicacion,
    this.activo = true,
    this.fechaCreacion,
    this.fechaModificacion,
    this.empresaId,
  });

  // Getters de compatibilidad
  String get nombre => descripcion; // Para compatibilidad con código existente
  String? get codigoBarras => codigo; // Para compatibilidad con código existente

  // Método toMap para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'codigo': codigo,
      'descripcion': descripcion,
      'stock': stock,
      'precio': precio,
      'categoria': categoria,
      'stockMinimo': stockMinimo,
      'ubicacion': ubicacion,
      'activo': activo ?? true,
      'fechaCreacion': fechaCreacion?.millisecondsSinceEpoch,
      'fechaModificacion': fechaModificacion?.millisecondsSinceEpoch,
      'empresaId': empresaId,
    };
  }

  // Factory constructor desde Map
  factory Articulo.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Articulo(
      id: map['id'] ?? docId,
      firebaseId: docId ?? map['firebaseId'],
      codigo: map['codigo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      stock: map['stock']?.toInt() ?? 0,
      precio: map['precio']?.toDouble(),
      categoria: map['categoria'],
      stockMinimo: map['stockMinimo']?.toInt(),
      ubicacion: map['ubicacion'],
      activo: map['activo'] ?? true,
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion'])
          : null,
      fechaModificacion: map['fechaModificacion'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaModificacion'])
          : null,
      empresaId: map['empresaId'],
    );
  }

  // Método copyWith
  Articulo copyWith({
    String? id,
    String? firebaseId,
    String? codigo,
    String? descripcion,
    int? stock,
    double? precio,
    String? categoria,
    int? stockMinimo,
    String? ubicacion,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    String? empresaId,
  }) {
    return Articulo(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      stock: stock ?? this.stock,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      ubicacion: ubicacion ?? this.ubicacion,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      empresaId: empresaId ?? this.empresaId,
    );
  }

  @override
  String toString() {
    return 'Articulo(id: $id, codigo: $codigo, descripcion: $descripcion, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Articulo &&
        other.id == id &&
        other.codigo == codigo;
  }

  @override
  int get hashCode => id.hashCode ^ codigo.hashCode;
}