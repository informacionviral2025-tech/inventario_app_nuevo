import 'package:cloud_firestore/cloud_firestore.dart';

class Empresa {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? telefono;
  final String? email;
  final DateTime fechaCreacion;
  final bool activa;
  final String? cif;
  final String? ciudad;
  final String? codigoPostal;
  final String? provincia;
  final String? pais;
  final String? web;
  final String? logoUrl;

  Empresa({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.telefono,
    this.email,
    required this.fechaCreacion,
    this.activa = true,
    this.cif,
    this.ciudad,
    this.codigoPostal,
    this.provincia,
    this.pais,
    this.web,
    this.logoUrl,
  });

  /// Convertir desde DocumentSnapshot de Firestore
  factory Empresa.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      throw Exception('El documento ${doc.id} no contiene datos');
    }

    return Empresa.fromMap(doc.id, data);
  }

  /// Convertir desde Map (Firebase)
  factory Empresa.fromMap(String id, Map<String, dynamic> map) {
    DateTime fecha;
    final rawFecha = map['fechaCreacion'];

    if (rawFecha is Timestamp) {
      fecha = rawFecha.toDate();
    } else if (rawFecha is String) {
      fecha = DateTime.tryParse(rawFecha) ?? DateTime.now();
    } else if (rawFecha is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(rawFecha);
    } else {
      fecha = DateTime.now();
    }

    return Empresa(
      id: id,
      nombre: (map['nombre'] ?? '').toString().trim().isEmpty
          ? 'Sin nombre'
          : map['nombre'],
      descripcion: map['descripcion'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      email: map['email'],
      fechaCreacion: fecha,
      activa: (map['activa'] is bool)
          ? map['activa']
          : (map['activa'] == 1 || map['activa'] == true),
      cif: map['cif'],
      ciudad: map['ciudad'],
      codigoPostal: map['codigoPostal'],
      provincia: map['provincia'],
      pais: map['pais'] ?? 'España',
      web: map['web'],
      logoUrl: map['logoUrl'],
    );
  }

  /// Convertir a Map (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'activa': activa,
      'cif': cif,
      'ciudad': ciudad,
      'codigoPostal': codigoPostal,
      'provincia': provincia,
      'pais': pais,
      'web': web,
      'logoUrl': logoUrl,
    };
  }

  /// Crear una nueva empresa
  factory Empresa.nueva({
    required String nombre,
    String? descripcion,
    String? direccion,
    String? telefono,
    String? email,
    String? cif,
    String? ciudad,
    String? codigoPostal,
    String? provincia,
    String? pais,
    String? web,
    String? logoUrl,
  }) {
    return Empresa(
      id: '',
      nombre: nombre.trim().isEmpty ? 'Sin nombre' : nombre,
      descripcion: descripcion,
      direccion: direccion,
      telefono: telefono,
      email: email,
      fechaCreacion: DateTime.now(),
      activa: true,
      cif: cif,
      ciudad: ciudad,
      codigoPostal: codigoPostal,
      provincia: provincia,
      pais: pais,
      web: web,
      logoUrl: logoUrl,
    );
  }

  /// Crear copia de la empresa
  Empresa copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? direccion,
    String? telefono,
    String? email,
    DateTime? fechaCreacion,
    bool? activa,
    String? cif,
    String? ciudad,
    String? codigoPostal,
    String? provincia,
    String? pais,
    String? web,
    String? logoUrl,
  }) {
    return Empresa(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activa: activa ?? this.activa,
      cif: cif ?? this.cif,
      ciudad: ciudad ?? this.ciudad,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      provincia: provincia ?? this.provincia,
      pais: pais ?? this.pais,
      web: web ?? this.web,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  // Validaciones
  bool get esValida => nombre.trim().isNotEmpty;
  
  bool get tieneDireccionCompleta => 
      direccion != null && 
      direccion!.isNotEmpty && 
      ciudad != null && 
      ciudad!.isNotEmpty && 
      codigoPostal != null && 
      codigoPostal!.isNotEmpty;
  
  bool get tieneContacto => 
      (telefono != null && telefono!.isNotEmpty) || 
      (email != null && email!.isNotEmpty);
  
  bool get cifValido {
    if (cif == null || cif!.isEmpty) return true;
    return _validarCIF(cif!);
  }
  
  bool _validarCIF(String cif) {
    // Implementación básica de validación de CIF
    final regex = RegExp(r'^[ABCDEFGHJKLMNPQRSUVW]\d{7}[0-9A-J]$');
    return regex.hasMatch(cif.toUpperCase());
  }

  // Métodos de utilidad
  String get direccionCompleta {
    final parts = [
      direccion,
      codigoPostal,
      ciudad,
      provincia,
      pais
    ].where((part) => part != null && part.isNotEmpty).toList();
    
    return parts.join(', ');
  }

  String get contactoPrincipal {
    if (telefono != null && telefono!.isNotEmpty) return telefono!;
    if (email != null && email!.isNotEmpty) return email!;
    return 'Sin contacto';
  }

  @override
  String toString() {
    return 'Empresa{id: $id, nombre: $nombre, activa: $activa}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Empresa &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}