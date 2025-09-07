import 'package:flutter/material.dart';
import '../security/permissions.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  UserRole _currentRole = UserRole.usuarioBasico;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  UserRole get currentRole => _currentRole;

  Future<void> login(String email, String password) async {
    // Simulación de login contra backend
    _isAuthenticated = true;
    _userId = "12345";

    // Asignar rol según email
    if (email.contains("admin")) {
      _currentRole = UserRole.admin;
    } else if (email.contains("almacen")) {
      _currentRole = UserRole.encargadoAlmacen;
    } else if (email.contains("obra")) {
      _currentRole = UserRole.jefeObra;
    } else if (email.contains("mecanico")) {
      _currentRole = UserRole.mecanico;
    } else {
      _currentRole = UserRole.usuarioBasico;
    }

    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _currentRole = UserRole.usuarioBasico;
    notifyListeners();
  }
}
