import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaranProveedor {
  String? id;
  String numeroAlbaran;
  String proveedorId;
  String proveedorNombre;
  String empresaId;
  DateTime fechaAlbaran;
  DateTime fechaRecepcion;
  DateTime fechaRegistro;
  DateTime? fechaProcesado;
  String estado; // 'pendiente', 'procesado', 'parcial'
  List<LineaAlbaran> lineas;
  double subtotal;
  double iva;
  double total;
  String? observaciones;
  Map<String, dynamic> metadatos;

  AlbaranProveedor({
    this.id,
    required this.numeroAlbaran,
    required this.proveedorId,
    required this.proveedorNombre,
    required this.empresaId,
    required this.fechaAlbaran,
    required this.fechaRecepcion,
    required this.fechaRegistro,
    this.fechaProcesado,
    this.estado = 'pendiente',
    required this.lineas,
    required this.subtotal,
    required this.iva,
    required this.total,
    this.observaciones,
    this.metadatos = const {},
  });

  // Métodos para Firestore
  factory AlbaranProveedor.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return AlbaranProveedor(
      id: doc.id,
      numeroAlbaran: map['numeroAlbaran'] ?? '',
      proveedorId: map['proveedorId'] ?? '',
      proveedorNombre: map['proveedorNombre'] ?? '',
      empresaId: map['empresaId'] ?? '',
      fechaAlbaran: (map['fechaAlbaran'] as Timestamp).toDate(),
      fechaRecepcion: (map['fechaRecepcion'] as Timestamp).toDate(),
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
      fechaProcesado: map['fechaProcesado'] != null 
          ? (map['fechaProcesado'] as Timestamp).toDate() 
          : null,
      estado: map['estado'] ?? 'pendiente',
      lineas: (map['lineas'] as List<dynamic>?)?.map((e) => LineaAlbaran.fromMap(e)).toList() ?? [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      iva: (map['iva'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      observaciones: map['observaciones'],
      metadatos: map['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'numeroAlbaran': numeroAlbaran,
      'proveedorId': proveedorId,
      'proveedorNombre': proveedorNombre,
      'empresaId': empresaId,
      'fechaAlbaran': Timestamp.fromDate(fechaAlbaran),
      'fechaRecepcion': Timestamp.fromDate(fechaRecepcion),
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      if (fechaProcesado != null) 'fechaProcesado': Timestamp.fromDate(fechaProcesado!),
      'estado': estado,
      'lineas': lineas.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'observaciones': observaciones,
      'metadatos': metadatos,
    };
  }

  factory AlbaranProveedor.fromMap(Map<String, dynamic> map, String id) {
    return AlbaranProveedor(
      id: id,
      numeroAlbaran: map['numero_albaran'] ?? '',
      proveedorId: map['proveedor_id'] ?? '',
      proveedorNombre: map['proveedor_nombre'] ?? '',
      empresaId: map['empresa_id'] ?? '',
      fechaAlbaran: DateTime.parse(map['fecha_albaran'] ?? DateTime.now().toIso8601String()),
      fechaRecepcion: DateTime.parse(map['fecha_recepcion'] ?? DateTime.now().toIso8601String()),
      fechaRegistro: DateTime.parse(map['fecha_registro'] ?? DateTime.now().toIso8601String()),
      fechaProcesado: map['fecha_procesado'] != null 
          ? DateTime.parse(map['fecha_procesado']) 
          : null,
      estado: map['estado'] ?? 'pendiente',
      lineas: (map['lineas'] as List<dynamic>?)?.map((e) => LineaAlbaran.fromMap(e)).toList() ?? [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      iva: (map['iva'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      observaciones: map['observaciones'],
      metadatos: map['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_albaran': numeroAlbaran,
      'proveedor_id': proveedorId,
      'proveedor_nombre': proveedorNombre,
      'empresa_id': empresaId,
      'fecha_albaran': fechaAlbaran.toIso8601String(),
      'fecha_recepcion': fechaRecepcion.toIso8601String(),
      'fecha_registro': fechaRegistro.toIso8601String(),
      'fecha_procesado': fechaProcesado?.toIso8601String(),
      'estado': estado,
      'lineas': lineas.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'observaciones': observaciones,
      'metadatos': metadatos,
    };
  }

  // Getters para estado
  bool get estaPendiente => estado == 'pendiente';
  bool get estaProcesado => estado == 'procesado';
  bool get estaParcialment => estado == 'parcial';
  bool get estaCancelado => estado == 'cancelado';
  bool get esPendiente => estado == 'pendiente';

  String get estadoTexto {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'procesado':
        return 'Procesado';
      case 'parcial':
        return 'Parcial';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Color get colorEstado {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'procesado':
        return Colors.green;
      case 'parcial':
        return Colors.purple;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Getters para totales
  int get totalArticulos => lineas.fold(0, (sum, linea) => sum + linea.cantidad.toInt());
  int get articulosRecibidos => lineas.where((l) => l.cantidadRecibida > 0).length;

  String get subtotalFormateado => '€${subtotal.toStringAsFixed(2)}';
  String get totalFormateado => '€${total.toStringAsFixed(2)}';
  String get ivaFormateado => '€${(total - subtotal).toStringAsFixed(2)}';

  // Propiedades adicionales para compatibilidad
  DateTime get fecha => fechaAlbaran;

  AlbaranProveedor copyWith({
    String? id,
    String? numeroAlbaran,
    String? proveedorId,
    String? proveedorNombre,
    String? empresaId,
    DateTime? fechaAlbaran,
    DateTime? fechaRecepcion,
    DateTime? fechaRegistro,
    DateTime? fechaProcesado,
    String? estado,
    List<LineaAlbaran>? lineas,
    double? subtotal,
    double? iva,
    double? total,
    String? observaciones,
    Map<String, dynamic>? metadatos,
  }) {
    return AlbaranProveedor(
      id: id ?? this.id,
      numeroAlbaran: numeroAlbaran ?? this.numeroAlbaran,
      proveedorId: proveedorId ?? this.proveedorId,
      proveedorNombre: proveedorNombre ?? this.proveedorNombre,
      empresaId: empresaId ?? this.empresaId,
      fechaAlbaran: fechaAlbaran ?? this.fechaAlbaran,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaProcesado: fechaProcesado ?? this.fechaProcesado,
      estado: estado ?? this.estado,
      lineas: lineas ?? List.from(this.lineas),
      subtotal: subtotal ?? this.subtotal,
      iva: iva ?? this.iva,
      total: total ?? this.total,
      observaciones: observaciones ?? this.observaciones,
      metadatos: metadatos ?? Map.from(this.metadatos),
    );
  }
}

class LineaAlbaran {
  String articuloId;
  String articuloNombre;
  String articuloCodigo;
  String? codigoBarras;
  double cantidad;
  double cantidadRecibida;
  double precioUnitario;
  double subtotal;
  String? observaciones;

  LineaAlbaran({
    required this.articuloId,
    required this.articuloNombre,
    required this.articuloCodigo,
    this.codigoBarras,
    required this.cantidad,
    this.cantidadRecibida = 0.0,
    required this.precioUnitario,
    required this.subtotal,
    this.observaciones,
  });

  factory LineaAlbaran.fromMap(Map<String, dynamic> map) {
    return LineaAlbaran(
      articuloId: map['articulo_id'] ?? '',
      articuloNombre: map['articulo_nombre'] ?? '',
      articuloCodigo: map['articulo_codigo'] ?? map['codigo_barras'] ?? '',
      codigoBarras: map['codigo_barras'],
      cantidad: (map['cantidad'] ?? 0.0).toDouble(),
      cantidadRecibida: (map['cantidad_recibida'] ?? 0.0).toDouble(),
      precioUnitario: (map['precio_unitario'] ?? 0.0).toDouble(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      observaciones: map['observaciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articulo_id': articuloId,
      'articulo_nombre': articuloNombre,
      'articulo_codigo': articuloCodigo,
      'codigo_barras': codigoBarras,
      'cantidad': cantidad,
      'cantidad_recibida': cantidadRecibida,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      'observaciones': observaciones,
    };
  }

  bool get estaCompleta => cantidadRecibida >= cantidad;
  bool get estaPendiente => cantidadRecibida == 0;
  bool get esParcial => cantidadRecibida > 0 && cantidadRecibida < cantidad;

  double get totalLinea => cantidad * precioUnitario;

  LineaAlbaran copyWith({
    String? articuloId,
    String? articuloNombre,
    String? articuloCodigo,
    String? codigoBarras,
    double? cantidad,
    double? cantidadRecibida,
    double? precioUnitario,
    double? subtotal,
    String? observaciones,
  }) {
    return LineaAlbaran(
      articuloId: articuloId ?? this.articuloId,
      articuloNombre: articuloNombre ?? this.articuloNombre,
      articuloCodigo: articuloCodigo ?? this.articuloCodigo,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      cantidad: cantidad ?? this.cantidad,
      cantidadRecibida: cantidadRecibida ?? this.cantidadRecibida,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}