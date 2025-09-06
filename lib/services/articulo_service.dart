// lib/services/articulo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/articulo.dart';

class ArticuloService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ArticuloService(this.empresaId);

  CollectionReference get _collection =>
      _firestore.collection('empresas').doc(empresaId).collection('articulos');

  Stream<List<Articulo>> getArticulos() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Articulo.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<Articulo>> getArticulosActivos() {
    return _collection.where('activo', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Articulo.fromFirestore(doc))
          .toList();
    });
  }

  Future<Articulo?> obtenerArticulo(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return Articulo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo artículo: $e');
      return null;
    }
  }

  Future<String> agregarArticulo(Articulo articulo) async {
    try {
      final docRef = await _collection.add(articulo.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al agregar artículo: $e');
    }
  }

  Future<void> actualizarArticulo(Articulo articulo) async {
    if (articulo.firebaseId == null) return;
    await _collection.doc(articulo.firebaseId).update(articulo.toFirestore());
  }

  Future<void> desactivarArticulo(String id) async {
    await _collection.doc(id).update({'activo': false});
  }

  Future<List<Articulo>> buscarPorNombre(String query) async {
    final snapshot = await _collection
        .where('nombre', isGreaterThanOrEqualTo: query)
        .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Articulo.fromFirestore(doc)).toList();
  }

  Future<Map<String, int>> getEstadisticas() async {
    final snapshot = await _collection.where('activo', isEqualTo: true).get();
    final articulosList = snapshot.docs.map((doc) => Articulo.fromFirestore(doc)).toList();
    final totalArticulos = articulosList.length;
    final stockTotal = articulosList.fold<int>(0, (sum, art) => sum + art.stock);
    return {
      'totalArticulos': totalArticulos,
      'stockTotal': stockTotal,
    };
  }

  Future<void> incrementarStock(String id, int cantidad) async {
    final doc = await _collection.doc(id).get();
    final articulo = Articulo.fromFirestore(doc);
    await _collection.doc(id).update({'stock': articulo.stock + cantidad});
  }

  Future<void> decrementarStock(String id, int cantidad) async {
    final doc = await _collection.doc(id).get();
    final articulo = Articulo.fromFirestore(doc);
    await _collection.doc(id).update({'stock': articulo.stock - cantidad});
  }

  Future<List<String>> getCategorias() async {
    final snapshot = await _collection.get();
    final categorias = <String>{};
    for (final doc in snapshot.docs) {
      final c = doc['categoria'] as String?;
      if (c != null && c.isNotEmpty) categorias.add(c);
    }
    return categorias.toList();
  }

  Future<List<Articulo>> buscarArticulos(String query) async {
    final snapshot = await _collection
        .where('nombre', isGreaterThanOrEqualTo: query)
        .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Articulo.fromFirestore(doc)).toList();
  }
}