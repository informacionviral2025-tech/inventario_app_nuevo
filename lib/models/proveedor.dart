// lib/models/proveedor.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Proveedor {
  final String? id;
  final String nombre;
  final String? rfc;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? contacto;
  final String? notas; // ¡Propiedad agregada!
  final bool activo;
  final DateTime fechaCreacion;

  const Proveedor({
    this.id,
    required this.nombre,
    this.rfc,
    this.email,
    this.telefono,
    this.direccion,
    this.contacto,
    this.notas, // ¡Parámetro agregado!
    this.activo = true,
    required this.fechaCreacion,
  });

  // Crear desde Firestore
  factory Proveedor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Proveedor(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      rfc: data['rfc'],
      email: data['email'],
      telefono: data['telefono'],
      direccion: data['direccion'],
      contacto: data['contacto'],
      notas: data['notas'], // ¡Campo agregado!
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Crear desde Map
  factory Proveedor.fromMap(Map<String, dynamic> data, String id) {
    return Proveedor(
      id: id,
      nombre: data['nombre'] ?? '',
      rfc: data['rfc'],
      email: data['email'],
      telefono: data['telefono'],
      direccion: data['direccion'],
      contacto: data['contacto'],
      notas: data['notas'], // ¡Campo agregado!
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'rfc': rfc,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'contacto': contacto,
      'notas': notas, // ¡Campo agregado!
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'rfc': rfc,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'contacto': contacto,
      'notas': notas, // ¡Campo agregado!
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Crear copia con cambios
  Proveedor copyWith({
    String? id,
    String? nombre,
    String? rfc,
    String? email,
    String? telefono,
    String? direccion,
    String? contacto,
    String? notas, // ¡Parámetro agregado!
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rfc: rfc ?? this.rfc,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      contacto: contacto ?? this.contacto,
      notas: notas ?? this.notas, // ¡Campo agregado!
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Validaciones
  bool get esValido => nombre.trim().isNotEmpty;
  
  bool get tieneRFC => rfc != null && rfc!.isNotEmpty;
  
  bool get tieneEmail => email != null && email!.isNotEmpty && 
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!);
  
  bool get tieneTelefono => telefono != null && telefono!.isNotEmpty;
  
  bool get tieneDireccion => direccion != null && direccion!.isNotEmpty;
  
  bool get tieneContacto => contacto != null && contacto!.isNotEmpty;
  
  bool get tieneNotas => notas != null && notas!.trim().isNotEmpty; // ¡Validación agregada!

  @override
  String toString() {
    return 'Proveedor{id: $id, nombre: $nombre, rfc: $rfc, email: $email, activo: $activo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Proveedor &&
        other.id == id &&
        other.nombre == nombre &&
        other.rfc == rfc &&
        other.email == email &&
        other.telefono == telefono &&
        other.direccion == direccion &&
        other.contacto == contacto &&
        other.notas == notas && // ¡Campo agregado!
        other.activo == activo;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombre,
      rfc,
      email,
      telefono,
      direccion,
      contacto,
      notas, // ¡Campo agregado!
      activo,
    );
  }
}