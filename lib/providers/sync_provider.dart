// lib/providers/sync_provider.dart
import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../services/sincronizacion_service.dart';

class SyncProvider with ChangeNotifier {
  bool _sincronizando = false;
  String? _error;
  int _pendientes = 0;
  int _conflictos = 0;
  DateTime? _ultimaSincronizacion;

  bool get sincronizando => _sincronizando;
  String? get error => _error;
  int get pendientes => _pendientes;
  int get conflictos => _conflictos;
  DateTime? get ultimaSincronizacion => _ultimaSincronizacion;

  final SyncService _syncService = SyncService();
  final SincronizacionService _sincronizacionService = SincronizacionService();

  Future<void> sincronizarTodo(String empresaId) async {
    _sincronizando = true;
    _error = null;
    notifyListeners();

    try {
      // Sincronizar con SQLite
      await _sincronizacionService.sincronizarConFirebase(empresaId);
      
      // Sincronizar con Firebase
      await _syncService.syncAll();
      
      _ultimaSincronizacion = DateTime.now();
      await _actualizarEstado();
    } catch (e) {
      _error = 'Error en sincronización: $e';
      rethrow;
    } finally {
      _sincronizando = false;
      notifyListeners();
    }
  }

  Future<void> _actualizarEstado() async {
    try {
      final syncInfo = await _syncService.getSyncInfo();
      _pendientes = syncInfo.pendingSyncCount;
      _conflictos = syncInfo.conflictedCount;
    } catch (e) {
      _error = 'Error actualizando estado: $e';
    }
  }

  Future<Map<String, int>> obtenerEstadoSincronizacion(String empresaId) async {
    try {
      return await _sincronizacionService.obtenerEstadoSincronizacion(empresaId);
    } catch (e) {
      _error = 'Error obteniendo estado: $e';
      return {'total': 0, 'sincronizados': 0, 'pendientes': 0, 'conflictos': 0};
    }
  }

  Future<bool> verificarConexion() async {
    try {
      return await _sincronizacionService.estaConectado();
    } catch (e) {
      return false;
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}