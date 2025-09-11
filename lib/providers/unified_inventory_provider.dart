// lib/providers/unified_inventory_provider.dart
import 'package:flutter/foundation.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';
import '../services/unified_sync_service.dart';
import '../services/barcode_service.dart';

class UnifiedInventoryProvider extends ChangeNotifier {
  // Servicios
  ArticuloService? _articuloService;
  final UnifiedSyncService _syncService = UnifiedSyncService();
  final BarcodeService _barcodeService = BarcodeService();

  // Estado
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;
  String? _empresaId;
  String? _empresaNombre;

  // Filtros y búsqueda
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  bool _showOnlyLowStock = false;
  bool _showOnlyActive = true;

  // Getters
  List<Articulo> get articulos => _getFilteredArticulos();
  List<Articulo> get allArticulos => _articulos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get empresaId => _empresaId;
  String? get empresaNombre => _empresaNombre;

  // Estadísticas
  int get totalArticulos => _articulos.length;
  int get totalStock => _articulos.fold(0, (sum, art) => sum + art.stock);
  int get articulosActivos => _articulos.where((art) => art.activo).length;
  int get articulosStockBajo => _articulos.where((art) => art.necesitaReabastecimiento).length;
  int get articulosSinStock => _articulos.where((art) => !art.tieneStock).length;
  double get valorTotalInventario => _articulos.fold(0.0, (sum, art) => sum + art.valorInventario);

  // Categorías disponibles
  List<String> get categorias {
    final cats = _articulos
        .map((art) => art.categoria)
        .where((cat) => cat != null && cat.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    cats.sort();
    return ['Todas', ...cats];
  }

  // Configurar empresa
  void setEmpresa(String empresaId, String empresaNombre) {
    _empresaId = empresaId;
    _empresaNombre = empresaNombre;
    _articuloService = ArticuloService(empresaId);
    _syncService.setCurrentEmpresa(empresaId);
    notifyListeners();
  }

  // Cargar artículos
  Future<void> loadArticulos({bool forceRefresh = false}) async {
    if (_empresaId == null || _articuloService == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      if (forceRefresh) {
        // Forzar sincronización antes de cargar
        await _syncService.forceSync();
      }

      _articulos = await _articuloService!.getArticulos();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar artículos: $e';
      if (kDebugMode) {
        print('Error cargando artículos: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Buscar artículos
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Filtrar por categoría
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Toggle filtros
  void toggleLowStockFilter() {
    _showOnlyLowStock = !_showOnlyLowStock;
    notifyListeners();
  }

  void toggleActiveFilter() {
    _showOnlyActive = !_showOnlyActive;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'Todas';
    _showOnlyLowStock = false;
    _showOnlyActive = true;
    notifyListeners();
  }

  // Obtener artículos filtrados
  List<Articulo> _getFilteredArticulos() {
    List<Articulo> filtered = List.from(_articulos);

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((art) =>
          art.nombre.toLowerCase().contains(_searchQuery) ||
          art.codigo.toLowerCase().contains(_searchQuery) ||
          (art.descripcion?.toLowerCase().contains(_searchQuery) ?? false) ||
          (art.categoria?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }

    // Filtro de categoría
    if (_selectedCategory != 'Todas') {
      filtered = filtered.where((art) => art.categoria == _selectedCategory).toList();
    }

    // Filtro de stock bajo
    if (_showOnlyLowStock) {
      filtered = filtered.where((art) => art.necesitaReabastecimiento).toList();
    }

    // Filtro de activos
    if (_showOnlyActive) {
      filtered = filtered.where((art) => art.activo).toList();
    }

    return filtered;
  }

  // Obtener artículo por ID
  Articulo? getArticuloById(String id) {
    try {
      return _articulos.firstWhere((art) => art.firebaseId == id || art.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener artículo por código
  Future<Articulo?> getArticuloByCodigo(String codigo) async {
    if (_articuloService == null) return null;

    try {
      return await _articuloService!.getArticuloByCodigo(codigo);
    } catch (e) {
      _error = 'Error buscando artículo por código: $e';
      return null;
    }
  }

  // Crear artículo
  Future<bool> crearArticulo(Articulo articulo) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      await _articuloService!.addArticulo(articulo);
      
      // Sincronizar inmediatamente
      await _syncService.syncArticulo(articulo);
      
      // Recargar lista
      await loadArticulos();
      
      return true;
    } catch (e) {
      _error = 'Error creando artículo: $e';
      return false;
    }
  }

  // Actualizar artículo
  Future<bool> actualizarArticulo(Articulo articulo) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      await _articuloService!.updateArticulo(articulo);
      
      // Sincronizar inmediatamente
      await _syncService.syncArticulo(articulo);
      
      // Actualizar en lista local
      final index = _articulos.indexWhere((art) => art.firebaseId == articulo.firebaseId);
      if (index != -1) {
        _articulos[index] = articulo;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando artículo: $e';
      return false;
    }
  }

  // Eliminar artículo (desactivar)
  Future<bool> eliminarArticulo(String id) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      final articulo = getArticuloById(id);
      if (articulo == null) {
        _error = 'Artículo no encontrado';
        return false;
      }

      final articuloDesactivado = articulo.copyWith(activo: false);
      await _articuloService!.updateArticulo(articuloDesactivado);
      
      // Sincronizar inmediatamente
      await _syncService.syncArticulo(articuloDesactivado);
      
      // Actualizar en lista local
      final index = _articulos.indexWhere((art) => art.firebaseId == id);
      if (index != -1) {
        _articulos[index] = articuloDesactivado;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error eliminando artículo: $e';
      return false;
    }
  }

  // Actualizar stock
  Future<bool> actualizarStock(String articuloId, int nuevoStock) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      await _articuloService!.actualizarStock(articuloId, nuevoStock);
      
      // Actualizar en lista local
      final index = _articulos.indexWhere((art) => art.firebaseId == articuloId);
      if (index != -1) {
        _articulos[index] = _articulos[index].copyWith(stock: nuevoStock);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando stock: $e';
      return false;
    }
  }

  // Incrementar stock
  Future<bool> incrementarStock(String articuloId, int cantidad) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      await _articuloService!.incrementarStock(articuloId, cantidad);
      
      // Actualizar en lista local
      final index = _articulos.indexWhere((art) => art.firebaseId == articuloId);
      if (index != -1) {
        final nuevoStock = _articulos[index].stock + cantidad;
        _articulos[index] = _articulos[index].copyWith(stock: nuevoStock);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error incrementando stock: $e';
      return false;
    }
  }

  // Decrementar stock
  Future<bool> decrementarStock(String articuloId, int cantidad) async {
    if (_articuloService == null) {
      _error = 'Servicio no inicializado';
      return false;
    }

    try {
      final articulo = getArticuloById(articuloId);
      if (articulo == null) {
        _error = 'Artículo no encontrado';
        return false;
      }

      if (articulo.stock < cantidad) {
        _error = 'Stock insuficiente';
        return false;
      }

      await _articuloService!.decrementarStock(articuloId, cantidad);
      
      // Actualizar en lista local
      final index = _articulos.indexWhere((art) => art.firebaseId == articuloId);
      if (index != -1) {
        final nuevoStock = _articulos[index].stock - cantidad;
        _articulos[index] = _articulos[index].copyWith(stock: nuevoStock);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error decrementando stock: $e';
      return false;
    }
  }

  // Generar código de barras
  String generarCodigoBarras(String codigoArticulo, {String? lote}) {
    return _barcodeService.generateBarcodeData2(
      codigoArticulo,
      empresaId: _empresaId,
      lote: lote,
    );
  }

  // Validar código de barras
  bool validarCodigoBarras(String codigo, String tipo) {
    return _barcodeService.validateBarcode(codigo, tipo);
  }

  // Sincronización
  Future<void> sincronizar() async {
    if (_empresaId == null) return;

    _setLoading(true);
    try {
      await _syncService.syncAll();
      await loadArticulos();
    } catch (e) {
      _error = 'Error en sincronización: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Obtener estadísticas detalladas
  Map<String, dynamic> get estadisticasDetalladas {
    final categorias = <String, int>{};
    final stockBajo = <Articulo>[];
    final sinStock = <Articulo>[];
    double valorTotal = 0;

    for (final articulo in _articulos) {
      // Contar por categorías
      final categoria = articulo.categoria ?? 'Sin categoría';
      categorias[categoria] = (categorias[categoria] ?? 0) + 1;

      // Stock bajo
      if (articulo.necesitaReabastecimiento) {
        stockBajo.add(articulo);
      }

      // Sin stock
      if (!articulo.tieneStock) {
        sinStock.add(articulo);
      }

      // Valor total
      valorTotal += articulo.valorInventario;
    }

    return {
      'totalArticulos': _articulos.length,
      'articulosActivos': articulosActivos,
      'articulosInactivos': _articulos.length - articulosActivos,
      'totalStock': totalStock,
      'valorTotalInventario': valorTotal,
      'articulosStockBajo': stockBajo.length,
      'articulosSinStock': sinStock.length,
      'categorias': categorias,
      'stockBajo': stockBajo,
      'sinStock': sinStock,
    };
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpiar datos
  void clearData() {
    _articulos.clear();
    _articuloService = null;
    _empresaId = null;
    _empresaNombre = null;
    _error = null;
    _isLoading = false;
    clearFilters();
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}

