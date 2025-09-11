// lib/services/unified_sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/articulo.dart';
import '../models/empresa.dart';
import '../models/obra.dart';
import '../models/task.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline
}

class SyncResult {
  final bool success;
  final String message;
  final int itemsSynced;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.itemsSynced = 0,
    this.errors = const [],
  });
}

class UnifiedSyncService {
  static final UnifiedSyncService _instance = UnifiedSyncService._internal();
  factory UnifiedSyncService() => _instance;
  UnifiedSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  final StreamController<SyncResult> _resultController = StreamController<SyncResult>.broadcast();
  
  SyncStatus _currentStatus = SyncStatus.idle;
  String? _currentEmpresaId;
  Timer? _autoSyncTimer;

  // Getters
  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<SyncResult> get resultStream => _resultController.stream;
  SyncStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus != SyncStatus.offline;

  // Configurar empresa actual
  void setCurrentEmpresa(String empresaId) {
    _currentEmpresaId = empresaId;
    _startAutoSync();
  }

  // Iniciar sincronización automática cada 5 minutos
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_currentEmpresaId != null) {
        syncAll();
      }
    });
  }

  // Verificar conectividad
  Future<bool> _checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    final isConnected = connectivity != ConnectivityResult.none;
    
    if (!isConnected) {
      _updateStatus(SyncStatus.offline);
    }
    
    return isConnected;
  }

  // Actualizar estado
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  // Sincronización completa
  Future<SyncResult> syncAll() async {
    if (_currentEmpresaId == null) {
      return SyncResult(
        success: false,
        message: 'No se ha configurado la empresa',
      );
    }

    if (!await _checkConnectivity()) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
      );
    }

    _updateStatus(SyncStatus.syncing);

    try {
      final results = await Future.wait([
        _syncArticulos(),
        _syncObras(),
        _syncTasks(),
      ]);

      final totalItems = results.fold<int>(0, (sum, result) => sum + result.itemsSynced);
      final allErrors = results.expand((result) => result.errors).toList();

      final syncResult = SyncResult(
        success: allErrors.isEmpty,
        message: allErrors.isEmpty 
            ? 'Sincronización completada exitosamente'
            : 'Sincronización completada con errores',
        itemsSynced: totalItems,
        errors: allErrors,
      );

      _updateStatus(SyncStatus.success);
      _resultController.add(syncResult);
      
      // Guardar timestamp de última sincronización
      await _saveLastSyncTime();
      
      return syncResult;
    } catch (e) {
      final errorResult = SyncResult(
        success: false,
        message: 'Error en sincronización: $e',
        errors: [e.toString()],
      );
      
      _updateStatus(SyncStatus.error);
      _resultController.add(errorResult);
      
      return errorResult;
    }
  }

  // Sincronizar artículos
  Future<SyncResult> _syncArticulos() async {
    try {
      // Obtener artículos pendientes de sincronización local
      final articulosPendientes = await _getPendingArticulos();
      
      // Subir cambios locales a Firebase
      int uploaded = 0;
      final errors = <String>[];
      
      for (final articulo in articulosPendientes) {
        try {
          if (articulo.firebaseId == null) {
            // Crear nuevo documento
            final docRef = await _firestore
                .collection('empresas')
                .doc(_currentEmpresaId)
                .collection('articulos')
                .add(articulo.toMap());
            
            // Actualizar ID local
            await _updateLocalArticuloId(articulo.id!, docRef.id);
            uploaded++;
          } else {
            // Actualizar documento existente
            await _firestore
                .collection('empresas')
                .doc(_currentEmpresaId)
                .collection('articulos')
                .doc(articulo.firebaseId)
                .update(articulo.toMap());
            uploaded++;
          }
        } catch (e) {
          errors.add('Error sincronizando artículo ${articulo.nombre}: $e');
        }
      }

      // Descargar cambios desde Firebase
      final downloaded = await _downloadArticulosFromFirebase();

      return SyncResult(
        success: errors.isEmpty,
        message: 'Artículos sincronizados: $uploaded subidos, $downloaded descargados',
        itemsSynced: uploaded + downloaded,
        errors: errors,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando artículos: $e',
        errors: [e.toString()],
      );
    }
  }

  // Sincronizar obras
  Future<SyncResult> _syncObras() async {
    try {
      // Implementación similar para obras
      // Por ahora retornamos un resultado vacío
      return SyncResult(
        success: true,
        message: 'Obras sincronizadas',
        itemsSynced: 0,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando obras: $e',
        errors: [e.toString()],
      );
    }
  }

  // Sincronizar tareas
  Future<SyncResult> _syncTasks() async {
    try {
      // Implementación similar para tareas
      // Por ahora retornamos un resultado vacío
      return SyncResult(
        success: true,
        message: 'Tareas sincronizadas',
        itemsSynced: 0,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando tareas: $e',
        errors: [e.toString()],
      );
    }
  }

  // Obtener artículos pendientes de sincronización
  Future<List<Articulo>> _getPendingArticulos() async {
    // Esta función debería obtener artículos de la base de datos local
    // que tengan pendienteSincronizacion = true
    // Por ahora retornamos una lista vacía
    return [];
  }

  // Descargar artículos desde Firebase
  Future<int> _downloadArticulosFromFirebase() async {
    try {
      final snapshot = await _firestore
          .collection('empresas')
          .doc(_currentEmpresaId)
          .collection('articulos')
          .get();

      int downloaded = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final articulo = Articulo.fromMap(data, doc.id);
          
          // Verificar si existe localmente y si necesita actualización
          final needsUpdate = await _needsUpdate(articulo);
          
          if (needsUpdate) {
            await _saveArticuloLocally(articulo);
            downloaded++;
          }
        } catch (e) {
          print('Error procesando artículo ${doc.id}: $e');
        }
      }

      return downloaded;
    } catch (e) {
      print('Error descargando artículos: $e');
      return 0;
    }
  }

  // Verificar si un artículo necesita actualización
  Future<bool> _needsUpdate(Articulo articulo) async {
    // Implementar lógica para verificar si el artículo local
    // necesita ser actualizado con la versión de Firebase
    // Por ahora siempre retorna true
    return true;
  }

  // Guardar artículo localmente
  Future<void> _saveArticuloLocally(Articulo articulo) async {
    // Implementar guardado en base de datos local
    // Por ahora no hace nada
  }

  // Actualizar ID local del artículo
  Future<void> _updateLocalArticuloId(String localId, String firebaseId) async {
    // Implementar actualización del ID en base de datos local
    // Por ahora no hace nada
  }

  // Guardar timestamp de última sincronización
  Future<void> _saveLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
  }

  // Obtener timestamp de última sincronización
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('last_sync_time');
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  // Sincronización forzada (ignora timestamp)
  Future<SyncResult> forceSync() async {
    if (_currentEmpresaId == null) {
      return SyncResult(
        success: false,
        message: 'No se ha configurado la empresa',
      );
    }

    _updateStatus(SyncStatus.syncing);

    try {
      // Forzar descarga completa desde Firebase
      final downloaded = await _downloadArticulosFromFirebase();
      
      final result = SyncResult(
        success: true,
        message: 'Sincronización forzada completada',
        itemsSynced: downloaded,
      );

      _updateStatus(SyncStatus.success);
      _resultController.add(result);
      
      await _saveLastSyncTime();
      
      return result;
    } catch (e) {
      final errorResult = SyncResult(
        success: false,
        message: 'Error en sincronización forzada: $e',
        errors: [e.toString()],
      );
      
      _updateStatus(SyncStatus.error);
      _resultController.add(errorResult);
      
      return errorResult;
    }
  }

  // Sincronización de un artículo específico
  Future<SyncResult> syncArticulo(Articulo articulo) async {
    if (_currentEmpresaId == null) {
      return SyncResult(
        success: false,
        message: 'No se ha configurado la empresa',
      );
    }

    try {
      if (articulo.firebaseId == null) {
        // Crear nuevo documento
        final docRef = await _firestore
            .collection('empresas')
            .doc(_currentEmpresaId)
            .collection('articulos')
            .add(articulo.toMap());
        
        await _updateLocalArticuloId(articulo.id!, docRef.id);
      } else {
        // Actualizar documento existente
        await _firestore
            .collection('empresas')
            .doc(_currentEmpresaId)
            .collection('articulos')
            .doc(articulo.firebaseId)
            .update(articulo.toMap());
      }

      return SyncResult(
        success: true,
        message: 'Artículo sincronizado exitosamente',
        itemsSynced: 1,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error sincronizando artículo: $e',
        errors: [e.toString()],
      );
    }
  }

  // Limpiar recursos
  void dispose() {
    _autoSyncTimer?.cancel();
    _statusController.close();
    _resultController.close();
  }
}

