import 'package:flutter/foundation.dart';
import '../security/permissions.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentUsername;
  String? _errorMessage;
  UserRole _currentRole = UserRole.usuarioBasico;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUsername => _currentUsername;
  String? get errorMessage => _errorMessage;
  UserRole get currentRole => _currentRole;

  /// Debug helper
  void debugCurrentState() {
    debugPrint('AuthProvider => '
        'isAuthenticated=$_isAuthenticated, '
        'isLoading=$_isLoading, '
        'currentUsername=$_currentUsername, '
        'role=$_currentRole');
  }

  /// Login con validación de credenciales reales (ejemplo simulado)
  Future<bool> loginWithUsername(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simular delay

    final valid = verifyCredentials(username, password);
    if (valid) {
      _isAuthenticated = true;
      _currentUsername = username;
      _currentRole = _mapUserToRole(username);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      _errorMessage = "Usuario o contraseña incorrectos";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login rápido para testing (sin validación estricta)
  Future<bool> loginWithUsernameSimple(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = true;
    _currentUsername = username;
    _currentRole = _mapUserToRole(username);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Verificación local de credenciales de prueba
  bool verifyCredentials(String username, String password) {
    const users = {
      "admin": "admin123",
      "gerente": "gerente123",
      "empleado": "empleado123",
      "supervisor": "supervisor123",
      "almacenero": "almacen123",
    };

    return users[username] == password;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUsername = null;
    _currentRole = UserRole.usuarioBasico;
    notifyListeners();
  }

  /// Asigna rol según usuario
  UserRole _mapUserToRole(String username) {
    switch (username) {
      case "admin":
        return UserRole.admin;
      case "gerente":
        return UserRole.gerente;
      case "empleado":
        return UserRole.empleado;
      case "supervisor":
        return UserRole.supervisor;
      case "almacenero":
        return UserRole.almacenero;
      default:
        return UserRole.usuarioBasico;
    }
  }
}
