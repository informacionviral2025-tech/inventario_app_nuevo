import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/albaran_proveedor.dart';
import '../models/articulo.dart';

class AlbaranProveedorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene todos los albaranes de una empresa
  Stream<List<AlbaranProveedor>> getAlbaranes(String empresaId) {
    return _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('albaranes_proveedor')
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlbaranProveedor.fromFirestore(doc)).toList());
  }

  /// Obtiene un albarán específico
  Future<AlbaranProveedor?> getAlbaran(String empresaId, String albaranId) async {
    try {
      final doc = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .doc(albaranId)
          .get();

      if (doc.exists) {
        return AlbaranProveedor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener albarán: $e');
    }
  }

  /// Crea un nuevo albarán
  Future<String> crearAlbaran(String empresaId, AlbaranProveedor albaran) async {
    try {
      // Verificar que el número de albarán no exista
      final existeNumero = await _verificarNumeroAlbaran(empresaId, albaran.numeroAlbaran);
      if (existeNumero) {
        throw Exception('Ya existe un albarán con el número ${albaran.numeroAlbaran}');
      }

      final docRef = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .add(albaran.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear albarán: $e');
    }
  }

  /// Actualiza un albarán existente
  Future<void> actualizarAlbaran(String empresaId, AlbaranProveedor albaran) async {
    try {
      if (albaran.id == null || albaran.id!.isEmpty) {
        throw Exception('ID de albarán requerido para actualizar');
      }

      // Si está procesado, no permitir edición
      if (albaran.estaProcesado) {
        throw Exception('No se puede editar un albarán procesado');
      }

      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .doc(albaran.id)
          .update(albaran.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar albarán: $e');
    }
  }

  /// Procesa un albarán (actualiza stock de artículos)
  Future<void> procesarAlbaran(String empresaId, String albaranId) async {
    try {
      final albaran = await getAlbaran(empresaId, albaranId);
      if (albaran == null) {
        throw Exception('Albarán no encontrado');
      }

      if (albaran.estaProcesado) {
        throw Exception('El albarán ya está procesado');
      }

      // Usar transacción para garantizar consistencia
      await _firestore.runTransaction((transaction) async {
        // Actualizar stock de cada artículo
        for (final linea in albaran.lineas) {
          final articuloRef = _firestore
              .collection('empresas')
              .doc(empresaId)
              .collection('articulos')
              .doc(linea.articuloId);

          final articuloDoc = await transaction.get(articuloRef);
          if (!articuloDoc.exists) {
            throw Exception('Artículo ${linea.articuloNombre} no encontrado');
          }

          final articulo = Articulo.fromFirestore(articuloDoc);
          final nuevoStock = articulo.stock + linea.cantidad.toInt();

          // Actualizar stock y fecha de actualización
          transaction.update(articuloRef, {
            'stock': nuevoStock,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          });
        }

        // Actualizar estado del albarán
        final albaranRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('albaranes_proveedor')
            .doc(albaranId);

        transaction.update(albaranRef, {
          'estado': 'procesado',
          'fechaProcesado': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Error al procesar albarán: $e');
    }
  }

  /// Cancela un albarán
  Future<void> cancelarAlbaran(String empresaId, String albaranId) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .doc(albaranId)
          .update({
        'estado': 'cancelado',
        'fechaCancelacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al cancelar albarán: $e');
    }
  }

  /// Elimina un albarán (solo si está pendiente)
  Future<void> eliminarAlbaran(String empresaId, String albaranId) async {
    try {
      final albaran = await getAlbaran(empresaId, albaranId);
      if (albaran == null) {
        throw Exception('Albarán no encontrado');
      }

      if (albaran.estaProcesado) {
        throw Exception('No se puede eliminar un albarán procesado');
      }

      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .doc(albaranId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar albarán: $e');
    }
  }

  /// Obtiene estadísticas de albaranes
  Future<Map<String, dynamic>> getEstadisticas(String empresaId, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      Query query = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor');

      if (fechaInicio != null) {
        query = query.where('fechaAlbaran', isGreaterThanOrEqualTo: fechaInicio);
      }

      if (fechaFin != null) {
        query = query.where('fechaAlbaran', isLessThanOrEqualTo: fechaFin);
      }

      final snapshot = await query.get();
      final albaranes = snapshot.docs.map((doc) => AlbaranProveedor.fromFirestore(doc)).toList();

      final pendientes = albaranes.where((a) => a.estaPendiente).length;
      final procesados = albaranes.where((a) => a.estaProcesado).length;
      final cancelados = albaranes.where((a) => a.estaCancelado).length;

      final totalImporte = albaranes
          .where((a) => a.estaProcesado)
          .fold(0.0, (sum, a) => sum + a.total);

      final totalArticulos = albaranes
          .where((a) => a.estaProcesado)
          .fold(0, (sum, a) => sum + a.totalArticulos);

      return {
        'total': albaranes.length,
        'pendientes': pendientes,
        'procesados': procesados,
        'cancelados': cancelados,
        'totalImporte': totalImporte,
        'totalArticulos': totalArticulos,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Obtiene albaranes por proveedor
  Stream<List<AlbaranProveedor>> getAlbaranesPorProveedor(
    String empresaId,
    String proveedorId,
  ) {
    return _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('albaranes_proveedor')
        .where('proveedorId', isEqualTo: proveedorId)
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlbaranProveedor.fromFirestore(doc)).toList());
  }

  /// Obtiene albaranes por estado
  Stream<List<AlbaranProveedor>> getAlbaranesPorEstado(
    String empresaId,
    String estado,
  ) {
    return _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('albaranes_proveedor')
        .where('estado', isEqualTo: estado)
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlbaranProveedor.fromFirestore(doc)).toList());
  }

  /// Busca albaranes por número
  Future<List<AlbaranProveedor>> buscarAlbaranesPorNumero(
    String empresaId,
    String numeroAlbaran,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('albaranes_proveedor')
          .where('numeroAlbaran', isGreaterThanOrEqualTo: numeroAlbaran)
          .where('numeroAlbaran', isLessThan: numeroAlbaran + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) => AlbaranProveedor.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error en búsqueda: $e');
    }
  }

  /// Verifica si existe un número de albarán
  Future<bool> _verificarNumeroAlbaran(String empresaId, String numeroAlbaran) async {
    final snapshot = await _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('albaranes_proveedor')
        .where('numeroAlbaran', isEqualTo: numeroAlbaran)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Genera un número de albarán único
  Future<String> generarNumeroAlbaran(String empresaId) async {
    final ahora = DateTime.now();
    final base = 'ALB${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}';
    
    int contador = 1;
    String numeroAlbaran;
    
    do {
      numeroAlbaran = '$base-${contador.toString().padLeft(3, '0')}';
      final existe = await _verificarNumeroAlbaran(empresaId, numeroAlbaran);
      if (!existe) break;
      contador++;
    } while (contador <= 999);

    if (contador > 999) {
      throw Exception('No se puede generar un número único para hoy');
    }

    return numeroAlbaran;
  }

  /// Obtiene el último número de albarán para sugerir el siguiente
  Future<String> sugerirProximoNumero(String empresaId) async {
    try {
      return await generarNumeroAlbaran(empresaId);
    } catch (e) {
      // Fallback: usar timestamp
      final ahora = DateTime.now();
      return 'ALB${ahora.millisecondsSinceEpoch}';
    }
  }
}