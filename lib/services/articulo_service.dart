// lib/services/articulo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/articulo.dart';

class ArticuloService {
  final String empresaId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ArticuloService(this.empresaId);

  CollectionReference get _articulosRef =>
      _firestore.collection('empresas').doc(empresaId).collection('articulos');

  Future<List<Articulo>> getArticulos() async {
    try {
      final snapshot = await _articulosRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Articulo.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener artículos: $e');
    }
  }

  Future<void> addArticulo(Articulo articulo) async {
    try {
      await _articulosRef.add(articulo.toMap());
    } catch (e) {
      throw Exception('Error al agregar artículo: $e');
    }
  }

  Future<void> updateArticulo(Articulo articulo) async {
    try {
      final docId = articulo.id ?? articulo.firebaseId ?? '';
      if (docId.isEmpty) {
        throw Exception('ID del artículo no válido');
      }
      await _articulosRef.doc(docId).update(articulo.toMap());
    } catch (e) {
      throw Exception('Error al actualizar artículo: $e');
    }
  }

  Future<void> deleteArticulo(String articuloId) async {
    try {
      await _articulosRef.doc(articuloId).delete();
    } catch (e) {
      throw Exception('Error al eliminar artículo: $e');
    }
  }

  Future<List<Articulo>> searchArticulos(String query) async {
    try {
      final snapshot = await _articulosRef.get();
      final articulos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Articulo.fromMap(data, doc.id);
      }).toList();

      if (query.isEmpty) return articulos;

      final queryLower = query.toLowerCase();
      return articulos.where((articulo) {
        return articulo.codigo.toLowerCase().contains(queryLower) ||
               (articulo.descripcion?.toLowerCase().contains(queryLower) ?? false) ||
               (articulo.nombre.toLowerCase().contains(queryLower)) ||
               (articulo.categoria?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar artículos: $e');
    }
  }

  Future<Articulo?> getArticuloByCodigo(String codigo) async {
    try {
      final snapshot = await _articulosRef
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return Articulo.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener artículo por código: $e');
    }
  }

  Future<List<Articulo>> getArticulosConStockBajo() async {
    try {
      final articulos = await getArticulos();
      return articulos.where((articulo) {
        final stockMinimo = articulo.stockMinimo ?? 0;
        return stockMinimo > 0 && articulo.stock <= stockMinimo;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener artículos con stock bajo: $e');
    }
  }

  Stream<List<Articulo>> getArticulosStream() {
    return _articulosRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Articulo.fromMap(data, doc.id);
      }).toList();
    });
  }

  Future<void> actualizarStock(String articuloId, int nuevoStock) async {
    try {
      await _articulosRef.doc(articuloId).update({
        'stock': nuevoStock,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  Future<void> incrementarStock(String articuloId, int cantidad) async {
    try {
      await _articulosRef.doc(articuloId).update({
        'stock': FieldValue.increment(cantidad),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al incrementar stock: $e');
    }
  }

  Future<void> decrementarStock(String articuloId, int cantidad) async {
    try {
      await _articulosRef.doc(articuloId).update({
        'stock': FieldValue.increment(-cantidad),
        'fechaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al decrementar stock: $e');
    }
  }
}