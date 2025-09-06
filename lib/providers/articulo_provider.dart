// lib/providers/articulo_provider.dart
import 'package:flutter/foundation.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';
import '../services/firebase_service.dart';
import '../services/sincronizacion_service.dart';

class ArticuloProvider with ChangeNotifier {
  List<Articulo> _articulos = [];
  bool _cargando = false;
  String? _error;
  String? _empresaId;

  List<Articulo> get articulos => _articulos;
  bool get cargando => _cargando;
  String? get error => _error;

  late ArticuloService _articuloService;
  late FirebaseService _firebaseService;
  late SincronizacionService _sincronizacionService;

  void setEmpresaId(String empresaId) {
    _empresaId = empresaId;
    _articuloService = ArticuloService(empresaId);
    _firebaseService = FirebaseService();
    _sincronizacionService = SincronizacionService();
  }

  Future<void> cargarArticulos({bool? soloActivos}) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      if (soloActivos == true) {
        _articulos = await _articuloService.getArticulosActivos().first;
      } else {
        _articulos = await _articuloService.getArticulos().first;
      }
    } catch (e) {
      _error = 'Error al cargar artículos: $e';
      if (kDebugMode) {
        print('Error cargando artículos: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Articulo?> obtenerArticulo(String id) async {
    try {
      final articuloLocal = _articulos.firstWhere(
        (art) => art.firebaseId == id,
        orElse: () => throw StateError('Artículo no encontrado'),
      );

      return articuloLocal;
    } catch (e) {
      // Si no se encuentra localmente, buscamos en el servicio
      try {
        return await _articuloService.obtenerArticulo(id);
      } catch (serviceError) {
        _error = 'Error obteniendo artículo: $serviceError';
        return null;
      }
    }
  }

  // MÉTODO CORREGIDO - ahora se llama 'crearArticulo' pero mantiene funcionalidad de 'agregarArticulo'
  Future<bool> crearArticulo(Articulo articulo) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return false;
    }

    try {
      await _articuloService.agregarArticulo(articulo);
      _articulos.add(articulo);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error creando artículo: $e';
      return false;
    }
  }

  // MÉTODO AGREGADO para mantener compatibilidad
  Future<bool> agregarArticulo(Articulo articulo) async {
    return await crearArticulo(articulo);
  }

  Future<bool> actualizarArticulo(Articulo articulo) async {
    try {
      await _articuloService.actualizarArticulo(articulo);
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

  Future<bool> eliminarArticulo(String id) async {
    try {
      await _articuloService.desactivarArticulo(id);
      _articulos.removeWhere((art) => art.firebaseId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error eliminando artículo: $e';
      return false;
    }
  }

  List<Articulo> buscarArticulos(String query) {
    if (query.isEmpty) return _articulos;
    
    final queryLower = query.toLowerCase();
    return _articulos.where((articulo) =>
      articulo.nombre.toLowerCase().contains(queryLower) ||
      (articulo.codigo?.toLowerCase().contains(queryLower) ?? false) ||
      (articulo.descripcion?.toLowerCase().contains(queryLower) ?? false)
    ).toList();
  }

  List<Articulo> filtrarPorCategoria(String categoria) {
    return _articulos.where((articulo) => articulo.categoria == categoria).toList();
  }

  List<Articulo> get articulosActivos => _articulos.where((art) => art.activo).toList();
  List<Articulo> get articulosInactivos => _articulos.where((art) => !art.activo).toList();

  List<Articulo> get articulosStockBajo {
    return _articulos.where((articulo) => articulo.necesitaReabastecimiento).toList();
  }

  List<Articulo> get articulosSinStock {
    return _articulos.where((articulo) => !articulo.tieneStock).toList();
  }

  Future<bool> incrementarStock(String articuloId, int cantidad) async {
    try {
      final articulo = await obtenerArticulo(articuloId);
      if (articulo == null) return false;

      final nuevoStock = articulo.stock + cantidad;
      final articuloActualizado = articulo.copyWith(stock: nuevoStock);
      
      return await actualizarArticulo(articuloActualizado);
    } catch (e) {
      _error = 'Error incrementando stock: $e';
      return false;
    }
  }

  Future<bool> decrementarStock(String articuloId, int cantidad) async {
    try {
      final articulo = await obtenerArticulo(articuloId);
      if (articulo == null) return false;

      if (articulo.stock < cantidad) {
        _error = 'Stock insuficiente';
        return false;
      }

      final nuevoStock = articulo.stock - cantidad;
      final articuloActualizado = articulo.copyWith(stock: nuevoStock);
      
      return await actualizarArticulo(articuloActualizado);
    } catch (e) {
      _error = 'Error decrementando stock: $e';
      return false;
    }
  }

  Map<String, dynamic> get estadisticas {
    final total = _articulos.length;
    final activos = _articulos.where((art) => art.activo).length;
    final stockBajo = articulosStockBajo.length;
    final sinStock = articulosSinStock.length;
    final valorTotal = _articulos.fold<double>(
      0, 
      (sum, art) => sum + art.valorInventario
    );

    return {
      'total': total,
      'activos': activos,
      'stockBajo': stockBajo,
      'sinStock': sinStock,
      'valorTotal': valorTotal,
    };
  }

  Future<void> sincronizarArticulos() async {
    if (_empresaId == null) return;

    _cargando = true;
    notifyListeners();

    try {
      await _sincronizacionService.sincronizarConFirebase(_empresaId!);
      await cargarArticulos();
    } catch (e) {
      _error = 'Error en sincronización: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void forzarRecarga() {
    _articulos = [];
    notifyListeners();
  }
}