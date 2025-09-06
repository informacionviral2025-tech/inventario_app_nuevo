// lib/services/base_empresa_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseEmpresaService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BaseEmpresaService(this.empresaId);

  // Referencia raíz de la empresa
  DocumentReference get empresaRef => 
      _firestore.collection('empresas').doc(empresaId);

  // Colecciones específicas de la empresa
  CollectionReference get articulos => empresaRef.collection('articulos');
  CollectionReference get obras => empresaRef.collection('obras');
  CollectionReference get traspasos => empresaRef.collection('traspasos');
  CollectionReference get albaranes => empresaRef.collection('albaranes');
  CollectionReference get usuarios => empresaRef.collection('usuarios');

  // Métodos auxiliares para timestamps
  Timestamp get now => Timestamp.now();
  DateTime fromTimestamp(Timestamp timestamp) => timestamp.toDate();
}