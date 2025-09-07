// lib/services/entradas_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EntradasService {
  final CollectionReference _entradasRef =
      FirebaseFirestore.instance.collection('entradas');

  Stream<List<Map<String, dynamic>>> obtenerEntradas({required String empresaId}) {
    return _entradasRef
        .where('empresaId', isEqualTo: empresaId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<void> agregarEntrada(Map<String, dynamic> entrada) async {
    await _entradasRef.add(entrada);
  }
}
