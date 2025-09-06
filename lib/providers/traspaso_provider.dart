// lib/providers/traspaso_provider.dart
import 'package:flutter/foundation.dart';
import '../services/traspaso_service.dart';

class TraspasoProvider with ChangeNotifier {
  List<Map<String, dynamic>> _traspasos = [];
  List<Map<String, dynamic>> _albaranes = [];
  bool _cargando = false;
  String? _error;

  List<Map<String, dynamic>> get traspasos => _traspasos;
  List<Map<String, dynamic>> get albaranes => _albaranes;
  bool get cargando => _cargando;
  String? get error => _error;

  final TraspasoService _traspasoService = TraspasoService();

  Future<void> cargarTraspasosPorEntidad({
    required String entidadId,
    required String tipoEntidad,
    String? estado,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _traspasos = await _traspasoService
          .obtenerTraspasosPorEntidad(
            entidadId: entidadId,
            tipoEntidad: tipoEntidad,
            estado: estado,
          )
          .first;
    } catch (e) {
      _error = 'Error al cargar traspasos: $e';
      if (kDebugMode) {
        print('Error cargando traspasos: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarAlbaranes({String? estado}) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _albaranes = await _traspasoService
          .obtenerAlbaranes(estado: estado)
          .first;
    } catch (e) {
      _error = 'Error al cargar albaranes: $e';
      if (kDebugMode) {
        print('Error cargando albaranes: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<String> crearTraspaso({
    required String origenId,
    required String destinoId,
    required String tipoOrigen,
    required String tipoDestino,
    required Map<String, int> articulos,
    required String usuario,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final traspasoId = await _traspasoService.crearTraspaso(
        origenId: origenId,
        destinoId: destinoId,
        tipoOrigen: tipoOrigen,
        tipoDestino: tipoDestino,
        articulos: articulos,
        usuario: usuario,
      );

      // Recargar traspasos
      await cargarTraspasosPorEntidad(
        entidadId: origenId,
        tipoEntidad: tipoOrigen,
      );

      return traspasoId;
    } catch (e) {
      _error = 'Error creando traspaso: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> confirmarRecepcionAlbaran(String albaranId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _traspasoService.confirmarRecepcion(albaranId);
      
      // Recargar albaranes
      await cargarAlbaranes();
    } catch (e) {
      _error = 'Error confirmando recepción: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> devolverTraspaso(String traspasoId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _traspasoService.devolverTraspaso(traspasoId);
      
      // Recargar traspasos
      final traspaso = _traspasos.firstWhere(
        (t) => t['id'] == traspasoId,
        orElse: () => {},
      );
      
      if (traspaso.isNotEmpty) {
        await cargarTraspasosPorEntidad(
          entidadId: traspaso['origenId'],
          tipoEntidad: traspaso['tipoOrigen'],
        );
      }
    } catch (e) {
      _error = 'Error devolviendo traspaso: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Map<String, int>> obtenerStockDisponible(
    String entidadId,
    String tipoEntidad,
  ) async {
    try {
      return await _traspasoService.obtenerStockDisponible(
        entidadId,
        tipoEntidad,
      );
    } catch (e) {
      _error = 'Error obteniendo stock: $e';
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialTraspasos({
    required String entidadId,
    required String tipoEntidad,
  }) async {
    try {
      return await _traspasoService
          .obtenerHistorialTraspasos(
            entidadId: entidadId,
            tipoEntidad: tipoEntidad,
          )
          .first;
    } catch (e) {
      _error = 'Error obteniendo historial: $e';
      return [];
    }
  }

  // Búsqueda y filtrado
  List<Map<String, dynamic>> filtrarTraspasosPorEstado(String estado) {
    return _traspasos.where((traspaso) => traspaso['estado'] == estado).toList();
  }

  List<Map<String, dynamic>> filtrarAlbaranesPorEstado(String estado) {
    return _albaranes.where((albaran) => albaran['estado'] == estado).toList();
  }

  Map<String, dynamic>? obtenerTraspasoPorId(String id) {
    try {
      return _traspasos.firstWhere((traspaso) => traspaso['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? obtenerAlbaranPorId(String id) {
    try {
      return _albaranes.firstWhere((albaran) => albaran['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Estadísticas
  Map<String, int> get estadisticasTraspasos {
    final total = _traspasos.length;
    final completados = _traspasos.where((t) => t['estado'] == 'completado').length;
    final pendientes = _traspasos.where((t) => t['estado'] == 'pendiente').length;
    final devueltos = _traspasos.where((t) => t['estado'] == 'devuelto').length;

    return {
      'total': total,
      'completados': completados,
      'pendientes': pendientes,
      'devueltos': devueltos,
    };
  }

  Map<String, int> get estadisticasAlbaranes {
    final total = _albaranes.length;
    final pendientes = _albaranes.where((a) => a['estado'] == 'pendiente').length;
    final confirmados = _albaranes.where((a) => a['estado'] == 'confirmado').length;
    final devueltos = _albaranes.where((a) => a['estado'] == 'devuelto').length;

    return {
      'total': total,
      'pendientes': pendientes,
      'confirmados': confirmados,
      'devueltos': devueltos,
    };
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Forzar recarga
  void forzarRecarga() {
    _traspasos = [];
    _albaranes = [];
    notifyListeners();
  }
}