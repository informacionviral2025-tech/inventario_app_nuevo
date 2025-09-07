import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;
  late ArticuloService _articuloService;

  List<Articulo> get articulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Inicializar el provider con el empresaId
  void initializeService(String empresaId) {
    _articuloService = ArticuloService(empresaId);
  }

  // Cargar artículos
  Future<void> loadArticulos(String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articulos = await _articuloService.getArticulos();
    } catch (e) {
      _error = 'Error al cargar artículos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar artículo
  Future<bool> addArticulo(Articulo articulo, String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }

    try {
      final success = await _articuloService.addArticulo(articulo);
      if (success) {
        await loadArticulos(empresaId);
      }
      return success;
    } catch (e) {
      _error = 'Error al agregar artículo: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualizar artículo
  Future<bool> updateArticulo(Articulo articulo, String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }

    try {
      final success = await _articuloService.updateArticulo(articulo);
      if (success) {
        await loadArticulos(empresaId);
      }
      return success;
    } catch (e) {
      _error = 'Error al actualizar artículo: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar artículo
  Future<bool> deleteArticulo(String articuloId, String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }

    try {
      final success = await _articuloService.deleteArticulo(articuloId);
      if (success) {
        await loadArticulos(empresaId);
      }
      return success;
    } catch (e) {
      _error = 'Error al eliminar artículo: $e';
      notifyListeners();
      return false;
    }
  }

  // Buscar artículos
  Future<void> searchArticulos(String query, String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _articulos = await _articuloService.getArticulos();
      } else {
        _articulos = await _articuloService.searchArticulos(query);
      }
    } catch (e) {
      _error = 'Error al buscar artículos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar stock
  Future<bool> updateStock(String articuloId, int nuevoStock, String empresaId) async {
    if (_articuloService == null) {
      initializeService(empresaId);
    }

    try {
      final articulo = _articulos.firstWhere((a) => a.id == articuloId);
      final articuloActualizado = Articulo(
        id: articulo.id,
        nombre: articulo.nombre,
        descripcion: articulo.descripcion,
        precio: articulo.precio,
        stock: nuevoStock,
        categoria: articulo.categoria,
        codigoBarras: articulo.codigoBarras,
        fechaCreacion: articulo.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      );

      final success = await _articuloService.updateArticulo(articuloActualizado);
      if (success) {
        await loadArticulos(empresaId);
      }
      return success;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  // Obtener artículo por ID
  Articulo? getArticuloById(String id) {
    try {
      return _articulos.firstWhere((articulo) => articulo.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener stock total
  int get totalStock {
    return _articulos.fold<int>(0, (sum, articulo) => sum + articulo.stock.toInt());
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}