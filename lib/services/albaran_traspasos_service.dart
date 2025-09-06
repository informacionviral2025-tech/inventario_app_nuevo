// lib/services/albaran_traspasos_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaranTraspasosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Crear un albarán (cuando se hace un traspaso o manualmente)
  Future<void> crearAlbaran({
    required String origenId,
    required String destinoId,
    required String tipoOrigen, // "empresa" o "obra"
    required String tipoDestino, // "empresa" o "obra"
    required Map<String, int> articulos, // { "articuloId": cantidad }
    required String usuario,
  }) async {
    final albaranRef = _db.collection("albaranes").doc();

    await albaranRef.set({
      "id": albaranRef.id,
      "numero": "ALB-${DateTime.now().millisecondsSinceEpoch}", // 🔢 único
      "fecha": FieldValue.serverTimestamp(),
      "origen": {
        "id": origenId,
        "tipo": tipoOrigen,
      },
      "destino": {
        "id": destinoId,
        "tipo": tipoDestino,
      },
      "articulos": articulos,
      "usuario": usuario,
      "estado": "pendiente", // pendiente | entregado | cancelado
    });
  }

  /// 🔹 Obtener todos los albaranes
  Stream<List<Map<String, dynamic>>> getAlbaranes() {
    return _db
        .collection("albaranes")
        .orderBy("fecha", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 🔹 Obtener albaranes filtrados por origen o destino
  Stream<List<Map<String, dynamic>>> getAlbaranesPorEntidad({
    required String entidadId,
    required String tipo, // "empresa" o "obra"
  }) {
    return _db
        .collection("albaranes")
        .where("origen.id", isEqualTo: entidadId)
        .where("origen.tipo", isEqualTo: tipo)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 🔹 Cambiar estado de un albarán
  Future<void> actualizarEstadoAlbaran({
    required String albaranId,
    required String nuevoEstado, // pendiente | entregado | cancelado
  }) async {
    await _db.collection("albaranes").doc(albaranId).update({
      "estado": nuevoEstado,
      "fechaActualizacion": FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Obtener un albarán por ID
  Future<Map<String, dynamic>?> getAlbaranPorId(String albaranId) async {
    final doc = await _db.collection("albaranes").doc(albaranId).get();
    return doc.exists ? doc.data() : null;
  }
}
