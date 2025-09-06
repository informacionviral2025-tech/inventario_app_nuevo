// lib/models/cliente.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String? firebaseId;
  final int? localId;
  final String nombre;
  final String? razonSocial;
  final String? nif;
  final String? direccion;
  final String? ciudad;
  final String? codigoPostal;
  final String? telefono;
  final String? email;
  final double limiteCredito;
  final int diasPago;
  final bool activo;
  final String empresaId;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final String? codigo;
  final String? provincia;
  final String? movil;
  final String? contacto;
  final String? observaciones;
  final double descuento;

  Cliente({
    this.firebaseId,
    this.localId,
    required this.nombre,
    this.razonSocial,
    this.nif,
    this.direccion,
    this.ciudad,
    this.codigoPostal,
    this.telefono,
    this.email,
    this.limiteCredito = 0.0,
    this.diasPago = 30,
    this.activo = true,
    required this.empresaId,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.codigo,
    this.provincia,
    this.movil,
    this.contacto,
    this.observaciones,
    this.descuento = 0.0,
  });

  String get id => firebaseId ?? localId?.toString() ?? '';

  factory Cliente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cliente(
      firebaseId: doc.id,
      nombre: data['nombre'] ?? '',
      razonSocial: data['razonSocial'],
      nif: data['nif'],
      direccion: data['direccion'],
      ciudad: data['ciudad'],
      codigoPostal: data['codigoPostal'],
      telefono: data['telefono'],
      email: data['email'],
      limiteCredito: (data['limiteCredito'] ?? 0.0).toDouble(),
      diasPago: data['diasPago'] ?? 30,
      activo: data['activo'] ?? true,
      empresaId: data['empresaId'] ?? '',
      fechaCreacion: data['fechaCreacion'] is Timestamp
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.parse(data['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: data['fechaActualizacion'] is Timestamp
          ? (data['fechaActualizacion'] as Timestamp).toDate()
          : DateTime.parse(data['fechaActualizacion'] ?? DateTime.now().toIso8601String()),
      codigo: data['codigo'],
      provincia: data['provincia'],
      movil: data['movil'],
      contacto: data['contacto'],
      observaciones: data['observaciones'],
      descuento: (data['descuento'] ?? 0.0).toDouble(),
    );
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      localId: map['id'],
      firebaseId: map['firebase_id'],
      nombre: map['nombre'] ?? '',
      razonSocial: map['razon_social'],
      nif: map['nif'],
      direccion: map['direccion'],
      ciudad: map['ciudad'],
      codigoPostal: map['codigo_postal'],
      telefono: map['telefono'],
      email: map['email'],
      limiteCredito: (map['limite_credito'] ?? 0.0).toDouble(),
      diasPago: map['dias_pago'] ?? 30,
      activo: (map['activo'] ?? 1) == 1,
      empresaId: map['empresa_id'] ?? '',
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion'] ?? DateTime.now().toIso8601String()),
      codigo: map['codigo'],
      provincia: map['provincia'],
      movil: map['movil'],
      contacto: map['contacto'],
      observaciones: map['observaciones'],
      descuento: (map['descuento'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'razonSocial': razonSocial,
      'nif': nif,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigoPostal': codigoPostal,
      'telefono': telefono,
      'email': email,
      'limiteCredito': limiteCredito,
      'diasPago': diasPago,
      'activo': activo,
      'empresaId': empresaId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
      'codigo': codigo,
      'provincia': provincia,
      'movil': movil,
      'contacto': contacto,
      'observaciones': observaciones,
      'descuento': descuento,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': localId,
      'firebase_id': firebaseId,
      'nombre': nombre,
      'razon_social': razonSocial,
      'nif': nif,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigo_postal': codigoPostal,
      'telefono': telefono,
      'email': email,
      'limite_credito': limiteCredito,
      'dias_pago': diasPago,
      'activo': activo ? 1 : 0,
      'empresa_id': empresaId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
      'codigo': codigo,
      'provincia': provincia,
      'movil': movil,
      'contacto': contacto,
      'observaciones': observaciones,
      'descuento': descuento,
    };
  }

  Cliente copyWith({
    String? firebaseId,
    int? localId,
    String? nombre,
    String? razonSocial,
    String? nif,
    String? direccion,
    String? ciudad,
    String? codigoPostal,
    String? telefono,
    String? email,
    double? limiteCredito,
    int? diasPago,
    bool? activo,
    String? empresaId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? codigo,
    String? provincia,
    String? movil,
    String? contacto,
    String? observaciones,
    double? descuento,
  }) {
    return Cliente(
      firebaseId: firebaseId ?? this.firebaseId,
      localId: localId ?? this.localId,
      nombre: nombre ?? this.nombre,
      razonSocial: razonSocial ?? this.razonSocial,
      nif: nif ?? this.nif,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      limiteCredito: limiteCredito ?? this.limiteCredito,
      diasPago: diasPago ?? this.diasPago,
      activo: activo ?? this.activo,
      empresaId: empresaId ?? this.empresaId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      codigo: codigo ?? this.codigo,
      provincia: provincia ?? this.provincia,
      movil: movil ?? this.movil,
      contacto: contacto ?? this.contacto,
      observaciones: observaciones ?? this.observaciones,
      descuento: descuento ?? this.descuento,
    );
  }
}