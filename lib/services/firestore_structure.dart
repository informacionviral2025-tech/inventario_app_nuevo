// lib/services/firestore_structure.dart
class FirestoreStructure {
  /// Colección raíz
  static const String coleccionEmpresas = 'empresas';

  /// Subcolecciones por empresa
  static String articulos(String empresaId) => 
      '$coleccionEmpresas/$empresaId/articulos';
  
  static String obras(String empresaId) => 
      '$coleccionEmpresas/$empresaId/obras';
  
  static String traspasos(String empresaId) => 
      '$coleccionEmpresas/$empresaId/traspasos';
  
  static String albaranes(String empresaId) => 
      '$coleccionEmpresas/$empresaId/albaranes';
  
  static String usuarios(String empresaId) => 
      '$coleccionEmpresas/$empresaId/usuarios';

  /// Campos comunes
  static const String campoFechaCreacion = 'fechaCreacion';
  static const String campoNombre = 'nombre';
  static const String campoEmpresaId = 'empresaId';
}