// lib/services/auth_service.dart - VERSIÓN CORREGIDA
// lib/services/auth_service.dart - VERSIÓN CORREGIDA
import 'package:flutter/foundation.dart';

class AuthService {
  static const Map<String, String> _usuariosPredefinidos = {
    'admin': 'admin123',
    'gerente': 'gerente123',
    'empleado': 'empleado123',
    'supervisor': 'supervisor123',
    'almacenero': 'almacen123',
  };

  dynamic get currentUser => null; // Simulación
  String? get currentUserId => null;
  Stream<dynamic> get authStateChanges => Stream.value(null);

  Future<void> initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('AuthService inicializado correctamente');
      debugPrint('No hay usuario autenticado');
    } catch (e, st) {
      debugPrint('Error inicializando AuthService: $e\n$st');
    }
  }

  String _usernameToEmail(String username) {
    return '${username.toLowerCase().trim()}@inventario-app.local';
  }

  Future<dynamic> signInWithUsername(String username, String password) async {
    return null; // Desactivado en modo prueba
  }

  Future<dynamic> signInWithUsernameSimple(String username, String password) async {
    try {
      final String usernameLower = username.toLowerCase().trim();
      final String passwordTrim = password.trim();
      
      debugPrint('=== LOGIN SIMPLE ===');
      debugPrint('Usuario: $usernameLower');
      
      if (!_usuariosPredefinidos.containsKey(usernameLower) || 
          _usuariosPredefinidos[usernameLower] != passwordTrim) {
        debugPrint('❌ Credenciales inválidas');
        return null;
      }

      debugPrint('✅ Credenciales válidas, usuario mock creado');
      return MockUser(usernameLower); // Simulación
    } catch (e) {
      debugPrint('❌ Error en login simple: $e');
      return null;
    }
  }

  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    return null; // Desactivado en modo prueba
  }

  Future<dynamic> registerWithUsername(String username, String password, {String? displayName}) async {
    return null; // Desactivado en modo prueba
  }

  Future<dynamic> registerWithEmailAndPassword(String email, String password) async {
    return null; // Desactivado en modo prueba
  }

  Future<dynamic> signInAnonymously() async {
    return null; // Desactivado en modo prueba
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    return false; // Desactivado en modo prueba
  }

  bool get isAuthenticated => false;

  String? get currentUsername => null;

  bool isValidUser(String username) {
    return _usuariosPredefinidos.containsKey(username.toLowerCase().trim());
  }

  List<String> get validUsernames => _usuariosPredefinidos.keys.toList();

  void printValidUsers() {
    debugPrint('=== USUARIOS VÁLIDOS ===');
    _usuariosPredefinidos.forEach((user, pass) {
      debugPrint('Usuario: $user | Contraseña: $pass');
    });
    debugPrint('========================');
  }

  void debugAuthState() {
    debugPrint('=== ESTADO AUTH SERVICE ===');
    debugPrint('Usuario actual: null');
    debugPrint('Autenticado: false');
    debugPrint('Username actual: null');
    debugPrint('============================');
  }

  Future<void> signOut() async {
    debugPrint('✅ Sesión cerrada correctamente');
  }
}

class MockUser {
  final String displayName;
  MockUser(this.displayName);
  @override
  String toString() => 'MockUser(displayName: $displayName)';
}