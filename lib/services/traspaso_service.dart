// lib/service/traspaso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/traspaso.dart';

class TraspasoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _collection;

  TraspasoService() {
    _collection = _firestore.collection('traspasos');
  }

  // Crear un nuevo traspaso
  Future<String> crearTraspaso(Traspaso traspaso) async {
    try {
      final docRef = await _collection.add(traspaso.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear traspaso: $e');
    }
  }

  // Obtener traspasos de una empresa
  Future<List<Traspaso>> getTraspasos(String empresaId) async {
    try {
      final querySnapshot = await _collection
          .where('empresaId', isEqualTo: empresaId)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Traspaso.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos: $e');
    }
  }

  // Obtener un traspaso por ID
  Future<Traspaso?> getTraspasoById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return Traspaso.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener traspaso: $e');
    }
  }

  // Actualizar estado del traspaso
  Future<void> actualizarEstado(String id, EstadoTraspaso nuevoEstado) async {
    try {
      await _collection.doc(id).update({
        'estado': nuevoEstado.name,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  // Confirmar envío del traspaso
  Future<void> confirmarEnvio(String id, String albaranId) async {
    try {
      await _collection.doc(id).update({
        'estado': EstadoTraspaso.enviado.name,
        'albaranId': albaranId,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al confirmar envío: $e');
    }
  }

  // Confirmar recepción del traspaso
  Future<void> confirmarRecepcion(String albaranId) async {
    try {
      // Buscar el traspaso por albaranId
      final querySnapshot = await _collection
          .where('albaranId', isEqualTo: albaranId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'estado': EstadoTraspaso.recibido.name,
          'fechaConfirmacion': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('No se encontró traspaso con albarán: $albaranId');
      }
    } catch (e) {
      throw Exception('Error al confirmar recepción: $e');
    }
  }

  // Completar traspaso
  Future<void> completarTraspaso(String id) async {
    try {
      await _collection.doc(id).update({
        'estado': EstadoTraspaso.completado.name,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al completar traspaso: $e');
    }
  }

  // Cancelar traspaso
  Future<void> cancelarTraspaso(String id, String motivo) async {
    try {
      await _collection.doc(id).update({
        'estado': EstadoTraspaso.cancelado.name,
        'observaciones': motivo,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al cancelar traspaso: $e');
    }
  }

  // Obtener traspasos por estado
  Future<List<Traspaso>> getTraspasosByEstado(String empresaId, EstadoTraspaso estado) async {
    try {
      final querySnapshot = await _collection
          .where('empresaId', isEqualTo: empresaId)
          .where('estado', isEqualTo: estado.name)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Traspaso.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos por estado: $e');
    }
  }

  // Obtener traspasos pendientes
  Future<List<Traspaso>> getTraspasosPendientes(String empresaId) async {
    return getTraspasosByEstado(empresaId, EstadoTraspaso.pendiente);
  }

  // Obtener traspasos enviados
  Future<List<Traspaso>> getTraspasosenviados(String empresaId) async {
    return getTraspasosByEstado(empresaId, EstadoTraspaso.enviado);
  }

  // Obtener estadísticas de traspasos
  Future<Map<String, int>> getEstadisticasTraspasos(String empresaId) async {
    try {
      final querySnapshot = await _collection
          .where('empresaId', isEqualTo: empresaId)
          .get();

      Map<String, int> estadisticas = {
        'total': 0,
        'pendientes': 0,
        'enviados': 0,
        'recibidos': 0,
        'completados': 0,
        'cancelados': 0,
      };

      for (final doc in querySnapshot.docs) {
        final traspaso = Traspaso.fromFirestore(doc);
        estadisticas['total'] = estadisticas['total']! + 1;
        
        switch (traspaso.estado) {
          case EstadoTraspaso.pendiente:
            estadisticas['pendientes'] = estadisticas['pendientes']! + 1;
            break;
          case EstadoTraspaso.enviado:
            estadisticas['enviados'] = estadisticas['enviados']! + 1;
            break;
          case EstadoTraspaso.recibido:
            estadisticas['recibidos'] = estadisticas['recibidos']! + 1;
            break;
          case EstadoTraspaso.completado:
            estadisticas['completados'] = estadisticas['completados']! + 1;
            break;
          case EstadoTraspaso.cancelado:
            estadisticas['cancelados'] = estadisticas['cancelados']! + 1;
            break;
        }
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Buscar traspasos
  Future<List<Traspaso>> buscarTraspasos(String empresaId, String query) async {
    try {
      final querySnapshot = await _collection
          .where('empresaId', isEqualTo: empresaId)
          .orderBy('fecha', descending: true)
          .get();

      final traspasos = querySnapshot.docs
          .map((doc) => Traspaso.fromFirestore(doc))
          .toList();

      // Filtrar por query
      return traspasos.where((traspaso) {
        return traspaso.origenId.toLowerCase().contains(query.toLowerCase()) ||
               traspaso.destinoId.toLowerCase().contains(query.toLowerCase()) ||
               traspaso.usuario.toLowerCase().contains(query.toLowerCase()) ||
               (traspaso.albaranId?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar traspasos: $e');
    }
  }

  // Stream para escuchar cambios en traspasos
  Stream<List<Traspaso>> getTraspasoStream(String empresaId) {
    return _collection
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Traspaso.fromFirestore(doc))
            .toList());
  }

  // Eliminar traspaso (solo para administradores)
  Future<void> eliminarTraspaso(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar traspaso: $e');
    }
  }
}