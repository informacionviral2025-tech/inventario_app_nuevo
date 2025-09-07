// lib/services/traspaso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/traspaso.dart';

class TraspasoService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TraspasoService(this.empresaId);

  CollectionReference get _traspasosRef =>
      _firestore.collection('empresas').doc(empresaId).collection('traspasos');

  // Crear un nuevo traspaso
  Future<void> crearTraspaso(Traspaso traspaso) async {
    try {
      await _traspasosRef.add(traspaso.toMap());
    } catch (e) {
      throw Exception('Error al crear traspaso: $e');
    }
  }

  // Obtener todos los traspasos
  Future<List<Traspaso>> obtenerTraspasos() async {
    try {
      final querySnapshot = await _traspasosRef
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Traspaso.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos: $e');
    }
  }

  // Obtener traspasos en tiempo real
  Stream<List<Traspaso>> obtenerTraspasosStream() {
    return _traspasosRef
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Traspaso.fromMap(data, doc.id);
            }).toList());
  }

  // Obtener un traspaso específico
  Future<Traspaso?> obtenerTraspaso(String traspasoId) async {
    try {
      final doc = await _traspasosRef.doc(traspasoId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Traspaso.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener traspaso: $e');
    }
  }

  // Actualizar estado del traspaso
  Future<void> actualizarEstadoTraspaso(String traspasoId, String nuevoEstado) async {
    try {
      await _traspasosRef.doc(traspasoId).update({
        'estado': nuevoEstado,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del traspaso: $e');
    }
  }

  // Eliminar traspaso
  Future<void> eliminarTraspaso(String traspasoId) async {
    try {
      await _traspasosRef.doc(traspasoId).delete();
    } catch (e) {
      throw Exception('Error al eliminar traspaso: $e');
    }
  }

  // Obtener traspasos por ubicación origen
  Future<List<Traspaso>> obtenerTraspasosPorOrigen(String ubicacionOrigen) async {
    try {
      final querySnapshot = await _traspasosRef
          .where('ubicacionOrigen', isEqualTo: ubicacionOrigen)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Traspaso.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos por origen: $e');
    }
  }

  // Obtener traspasos por ubicación destino
  Future<List<Traspaso>> obtenerTraspasosPorDestino(String ubicacionDestino) async {
    try {
      final querySnapshot = await _traspasosRef
          .where('ubicacionDestino', isEqualTo: ubicacionDestino)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Traspaso.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos por destino: $e');
    }
  }

  // Obtener traspasos por estado
  Future<List<Traspaso>> obtenerTraspasosPorEstado(String estado) async {
    try {
      final querySnapshot = await _traspasosRef
          .where('estado', isEqualTo: estado)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Traspaso.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener traspasos por estado: $e');
    }
  }

  // Confirmar recepción de traspaso
  Future<void> confirmarRecepcion(String traspasoId, Map<String, int> cantidadesRecibidas) async {
    try {
      await _traspasosRef.doc(traspasoId).update({
        'estado': 'completado',
        'cantidadesRecibidas': cantidadesRecibidas,
        'fechaRecepcion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al confirmar recepción: $e');
    }
  }

  // Cancelar traspaso
  Future<void> cancelarTraspaso(String traspasoId, String motivo) async {
    try {
      await _traspasosRef.doc(traspasoId).update({
        'estado': 'cancelado',
        'motivoCancelacion': motivo,
        'fechaCancelacion': FieldValue.serverTimestamp(),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al cancelar traspaso: $e');
    }
  }
}