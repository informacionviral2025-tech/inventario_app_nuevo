// lib/services/empresa_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empresa.dart';

class EmpresaFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección empresas
  CollectionReference get empresasCollection => 
      _firestore.collection('empresas');

  // Obtener todas las empresas
  Stream<List<Empresa>> getEmpresas() {
    return empresasCollection
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Empresa.fromFirestore(doc))
            .toList());
  }

  // Crear nueva empresa
  Future<String> createEmpresa(Empresa empresa) async {
    final docRef = await empresasCollection.add(empresa.toMap());
    return docRef.id;
  }

  // Eliminar empresa (solo admin)
  Future<void> deleteEmpresa(String empresaId) async {
    await empresasCollection.doc(empresaId).delete();
  }
}