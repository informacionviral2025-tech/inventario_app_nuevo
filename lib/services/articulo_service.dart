// lib/services/articulo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/articulo.dart';

class ArticuloService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String empresaId;

  // Constructor que requiere empresaId
  ArticuloService(this.empresaId);

  // Obtener todos los artículos de la empresa
  Future<List<Articulo>> getArticulos() async {
    try {
      final querySnapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Articulo.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error al obtener artículos: $e');
      return [];
    }
  }

  // Agregar un nuevo artículo
  Future<bool> addArticulo(Articulo articulo) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .add(articulo.toFirestore());
      return true;
    } catch (e) {
      print('Error al agregar artículo: $e');
      return false;
    }
  }

  // Actualizar un artículo existente
  Future<bool> updateArticulo(Articulo articulo) async {
    try {
      if (articulo.id == null) return false;
      
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc(articulo.id)
          .update(articulo.toFirestore());
      return true;
    } catch (e) {
      print('Error al actualizar artículo: $e');
      return false;
    }
  }

  // Eliminar un artículo
  Future<bool> deleteArticulo(String articuloId) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc(articuloId)
          .delete();
      return true;
    } catch (e) {
      print('Error al eliminar artículo: $e');
      return false;
    }
  }

  // Buscar artículos por nombre o código
  Future<List<Articulo>> searchArticulos(String query) async {
    try {
      // Buscar por nombre
      final queryByName = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      // Buscar por código
      final queryByCode = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('codigoBarras', isEqualTo: query)
          .get();

      final Set<String> processedIds = {};
      final List<Articulo> results = [];

      // Procesar resultados por nombre
      for (var doc in queryByName.docs) {
        if (!processedIds.contains(doc.id)) {
          final data = doc.data();
          data['id'] = doc.id;
          results.add(Articulo.fromFirestore(data));
          processedIds.add(doc.id);
        }
      }

      // Procesar resultados por código
      for (var doc in queryByCode.docs) {
        if (!processedIds.contains(doc.id)) {
          final data = doc.data();
          data['id'] = doc.id;
          results.add(Articulo.fromFirestore(data));
          processedIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      print('Error al buscar artículos: $e');
      return [];
    }
  }

  // Obtener el stock total de todos los artículos
  Future<int> getTotalStock() async {
    try {
      final articulos = await getArticulos();
      return articulos.fold<int>(0, (sum, articulo) => sum + articulo.stock.toInt());
    } catch (e) {
      print('Error al obtener stock total: $e');
      return 0;
    }
  }
}