// lib/providers/inventory_provider.dart
import 'package:flutter/foundation.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;
  ArticuloService? _articuloService;

  List<Articulo> get articulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para inicializar el servicio
  void initializeService(String empresaId) {
    _articuloService = ArticuloService(empresaId);
  }

  // Getter para artículos activos
  List<Articulo> get articulosActivos {
    return _articulos.where((articulo) => articulo.activo == true).toList();
  }

  // Método para refrescar datos
  Future<void> refresh() async {
    if (_articuloService != null) {
      await loadArticulos(_articuloService!.empresaId);
    }
  }

  int get totalArticulos => _articulos.length;

  int get totalStock => _articulos.fold(0, (sum, articulo) => sum + articulo.stock);

  Future<void> loadArticulos(String empresaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_articuloService == null) {
        initializeService(empresaId);
      }
      _articulos = await _articuloService!.getArticulos();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar artículos: $e';
      _articulos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addArticulo(Articulo articulo) async {
    try {
      await _articuloService!.addArticulo(articulo);
      await refresh();
    } catch (e) {
      _error = 'Error al agregar artículo: $e';
      notifyListeners();
    }
  }

  Future<void> updateArticulo(Articulo articulo) async {
    try {
      await _articuloService!.updateArticulo(articulo);
      await refresh();
    } catch (e) {
      _error = 'Error al actualizar artículo: $e';
      notifyListeners();
    }
  }

  Future<void> deleteArticulo(String articuloId) async {
    try {
      await _articuloService!.deleteArticulo(articuloId);
      await refresh();
    } catch (e) {
      _error = 'Error al eliminar artículo: $e';
      notifyListeners();
    }
  }

  List<Articulo> searchArticulos(String query, String empresaId) {
    if (query.isEmpty) return _articulos;
    
    final lowercaseQuery = query.toLowerCase();
    return _articulos.where((articulo) {
      return articulo.nombre.toLowerCase().contains(lowercaseQuery) ||
             articulo.codigo.toLowerCase().contains(lowercaseQuery) ||
             articulo.categoria.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Articulo> getArticulosByCategoria(String categoria) {
    return _articulos.where((articulo) =>
        articulo.categoria.toLowerCase() == categoria.toLowerCase()).toList();
  }

  List<Articulo> getArticulosConStockBajo({int limite = 10}) {
    return _articulos
        .where((articulo) => articulo.stock <= limite)
        .toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));
  }

  Future<void> updateStock(String articuloId, int nuevoStock) async {
    try {
      final index = _articulos.indexWhere((a) => a.id == articuloId || a.firebaseId == articuloId);
      if (index != -1) {
        final articuloActualizado = _articulos[index].copyWith(
          stock: nuevoStock,
        );
        await updateArticulo(articuloActualizado);
      }
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}