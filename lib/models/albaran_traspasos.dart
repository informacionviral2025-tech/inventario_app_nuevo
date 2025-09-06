import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaranTraspasos {
  final String id;
  final String numero;
  final DateTime fecha;
  final Map<String, dynamic> origen;
  final Map<String, dynamic> destino;
  final Map<String, int> articulos;
  final String usuario;
  final String estado;
  final String traspasoId;
  final String observaciones;

  AlbaranTraspasos({
    required this.id,
    required this.numero,
    required this.fecha,
    required this.origen,
    required this.destino,
    required this.articulos,
    required this.usuario,
    this.estado = "pendiente",
    required this.traspasoId,
    this.observaciones = '',
  });

  Map<String, dynamic> toMap() {
    return {
      "numero": numero,
      "fecha": fecha.toIso8601String(),
      "origen": origen,
      "destino": destino,
      "articulos": articulos,
      "usuario": usuario,
      "estado": estado,
      "traspasoId": traspasoId,
      'observaciones': observaciones,
    };
  }

  factory AlbaranTraspasos.fromMap(String id, Map<String, dynamic> map) {
    return AlbaranTraspasos(
      id: id,
      numero: map["numero"] ?? "",
      fecha: DateTime.parse(map["fecha"]),
      origen: Map<String, dynamic>.from(map["origen"] ?? {}),
      destino: Map<String, dynamic>.from(map["destino"] ?? {}),
      articulos: Map<String, int>.from(map["articulos"] ?? {}),
      usuario: map["usuario"] ?? "",
      estado: map["estado"] ?? "pendiente",
      traspasoId: map["traspasoId"] ?? "",
      observaciones: map['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "numero": numero,
      "fecha": Timestamp.fromDate(fecha),
      "origen": origen,
      "destino": destino,
      "articulos": articulos,
      "usuario": usuario,
      "estado": estado,
      "traspasoId": traspasoId,
      'observaciones': observaciones,
    };
  }

  factory AlbaranTraspasos.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlbaranTraspasos.fromMap(doc.id, data);
  }

  bool get esValido {
    if (numero.isEmpty) return false;
    if (origen['id'] == null || destino['id'] == null) return false;
    if (articulos.isEmpty) return false;
    if (usuario.isEmpty) return false;
    if (traspasoId.isEmpty) return false;
    return true;
  }

  bool get estaConfirmado => estado == "confirmado";
  bool get estaPendiente => estado == "pendiente";
  bool get estaDevuelto => estado == "devuelto";

  int get cantidadTotalArticulos {
    return articulos.values.fold(0, (sum, cantidad) => sum + cantidad);
  }

  String get estadoDisplay {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmado':
        return 'Confirmado';
      case 'devuelto':
        return 'Devuelto';
      default:
        return estado;
    }
  }

  AlbaranTraspasos copyWith({
    String? id,
    String? numero,
    DateTime? fecha,
    Map<String, dynamic>? origen,
    Map<String, dynamic>? destino,
    Map<String, int>? articulos,
    String? usuario,
    String? estado,
    String? traspasoId,
    String? observaciones,
  }) {
    return AlbaranTraspasos(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      fecha: fecha ?? this.fecha,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      articulos: articulos ?? this.articulos,
      usuario: usuario ?? this.usuario,
      estado: estado ?? this.estado,
      traspasoId: traspasoId ?? this.traspasoId,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  String toString() {
    return 'AlbaranTraspasos{id: $id, numero: $numero, origen: ${origen['nombre']}, destino: ${destino['nombre']}}';
  }
}