// lib/providers/obra_provider.dart
import 'package:flutter/foundation.dart';
import '../models/obra.dart';
import '../services/obra_service.dart';

class ObraProvider with ChangeNotifier {
  List<Obra> _obras = [];
  bool _cargando = false;
  String? _error;
  String? _empresaId;

  List<Obra> get obras => _obras;
  bool get cargando => _cargando;
  String? get error => _error;

  late ObraService _obraService;

  void setEmpresaId(String empresaId) {
    _empresaId = empresaId;
    _obraService = ObraService(empresaId);
  }

  Future<void> cargarObras({bool? activas}) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      if (activas == true) {
        _obras = await _obraService.getObrasActivas().first;
      } else {
        _obras = await _obraService.getObras().first;
      }
    } catch (e) {
      _error = 'Error al cargar obras: $e';
      if (kDebugMode) {
        print('Error cargando obras: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Obra?> obtenerObra(String id) async {
    try {
      // Primero buscar en la lista local
      try {
        final obraLocal = _obras.firstWhere(
          (obra) => obra.id == id,
        );
        return obraLocal;
      } catch (e) {
        // No se encontró en local
      }

      // Si no está en local, buscar en Firebase
      return await _obraService.getObra(id); // Cambiado de obtenerObra a getObra
    } catch (e) {
      _error = 'Error obteniendo obra: $e';
      return null;
    }
  }

  Future<bool> crearObra(Obra obra) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return false;
    }

    try {
      final obraId = await _obraService.crearObra(obra);
      final obraConId = obra.copyWith(id: obraId, firebaseId: obraId);
      
      _obras.add(obraConId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Error creando obra: $e';
      return false;
    }
  }

  Future<bool> actualizarObra(Obra obra) async {
    try {
      await _obraService.actualizarObra(obra);
      
      final index = _obras.indexWhere((o) => o.id == obra.id);
      if (index != -1) {
        _obras[index] = obra;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando obra: $e';
      return false;
    }
  }

  Future<bool> cambiarEstadoObra(String obraId, String nuevoEstado) async {
    try {
      await _obraService.cambiarEstadoObra(obraId, nuevoEstado);
      
      final index = _obras.indexWhere((o) => o.id == obraId);
      if (index != -1) {
        final obraActualizada = _obras[index].copyWith(estado: nuevoEstado);
        _obras[index] = obraActualizada;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error cambiando estado: $e';
      return false;
    }
  }

  Future<bool> actualizarStockObra(String obraId, String articuloId, int nuevaCantidad) async {
    try {
      await _obraService.actualizarStockObra(obraId, articuloId, nuevaCantidad);
      
      final index = _obras.indexWhere((o) => o.id == obraId);
      if (index != -1) {
        final obra = _obras[index];
        final nuevoStock = Map<String, int>.from(obra.stock);
        if (nuevaCantidad <= 0) {
          nuevoStock.remove(articuloId);
        } else {
          nuevoStock[articuloId] = nuevaCantidad;
        }
        
        _obras[index] = obra.copyWith(stock: nuevoStock);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando stock: $e';
      return false;
    }
  }

  Future<bool> agregarStockObra(String obraId, String articuloId, int cantidad) async {
    try {
      await _obraService.agregarStockObra(obraId, articuloId, cantidad);
      
      final index = _obras.indexWhere((o) => o.id == obraId);
      if (index != -1) {
        await cargarObras();
      }
      
      return true;
    } catch (e) {
      _error = 'Error agregando stock: $e';
      return false;
    }
  }

  Future<bool> reducirStockObra(String obraId, String articuloId, int cantidad) async {
    try {
      await _obraService.reducirStockObra(obraId, articuloId, cantidad);
      
      final index = _obras.indexWhere((o) => o.id == obraId);
      if (index != -1) {
        await cargarObras();
      }
      
      return true;
    } catch (e) {
      _error = 'Error reduciendo stock: $e';
      return false;
    }
  }

  List<Obra> buscarObras(String query) {
    if (query.isEmpty) return _obras;
    
    final queryLower = query.toLowerCase();
    return _obras.where((obra) =>
      obra.nombre.toLowerCase().contains(queryLower) ||
      (obra.direccion?.toLowerCase().contains(queryLower) ?? false) ||
      (obra.cliente?.toLowerCase().contains(queryLower) ?? false)
    ).toList();
  }

  List<Obra> filtrarPorEstado(String estado) {
    return _obras.where((obra) => obra.estado == estado).toList();
  }

  List<Obra> get obrasActivas => _obras.where((o) => o.estaActiva).toList();
  List<Obra> get obrasPausadas => _obras.where((o) => o.estaPausada).toList();
  List<Obra> get obrasFinalizadas => _obras.where((o) => o.estaFinalizada).toList();

  Future<Map<String, int>> getEstadisticas() async {
    try {
      return await _obraService.getEstadisticasObras();
    } catch (e) {
      _error = 'Error obteniendo estadísticas: $e';
      return {'total': 0, 'activas': 0, 'pausadas': 0, 'finalizadas': 0};
    }
  }

  Future<bool> transferirStock(
    String obraOrigenId,
    String obraDestinoId,
    String articuloId,
    int cantidad,
  ) async {
    try {
      await _obraService.transferirStock(
        obraOrigenId,
        obraDestinoId,
        articuloId,
        cantidad,
      );
      
      await cargarObras();
      
      return true;
    } catch (e) {
      _error = 'Error en transferencia: $e';
      return false;
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void forzarRecarga() {
    _obras = [];
    notifyListeners();
  }
}