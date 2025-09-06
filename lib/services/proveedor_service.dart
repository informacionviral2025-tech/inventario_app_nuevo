// lib/services/proveedor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proveedor.dart';

class ProveedorService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProveedorService(this.empresaId);

  CollectionReference get _collection =>
      _firestore.collection('empresas').doc(empresaId).collection('proveedores');

  // Obtener todos los proveedores como Stream
  Stream<List<Proveedor>> getProveedores() {
    return _collection
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Proveedor.fromFirestore(doc)).toList();
    });
  }

  // Obtener solo proveedores activos como Stream
  Stream<List<Proveedor>> getProveedoresActivos() {
    return _collection
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Proveedor.fromFirestore(doc)).toList();
    });
  }

  // Obtener un proveedor específico
  Future<Proveedor?> obtenerProveedor(String proveedorId) async {
    try {
      final doc = await _collection.doc(proveedorId).get();
      if (!doc.exists) return null;
      return Proveedor.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener proveedor: $e');
      return null;
    }
  }

  // Agregar nuevo proveedor
  Future<String> agregarProveedor(Proveedor proveedor) async {
    try {
      final docRef = await _collection.add(proveedor.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error al agregar proveedor: $e');
      rethrow;
    }
  }

  // Actualizar proveedor existente
  Future<void> actualizarProveedor(Proveedor proveedor) async {
    try {
      await _collection.doc(proveedor.id).update(proveedor.toFirestore());
    } catch (e) {
      print('Error al actualizar proveedor: $e');
      rethrow;
    }
  }

  // Eliminar proveedor
  Future<void> eliminarProveedor(String proveedorId) async {
    try {
      await _collection.doc(proveedorId).delete();
    } catch (e) {
      print('Error al eliminar proveedor: $e');
      rethrow;
    }
  }

  // Cambiar estado del proveedor (activar/desactivar)
  Future<void> cambiarEstadoProveedor(String proveedorId, bool activo) async {
    try {
      await _collection.doc(proveedorId).update({'activo': activo});
    } catch (e) {
      print('Error al cambiar estado del proveedor: $e');
      rethrow;
    }
  }

  // Buscar proveedores por nombre
  Future<List<Proveedor>> buscarProveedoresPorNombre(String nombre) async {
    try {
      final query = await _collection
          .where('nombre', isGreaterThanOrEqualTo: nombre)
          .where('nombre', isLessThan: nombre + 'z')
          .orderBy('nombre')
          .get();
      
      return query.docs.map((doc) => Proveedor.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al buscar proveedores: $e');
      return [];
    }
  }

  // Verificar si existe un proveedor con el mismo RFC
  Future<bool> existeProveedorConRFC(String rfc, {String? excluirId}) async {
    try {
      var query = _collection.where('rfc', isEqualTo: rfc.toUpperCase());
      final result = await query.get();
      
      if (excluirId != null) {
        // Excluir el proveedor actual en caso de edición
        return result.docs.any((doc) => doc.id != excluirId);
      }
      
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar RFC: $e');
      return false;
    }
  }

  // Obtener estadísticas de proveedores
  Future<Map<String, int>> obtenerEstadisticas() async {
    try {
      final snapshot = await _collection.get();
      final total = snapshot.docs.length;
      final activos = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['activo'] ?? true;
      }).length;
      
      return {
        'total': total,
        'activos': activos,
        'inactivos': total - activos,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {'total': 0, 'activos': 0, 'inactivos': 0};
    }
  }
}