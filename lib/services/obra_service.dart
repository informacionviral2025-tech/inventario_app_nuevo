// services/obra_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/obra.dart';

class ObraService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ObraService(this.empresaId);

  // Obtener todas las obras de la empresa
  Stream<List<Obra>> getObras() {
    return _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('obras')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Obra.fromFirestore(doc)).toList());
  }

  // Obtener obras por estado
  Stream<List<Obra>> getObrasPorEstado(String estado) {
    return _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('obras')
        .where('estado', isEqualTo: estado)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Obra.fromFirestore(doc)).toList());
  }

  // Obtener obras activas
  Stream<List<Obra>> getObrasActivas() {
    return getObrasPorEstado('activa');
  }

  // Obtener una obra específica
  Future<Obra?> getObra(String obraId) async {
    try {
      final doc = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId)
          .get();
      if (doc.exists) {
        return Obra.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener obra: $e');
    }
  }

  // Crear nueva obra
  Future<String> crearObra(Obra obra) async {
    try {
      final docRef = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .add(obra.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear obra: $e');
    }
  }

  // Actualizar obra
  Future<void> actualizarObra(Obra obra) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obra.id)
          .update(obra.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar obra: $e');
    }
  }

  // Cambiar estado de obra
  Future<void> cambiarEstadoObra(String obraId, String nuevoEstado) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId)
          .update({
        'estado': nuevoEstado,
      });
    } catch (e) {
      throw Exception('Error al cambiar estado: $e');
    }
  }

  // Eliminar obra
  Future<void> eliminarObra(String obraId) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar obra: $e');
    }
  }

  // Obtener inventario de una obra
  Future<Map<String, dynamic>> getInventarioObra(String obraId) async {
    try {
      final obra = await getObra(obraId);
      return obra?.stock ?? {};
    } catch (e) {
      throw Exception('Error al obtener inventario: $e');
    }
  }

  // Agregar stock a una obra
  Future<void> agregarStockObra(String obraId, String articuloId, int cantidad) async {
    try {
      final obraRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId);
      
      await _firestore.runTransaction((transaction) async {
        final obraDoc = await transaction.get(obraRef);
        
        if (!obraDoc.exists) {
          throw Exception('La obra no existe');
        }

        final obra = Obra.fromFirestore(obraDoc);
        final stockActual = Map<String, dynamic>.from(obra.stock);
        
        if (stockActual.containsKey(articuloId)) {
          final stockInfo = stockActual[articuloId] as Map<String, dynamic>;
          stockInfo['cantidad'] = (stockInfo['cantidad'] as int? ?? 0) + cantidad;
          stockInfo['fechaActualizacion'] = FieldValue.serverTimestamp();
        } else {
          stockActual[articuloId] = {
            'cantidad': cantidad,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          };
        }

        transaction.update(obraRef, {'stock': stockActual});
      });
    } catch (e) {
      throw Exception('Error al agregar stock: $e');
    }
  }

  // Reducir stock de una obra
  Future<void> reducirStockObra(String obraId, String articuloId, int cantidad) async {
    try {
      final obraRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId);
      
      await _firestore.runTransaction((transaction) async {
        final obraDoc = await transaction.get(obraRef);
        
        if (!obraDoc.exists) {
          throw Exception('La obra no existe');
        }

        final obra = Obra.fromFirestore(obraDoc);
        final stockActual = Map<String, dynamic>.from(obra.stock);
        
        if (stockActual.containsKey(articuloId)) {
          final stockInfo = stockActual[articuloId] as Map<String, dynamic>;
          final cantidadActual = stockInfo['cantidad'] as int? ?? 0;
          final nuevaCantidad = cantidadActual - cantidad;
          
          if (nuevaCantidad <= 0) {
            stockActual.remove(articuloId);
          } else {
            stockInfo['cantidad'] = nuevaCantidad;
            stockInfo['fechaActualizacion'] = FieldValue.serverTimestamp();
          }

          transaction.update(obraRef, {'stock': stockActual});
        }
      });
    } catch (e) {
      throw Exception('Error al reducir stock: $e');
    }
  }

  // Actualizar stock de una obra (cantidad absoluta)
  Future<void> actualizarStockObra(String obraId, String articuloId, int nuevaCantidad) async {
    try {
      final obraRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .doc(obraId);
      
      await _firestore.runTransaction((transaction) async {
        final obraDoc = await transaction.get(obraRef);
        
        if (!obraDoc.exists) {
          throw Exception('La obra no existe');
        }

        final obra = Obra.fromFirestore(obraDoc);
        final stockActual = Map<String, dynamic>.from(obra.stock);
        
        if (nuevaCantidad <= 0) {
          stockActual.remove(articuloId);
        } else {
          stockActual[articuloId] = {
            'cantidad': nuevaCantidad,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          };
        }

        transaction.update(obraRef, {'stock': stockActual});
      });
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  // Transferir stock entre obras
  Future<void> transferirStock(
    String obraOrigenId,
    String obraDestinoId,
    String articuloId,
    int cantidad,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final obraOrigenRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('obras')
            .doc(obraOrigenId);
        final obraDestinoRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('obras')
            .doc(obraDestinoId);
        
        final obraOrigenDoc = await transaction.get(obraOrigenRef);
        final obraDestinoDoc = await transaction.get(obraDestinoRef);
        
        if (!obraOrigenDoc.exists || !obraDestinoDoc.exists) {
          throw Exception('Una o ambas obras no existen');
        }

        final obraOrigen = Obra.fromFirestore(obraOrigenDoc);
        final obraDestino = Obra.fromFirestore(obraDestinoDoc);
        
        // Verificar stock disponible en origen
        final cantidadDisponible = obraOrigen.getCantidadArticulo(articuloId);
        if (cantidadDisponible < cantidad) {
          throw Exception('Stock insuficiente en la obra origen');
        }

        // Actualizar stock en origen
        final stockOrigen = Map<String, dynamic>.from(obraOrigen.stock);
        final stockInfoOrigen = stockOrigen[articuloId] as Map<String, dynamic>;
        final nuevaCantidadOrigen = (stockInfoOrigen['cantidad'] as int) - cantidad;
        
        if (nuevaCantidadOrigen <= 0) {
          stockOrigen.remove(articuloId);
        } else {
          stockInfoOrigen['cantidad'] = nuevaCantidadOrigen;
          stockInfoOrigen['fechaActualizacion'] = FieldValue.serverTimestamp();
        }

        // Actualizar stock en destino
        final stockDestino = Map<String, dynamic>.from(obraDestino.stock);
        if (stockDestino.containsKey(articuloId)) {
          final stockInfoDestino = stockDestino[articuloId] as Map<String, dynamic>;
          stockInfoDestino['cantidad'] = (stockInfoDestino['cantidad'] as int? ?? 0) + cantidad;
          stockInfoDestino['fechaActualizacion'] = FieldValue.serverTimestamp();
        } else {
          stockDestino[articuloId] = {
            'cantidad': cantidad,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          };
        }

        // Aplicar cambios
        transaction.update(obraOrigenRef, {'stock': stockOrigen});
        transaction.update(obraDestinoRef, {'stock': stockDestino});
      });
    } catch (e) {
      throw Exception('Error al transferir stock: $e');
    }
  }

  // Obtener estadísticas de la empresa
  Future<Map<String, int>> getEstadisticasObras() async {
    try {
      final snapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('obras')
          .get();

      int total = snapshot.docs.length;
      int activas = 0;
      int pausadas = 0;
      int finalizadas = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final estado = data['estado'] ?? 'activa';
        
        switch (estado) {
          case 'activa':
            activas++;
            break;
          case 'pausada':
            pausadas++;
            break;
          case 'finalizada':
            finalizadas++;
            break;
        }
      }

      return {
        'total': total,
        'activas': activas,
        'pausadas': pausadas,
        'finalizadas': finalizadas,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Obtener estadísticas de una obra específica
  Future<Map<String, dynamic>> getEstadisticasObra(String empresaId, String obraId) async {
    try {
      // Implementación de ejemplo; reemplazar con la lógica real si existe
      return {
        'tareasCompletadas': 0,
        'totalTareas': 0,
        'materialesUsados': 0,
        'costeTotal': 0.0,
        'horasTrabajadas': 0,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas de obra: $e');
    }
  }
}