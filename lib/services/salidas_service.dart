// lib/services/salidas_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalidasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registra una salida de inventario
  Future<bool> registrarSalida({
    required String empresaId,
    required String articuloId,
    required int cantidad,
    required String motivo,
  }) async {
    try {
      // Crear referencia a colección de salidas
      final salidasRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('salidas');

      // Generar un albarán único
      final albaranId = salidasRef.doc().id;

      // Guardar salida individual
      await salidasRef.doc(albaranId).set({
        'fecha': Timestamp.now(),
        'articulos': {
          articuloId: cantidad,
        },
        'motivo': motivo,
        'estado': 'pendiente', // pendiente o procesado
      });

      return true;
    } catch (e) {
      print('Error al registrar salida: $e');
      return false;
    }
  }

  /// Obtiene el historial de albaranes de una empresa
  Stream<List<Map<String, dynamic>>> obtenerAlbaranes(String empresaId) {
    final salidasRef = _firestore
        .collection('empresas')
        .doc(empresaId)
        .collection('salidas')
        .orderBy('fecha', descending: true);

    return salidasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Marcar albarán como procesado
  Future<void> procesarAlbaran(String empresaId, String albaranId) async {
    try {
      final albaranRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('salidas')
          .doc(albaranId);

      await albaranRef.update({
        'estado': 'procesado',
        'procesadoEn': Timestamp.now(),
      });
    } catch (e) {
      print('Error al procesar albarán: $e');
    }
  }
}
