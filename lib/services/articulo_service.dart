// lib/services/articulo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/articulo.dart';

class ArticuloService {
  final String empresaId;
  final CollectionReference _articulosRef;

  ArticuloService(this.empresaId)
      : _articulosRef = FirebaseFirestore.instance
            .collection('empresas')
            .doc(empresaId)
            .collection('articulos');

  /// Obtener todos los artículos
  Future<List<Articulo>> getArticulos() async {
    final snapshot = await _articulosRef.get();
    return snapshot.docs.map((doc) => Articulo.fromFirestore(doc)).toList();
  }

  /// Crear artículo
  Future<void> addArticulo(Articulo articulo) async {
    await _articulosRef.add(articulo.toMap());
  }

  /// Actualizar artículo
  Future<bool> updateArticulo(Articulo articulo) async {
    if (articulo.id == null) return false;
    await _articulosRef.doc(articulo.id).update(articulo.toMap());
    return true;
  }

  /// Eliminar artículo
  Future<void> deleteArticulo(String id) async {
    await _articulosRef.doc(id).delete();
  }

  /// Buscar artículos por nombre
  Future<List<Articulo>> searchArticulos(String query) async {
    final snapshot = await _articulosRef
        .where('nombre', isGreaterThanOrEqualTo: query)
        .where('nombre', isLessThanOrEqualTo: "$query\uf8ff")
        .get();

    return snapshot.docs.map((doc) => Articulo.fromFirestore(doc)).toList();
  }
}
