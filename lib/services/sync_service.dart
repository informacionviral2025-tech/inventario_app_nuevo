// lib/services/sync_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/articulo.dart';
import 'database_service.dart';

class SyncInfo {
  final bool isSyncing;
  final bool hasInternetConnection;
  final int pendingSyncCount;
  final int conflictedCount;
  final DateTime lastSyncTime;

  SyncInfo({
    required this.isSyncing,
    required this.hasInternetConnection,
    required this.pendingSyncCount,
    required this.conflictedCount,
    required this.lastSyncTime,
  });
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _dbService = DatabaseService.instance;
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref();
  final StreamController<SyncInfo> _syncStatusController = StreamController<SyncInfo>.broadcast();
  
  bool _isSyncing = false;
  String? _currentCompanyId;

  Stream<SyncInfo> get syncStatusStream => _syncStatusController.stream;

  void setCurrentCompany(String companyId) {
    _currentCompanyId = companyId;
  }

  Future<SyncInfo> getSyncInfo() async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity != ConnectivityResult.none;
    
    final pendingArticles = await _getPendingSyncArticles();
    final conflictedArticles = await _getConflictedArticles();

    return SyncInfo(
      isSyncing: _isSyncing,
      hasInternetConnection: hasInternet,
      pendingSyncCount: pendingArticles.length,
      conflictedCount: conflictedArticles.length,
      lastSyncTime: DateTime.now(),
    );
  }

  Future<List<Articulo>> _getPendingSyncArticles() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'articulos',
      where: 'pendiente_sincronizacion = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Articulo.fromMap(maps[i]));
  }

  Future<List<Articulo>> _getConflictedArticles() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'articulos',
      where: 'conflicto IS NOT NULL',
    );
    return List.generate(maps.length, (i) => Articulo.fromMap(maps[i]));
  }

  Future<void> syncAll() async {
    if (_isSyncing || _currentCompanyId == null) return;

    _isSyncing = true;
    _notifySyncStatus();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw Exception('Sin conexión a internet');
      }

      await _syncPendingArticles();
      await _downloadFromFirebase();
      
    } catch (e) {
      print('Error en sincronización: $e');
    } finally {
      _isSyncing = false;
      _notifySyncStatus();
    }
  }

  Future<void> _syncPendingArticles() async {
    final pendingArticles = await _getPendingSyncArticles();
    
    for (final articulo in pendingArticles) {
      try {
        if (articulo.firebaseId == null) {
          final ref = _firebaseRef.child('companies/$_currentCompanyId/articulos').push();
          await ref.set(articulo.toFirebase());
          
          final updatedArticulo = articulo.copyWith(
            firebaseId: ref.key,
          );
          await _dbService.updateArticulo(updatedArticulo);
        } else {
          await _firebaseRef
              .child('companies/$_currentCompanyId/articulos/${articulo.firebaseId}')
              .update(articulo.toFirebase());
          
          final updatedArticulo = articulo.copyWith();
          await _dbService.updateArticulo(updatedArticulo);
        }
      } catch (e) {
        print('Error sincronizando artículo ${articulo.id}: $e');
      }
    }
  }

  Future<void> _downloadFromFirebase() async {
    try {
      final snapshot = await _firebaseRef
          .child('companies/$_currentCompanyId/articulos')
          .get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        
        for (final entry in data.entries) {
          final firebaseId = entry.key;
          final articleData = Map<String, dynamic>.from(entry.value);
          
          final db = await _dbService.database;
          final existing = await db.query(
            'articulos',
            where: 'firebase_id = ?',
            whereArgs: [firebaseId],
          );
          
          final firebaseArticle = Articulo.fromFirebase(firebaseId, articleData);
          
          if (existing.isEmpty) {
            await _dbService.insertArticulo(firebaseArticle);
          } else {
            final localArticle = Articulo.fromMap(existing.first);
            if (localArticle.fechaActualizacion.isBefore(firebaseArticle.fechaActualizacion)) {
              await _dbService.updateArticulo(firebaseArticle);
            }
          }
        }
      }
    } catch (e) {
      print('Error descargando desde Firebase: $e');
    }
  }

  void _notifySyncStatus() async {
    final syncInfo = await getSyncInfo();
    _syncStatusController.add(syncInfo);
  }

  void dispose() {
    _syncStatusController.close();
  }
}