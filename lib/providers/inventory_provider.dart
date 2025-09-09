// lib/providers/inventory_provider.dart - VERSIÓN CORREGIDA
import 'package:flutter/foundation.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventoryProvider extends ChangeNotifier {
  ArticuloService? _articuloService;
  
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Articulo> get articulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter para artículos con stock bajo
  List<Articulo> get articulosStockBajo {
    return _articulos.where((articulo) => 
      (articulo.stockMinimo != null && articulo.stock <= articulo.stockMinimo!)
    ).toList();
  }

  // Getter para stock total
  int get totalStock {
    return _articulos.fold(0, (sum, articulo) => sum + articulo.stock);
  }

  // Cargar todos los artículos
  Future<void> loadArticulos(String empresaId) async {
    if (empresaId.isEmpty) {
      print('⚠️ EmpresaId vacío, no se pueden cargar artículos');
      return;
    }

    _setLoading(true);
    try {
      print('📦 Cargando artículos para empresa: $empresaId');
      
      // Inicializar o actualizar el servicio
      _articuloService = ArticuloService(empresaId);
      
      // Cargar artículos
      _articulos = await _articuloService!.getArticulos();
      _error = null;
      
      print('✅ Se cargaron ${_articulos.length} artículos');
      print('📊 Stock total: $totalStock');
      print('⚠️ Artículos con stock bajo: ${articulosStockBajo.length}');
      
    } catch (e) {
      print('❌ Error cargando artículos: $e');
      _error = 'Error al cargar artículos: $e';
      _articulos = [];
    } finally {
      _setLoading(false);
    }
  }

  // Buscar artículos
  Future<List<Articulo>> searchArticulos(String query, String empresaId) async {
    if (_articuloService == null || _articuloService!.empresaId != empresaId) {
      _articuloService = ArticuloService(empresaId);
    }
    
    try {
      return await _articuloService!.searchArticulos(query);
    } catch (e) {
      print('❌ Error buscando artículos: $e');
      return [];
    }
  }

  // Filtrar por categoría
  List<Articulo> filtrarPorCategoria(String categoria) {
    if (categoria == 'Todas' || categoria.isEmpty) return _articulos;
    
    return _articulos.where((articulo) => 
        articulo.categoria?.toLowerCase() == categoria.toLowerCase()).toList();
  }

  // Obtener artículos con stock bajo
  List<Articulo> obtenerArticulosStockBajo() {
    return articulosStockBajo;
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
    if (_articuloService == null) {
      throw Exception('Servicio no inicializado');
    }
    
    try {
      await _articuloService!.addArticulo(articulo);
      await loadArticulos(_articuloService!.empresaId); // Recargar la lista
    } catch (e) {
      _error = 'Error al agregar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar artículo
  Future<void> updateArticulo(Articulo articulo) async {
    if (_articuloService == null) {
      throw Exception('Servicio no inicializado');
    }
    
    try {
      await _articuloService!.updateArticulo(articulo);
      await loadArticulos(_articuloService!.empresaId); // Recargar la lista
    } catch (e) {
      _error = 'Error al actualizar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Eliminar artículo
  Future<void> deleteArticulo(String id) async {
    if (_articuloService == null) {
      throw Exception('Servicio no inicializado');
    }
    
    try {
      await _articuloService!.deleteArticulo(id);
      await loadArticulos(_articuloService!.empresaId); // Recargar la lista
    } catch (e) {
      _error = 'Error al eliminar artículo: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Inicializar servicio
  void initializeService(String empresaId) {
    if (empresaId.isNotEmpty) {
      _articuloService = ArticuloService(empresaId);
      print('🔧 Servicio inicializado para empresa: $empresaId');
    }
  }

  // Obtener artículo por código
  Future<Articulo?> getArticuloByCodigo(String codigo, String empresaId) async {
    if (_articuloService == null || _articuloService!.empresaId != empresaId) {
      _articuloService = ArticuloService(empresaId);
    }
    
    try {
      return await _articuloService!.getArticuloByCodigo(codigo);
    } catch (e) {
      print('❌ Error obteniendo artículo por código: $e');
      return null;
    }
  }

  // Actualizar stock
  Future<void> actualizarStock(String articuloId, int nuevoStock, String empresaId) async {
    if (_articuloService == null || _articuloService!.empresaId != empresaId) {
      _articuloService = ArticuloService(empresaId);
    }
    
    try {
      await _articuloService!.actualizarStock(articuloId, nuevoStock);
      await loadArticulos(empresaId); // Recargar para reflejar cambios
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Incrementar stock
  Future<void> incrementarStock(String articuloId, int cantidad, String empresaId) async {
    if (_articuloService == null || _articuloService!.empresaId != empresaId) {
      _articuloService = ArticuloService(empresaId);
    }
    
    try {
      await _articuloService!.incrementarStock(articuloId, cantidad);
      await loadArticulos(empresaId); // Recargar para reflejar cambios
    } catch (e) {
      _error = 'Error al incrementar stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Decrementar stock
  Future<void> decrementarStock(String articuloId, int cantidad, String empresaId) async {
    if (_articuloService == null || _articuloService!.empresaId != empresaId) {
      _articuloService = ArticuloService(empresaId);
    }
    
    try {
      await _articuloService!.decrementarStock(articuloId, cantidad);
      await loadArticulos(empresaId); // Recargar para reflejar cambios
    } catch (e) {
      _error = 'Error al decrementar stock: $e';
      notifyListeners();
      rethrow;
    }
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

  // Limpiar datos (útil al cambiar de empresa o cerrar sesión)
  void clearData() {
    _articulos.clear();
    _articuloService = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}