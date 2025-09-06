// lib/providers/auth_provider.dart - VERSIÓN CORREGIDA
// lib/providers/auth_provider.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  dynamic _user; // Cambiado a dynamic para simulación
  bool _isLoading = false;
  String? _errorMessage;

  dynamic get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUsername => _authService.currentUsername;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    debugPrint('🔄 Inicializando AuthProvider...');
    _authService.printValidUsers();
    debugPrint('✅ AuthProvider inicializado');
  }

  void _setLoading(bool loading) {
    debugPrint('Loading state: $loading');
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    debugPrint('Error state: $error');
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// MÉTODO CORREGIDO - Login con username usando modo simple
  Future<bool> loginWithUsername(String username, String password) async {
    debugPrint('🚀 AuthProvider: Iniciando login con usuario: $username');
    
    _setLoading(true);
    _clearError();

    try {
      if (username.trim().isEmpty || password.trim().isEmpty) {
        debugPrint('❌ Usuario o contraseña vacíos');
        _setError('Usuario y contraseña son requeridos');
        _setLoading(false);
        return false;
      }

      if (!_authService.isValidUser(username.trim())) {
        debugPrint('❌ Usuario no válido: $username');
        _setError('Usuario no válido. Usuarios disponibles: ${_authService.validUsernames.join(", ")}');
        _setLoading(false);
        return false;
      }

      debugPrint('✅ Usuario válido, procediendo con autenticación...');
      final user = await _authService.signInWithUsernameSimple(username, password);
      
      if (user != null) {
        debugPrint('✅ AuthProvider: Login exitoso para usuario: $username');
        _user = user;
        _clearError();
        _setLoading(false);
        return true;
      } else {
        debugPrint('❌ AuthProvider: Login falló para usuario: $username');
        _setError('Usuario o contraseña incorrectos');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ AuthProvider: Error en login: $e');
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  /// MÉTODO ALTERNATIVO - Login simple para testing
  Future<bool> loginWithUsernameSimple(String username, String password) async {
    debugPrint('🚀 AuthProvider: Login simple con usuario: $username');
    
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithUsernameSimple(username, password);
      
      if (user != null) {
        debugPrint('✅ Login simple exitoso');
        _user = user;
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError('Usuario o contraseña incorrectos');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error en login simple: $e');
      _setError('Error en autenticación: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    _setError('Método no disponible en modo prueba');
    _setLoading(false);
    return false;
  }

  /// Cerrar sesión
  Future<void> logout() async {
    debugPrint('🚀 Cerrando sesión...');
    _setLoading(true);

    try {
      _user = null;
      _clearError();
      debugPrint('✅ Sesión cerrada exitosamente');
    } catch (e) {
      debugPrint('❌ Error en logout: $e');
      _setError('Error cerrando sesión');
    } finally {
      _setLoading(false);
    }
  }

  bool isValidUser(String username) {
    return _authService.isValidUser(username);
  }

  List<String> get validUsernames => _authService.validUsernames;

  bool verifyCredentials(String username, String password) {
    final validUsers = {
      'admin': 'admin123',
      'gerente': 'gerente123',
      'empleado': 'empleado123',
      'supervisor': 'supervisor123',
      'almacenero': 'almacen123',
    };
    
    final userLower = username.toLowerCase().trim();
    return validUsers.containsKey(userLower) && 
           validUsers[userLower] == password.trim();
  }

  void debugCurrentState() {
    debugPrint('=== ESTADO ACTUAL AUTH PROVIDER ===');
    debugPrint('Usuario autenticado: $isAuthenticated');
    debugPrint('Usuario actual: ${_user?.toString() ?? 'null'}');
    debugPrint('Username actual: ${currentUsername ?? 'null'}');
    debugPrint('Cargando: $_isLoading');
    debugPrint('Error: ${_errorMessage ?? 'ninguno'}');
    debugPrint('Usuarios válidos: ${validUsernames.join(", ")}');
    debugPrint('====================================');
    _authService.debugAuthState();
  }
}