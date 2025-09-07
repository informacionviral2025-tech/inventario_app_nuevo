// lib/providers/inventory_provider.dart
import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventoryProvider extends ChangeNotifier {
  final String empresaId;
  final ArticuloService _articuloService;
  
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this.empresaId) : _articuloService = ArticuloService(empresaId);

  // Getters
  List<Articulo> get articulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter para artículos con stock bajo
  List<Articulo> get articulosStockBajo {
    return _articulos.where((articulo) {
      final stockMinimo = articulo.stockMinimo ?? 0;
      return articulo.stock <= stockMinimo && stockMinimo > 0;
    }

  // Refrescar datos
  Future<void> refresh() async {
    await cargarArticulos();
  }
}).toList();
  }

  // Getter para artículos activos
  List<Articulo> get articulosActivos {
    return _articulos.where((articulo) => articulo.activo == true).toList();
  }

  // Getter para total de artículos
  int get totalArticulos => _articulos.length;

  // Getter para total de stock
  int get totalStock => _articulos.fold(0, (sum, articulo) => sum + articulo.stock);

  // Cargar artículos
  Future<void> cargarArticulos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articulos = await _articuloService.getArticulos();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar artículos: $e';
      _articulos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar artículo
  Future<void> agregarArticulo(Articulo articulo) async {
    try {
      await _articuloService.addArticulo(articulo);
      await cargarArticulos(); // Recargar la lista
    } catch (e) {
      _error = 'Error al agregar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar artículo
  Future<void> actualizarArticulo(Articulo articulo) async {
    try {
      await _articuloService.updateArticulo(articulo);
      await cargarArticulos(); // Recargar la lista
    } catch (e) {
      _error = 'Error al actualizar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar artículo
  Future<void> eliminarArticulo(String articuloId) async {
    try {
      await _articuloService.deleteArticulo(articuloId);
      await cargarArticulos(); // Recargar la lista
    } catch (e) {
      _error = 'Error al eliminar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Buscar artículos
  List<Articulo> buscarArticulos(String query) {
    if (query.isEmpty) return _articulos;
    
    final queryLower = query.toLowerCase();
    return _articulos.where((articulo) {
      return articulo.codigo.toLowerCase().contains(queryLower) ||
             articulo.descripcion.toLowerCase().contains(queryLower) ||
             (articulo.categoria?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  // Filtrar por categoría
  List<Articulo> filtrarPorCategoria(String categoria) {
    return _articulos.where((articulo) => 
        articulo.categoria?.toLowerCase() == categoria.toLowerCase()).toList();
  }

  // Obtener categorías únicas
  List<String> get categorias {
    return _articulos
        .where((articulo) => articulo.categoria != null && articulo.categoria!.isNotEmpty)
        .map((articulo) => articulo.categoria!)
        .toSet()
        .toList()
        ..sort();
  }

  // Actualizar stock de un artículo
  Future<void> actualizarStock(String articuloId, int nuevoStock) async {
    try {
      final index = _articulos.indexWhere((a) => a.id == articuloId || a.firebaseId == articuloId);
      if (index != -1) {
        final articuloActualizado = _articulos[index].copyWith(
          stock: nuevoStock,
          fechaModificacion: DateTime.now(),
        );
        await actualizarArticulo(articuloActualizado);
      }
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await cargarArticulos();
  }
}