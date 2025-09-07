// lib/providers/inventory_provider.dart
import 'package:flutter/foundation.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventoryProvider extends ChangeNotifier {
  ArticuloService _articuloService;
  
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;

  List<Articulo> get articulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InventoryProvider() : _articuloService = ArticuloService('');

  // Getter para artículos con stock bajo
  List<Articulo> get articulosStockBajo {
    return _articulos.where((articulo) => 
      (articulo.stock) <= (articulo.stockMinimo ?? 0)
    ).toList();
  }

  // Getter para stock total
  int get totalStock {
    return _articulos.fold(0, (sum, articulo) => sum + articulo.stock);
  }

  // Cargar todos los artículos
  Future<void> loadArticulos(String empresaId) async {
    _setLoading(true);
    try {
      _articuloService = ArticuloService(empresaId);
      _articulos = await _articuloService.getArticulos();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articulos = [];
    } finally {
      _setLoading(false);
    }
  }

  // Buscar artículos
  Future<List<Articulo>> searchArticulos(String query, String empresaId) async {
    if (query.isEmpty) return _articulos;
    
    final articulos = await _articuloService.searchArticulos(query);
    return articulos;
  }

  // Filtrar por categoría
  List<Articulo> filtrarPorCategoria(String categoria) {
    if (categoria == 'Todas' || categoria.isEmpty) return _articulos;
    
    return _articulos.where((articulo) => 
        articulo.categoria?.toLowerCase() == categoria.toLowerCase()).toList();
  }

  // Obtener artículos con stock bajo
  List<Articulo> obtenerArticulosStockBajo() {
    return _articulos.where((articulo) => 
        (articulo.stock) <= (articulo.stockMinimo ?? 0)).toList();
  }

  // Obtener categorías únicas
  List<String> obtenerCategorias() {
    final categorias = _articulos
        .map((articulo) => articulo.categoria)
        .where((categoria) => categoria != null && categoria.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    
    categorias.sort();
    return ['Todas', ...categorias];
  }

  // Agregar artículo
  Future<void> addArticulo(Articulo articulo) async {
    try {
      await _articuloService.addArticulo(articulo);
      await loadArticulos(_articuloService.empresaId); // Recargar la lista
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar artículo
  Future<void> updateArticulo(Articulo articulo) async {
    try {
      await _articuloService.updateArticulo(articulo);
      await loadArticulos(_articuloService.empresaId); // Recargar la lista
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar artículo
  Future<void> deleteArticulo(String id) async {
    try {
      await _articuloService.deleteArticulo(id);
      await loadArticulos(_articuloService.empresaId); // Recargar la lista
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Inicializar servicio
  void initializeService(String empresaId) {
    _articuloService = ArticuloService(empresaId);
  }

  // Método privado para manejar el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}