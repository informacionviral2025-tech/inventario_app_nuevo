// lib/providers/albaran_provider.dart
import 'package:flutter/foundation.dart';
import '../services/albaran_proveedor_service.dart';
import '../services/albaran_traspasos_service.dart';
import '../models/albaran_proveedor.dart';

class AlbaranProvider with ChangeNotifier {
  List<AlbaranProveedor> _albaranesProveedor = [];
  List<dynamic> _albaranesTraspasos = [];
  bool _cargando = false;
  String? _error;
  String? _empresaId;

  List<AlbaranProveedor> get albaranesProveedor => _albaranesProveedor;
  List<dynamic> get albaranesTraspasos => _albaranesTraspasos;
  bool get cargando => _cargando;
  String? get error => _error;

  late AlbaranProveedorService _albaranProveedorService;
  final AlbaranTraspasosService _albaranTraspasosService = AlbaranTraspasosService();

  // Configurar empresa actual
  void setEmpresaId(String empresaId) {
    _empresaId = empresaId;
    _albaranProveedorService = AlbaranProveedorService();
  }

  // Albaranes de proveedor
  Future<void> cargarAlbaranesProveedor() async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _albaranesProveedor = await _albaranProveedorService
          .getAlbaranes(_empresaId!)
          .first;
    } catch (e) {
      _error = 'Error al cargar albaranes de proveedor: $e';
      if (kDebugMode) {
        print('Error cargando albaranes proveedor: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarAlbaranesTraspasos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _albaranesTraspasos = await _albaranTraspasosService
          .getAlbaranes()
          .first;
    } catch (e) {
      _error = 'Error al cargar albaranes de traspasos: $e';
      if (kDebugMode) {
        print('Error cargando albaranes traspasos: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<String> crearAlbaranProveedor(AlbaranProveedor albaran) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      throw Exception(_error);
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final albaranId = await _albaranProveedorService.crearAlbaran(
        _empresaId!,
        albaran,
      );

      // Recargar albaranes
      await cargarAlbaranesProveedor();

      return albaranId;
    } catch (e) {
      _error = 'Error creando albarán: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> procesarAlbaranProveedor(String albaranId) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _albaranProveedorService.procesarAlbaran(
        _empresaId!,
        albaranId,
      );

      // Recargar albaranes
      await cargarAlbaranesProveedor();
    } catch (e) {
      _error = 'Error procesando albarán: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> crearAlbaranTraspaso({
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
      await _albaranTraspasosService.crearAlbaran(
        origenId: origenId,
        destinoId: destinoId,
        tipoOrigen: tipoOrigen,
        tipoDestino: tipoDestino,
        articulos: articulos,
        usuario: usuario,
      );

      // Recargar albaranes
      await cargarAlbaranesTraspasos();
    } catch (e) {
      _error = 'Error creando albarán de traspaso: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizarEstadoAlbaranTraspaso({
    required String albaranId,
    required String nuevoEstado,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _albaranTraspasosService.actualizarEstadoAlbaran(
        albaranId: albaranId,
        nuevoEstado: nuevoEstado,
      );

      // Recargar albaranes
      await cargarAlbaranesTraspasos();
    } catch (e) {
      _error = 'Error actualizando estado: $e';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Búsqueda y filtrado
  List<AlbaranProveedor> filtrarAlbaranesProveedorPorEstado(String estado) {
    return _albaranesProveedor.where((albaran) => albaran.estado == estado).toList();
  }

  List<dynamic> filtrarAlbaranesTraspasosPorEstado(String estado) {
    return _albaranesTraspasos.where((albaran) => albaran['estado'] == estado).toList();
  }

  List<AlbaranProveedor> buscarAlbaranesProveedorPorNumero(String numero) {
    if (numero.isEmpty) return _albaranesProveedor;
    
    return _albaranesProveedor.where((albaran) =>
      albaran.numeroAlbaran.toLowerCase().contains(numero.toLowerCase())
    ).toList();
  }

  // Estadísticas
  Future<Map<String, dynamic>> getEstadisticasAlbaranesProveedor({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    if (_empresaId == null) {
      return {};
    }

    try {
      return await _albaranProveedorService.getEstadisticas(
        _empresaId!,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
    } catch (e) {
      _error = 'Error obteniendo estadísticas: $e';
      return {};
    }
  }

  // Generar número de albarán
  Future<String> generarNumeroAlbaran() async {
    if (_empresaId == null) {
      throw Exception('No se ha configurado la empresa');
    }

    try {
      return await _albaranProveedorService.generarNumeroAlbaran(_empresaId!);
    } catch (e) {
      _error = 'Error generando número: $e';
      rethrow;
    }
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Forzar recarga
  void forzarRecarga() {
    _albaranesProveedor = [];
    _albaranesTraspasos = [];
    notifyListeners();
  }
}