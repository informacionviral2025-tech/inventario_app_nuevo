// lib/services/sync_helper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

/// Helper que gestiona la sincronización automática
/// entre SQLite y Firebase según la conectividad.
class SyncHelper {
  static final SyncHelper _instance = SyncHelper._internal();
  factory SyncHelper() => _instance;
  SyncHelper._internal();

  final SyncService _syncService = SyncService();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isInitialized = false;
  String? _currentCompanyId;

  /// Contexto global para mostrar SnackBars
  static BuildContext? globalContext;

  void init(String companyId) {
    if (_isInitialized) return;
    _currentCompanyId = companyId;
    _syncService.setCurrentCompany(companyId);

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result.first != ConnectivityResult.none) {
        _syncWithFeedback();
      }
    });

    _checkInitialConnection();
    _isInitialized = true;
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (result.first != ConnectivityResult.none) {
      _syncWithFeedback();
    }
  }

  Future<void> _syncWithFeedback() async {
    try {
      await _syncService.syncAll();
      _showSnack('Sincronización completada ✅');
    } catch (e) {
      _showSnack('Error al sincronizar: ${e.toString()}');
    }
  }

  Future<void> syncNow() async {
    if (_currentCompanyId == null) {
      _showSnack('No se ha seleccionado empresa');
      return;
    }
    await _syncWithFeedback();
  }

  void _showSnack(String message) {
    if (globalContext == null) return;
    ScaffoldMessenger.of(globalContext!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void dispose() {
    _subscription.cancel();
    _syncService.dispose();
    _isInitialized = false;
  }
}