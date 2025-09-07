// lib/services/traspaso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TraspasoService {
  final CollectionReference _traspasosRef =
      FirebaseFirestore.instance.collection('traspasos');
  final CollectionReference _albaranesRef =
      FirebaseFirestore.instance.collection('albaranes');

  Stream<List<Map<String, dynamic>>> obtenerHistorialTraspasos({
    required String entidadId,
    required String tipoEntidad,
  }) {
    return _traspasosRef
        .where(tipoEntidad, isEqualTo: entidadId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Stream<List<Map<String, dynamic>>> obtenerAlbaranes() {
    return _albaranesRef.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
