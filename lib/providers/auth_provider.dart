// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? empresaId;
  final String? empresaNombre;
  final String? rol;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.empresaId,
    this.empresaNombre,
    this.rol,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      empresaId: data['empresaId'],
      empresaNombre: data['empresaNombre'],
      rol: data['rol'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'empresaId': empresaId,
      'empresaNombre': empresaNombre,
      'rol': rol,
    };
  }
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _currentUser != null;

  AuthProvider() {
    print('AuthProvider inicializado');
    // Escuchar cambios en el estado de autenticación
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    print('Cambio en estado de autenticación: ${user != null ? "Usuario autenticado" : "Usuario no autenticado"}');
    _user = user;
    
    if (user != null) {
      print('Usuario Firebase UID: ${user.uid}');
      print('Usuario Firebase Email: ${user.email}');
      // Cargar datos del usuario desde Firestore
      await _loadUserData(user.uid);
    } else {
      print('No hay usuario autenticado');
      _currentUser = null;
    }
    
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print('Cargando datos del usuario desde Firestore: $uid');
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        print('Usuario encontrado en Firestore: ${doc.data()}');
        _currentUser = UserModel.fromFirestore(doc);
        print('Datos cargados - Email: ${_currentUser?.email}');
        print('Datos cargados - DisplayName: ${_currentUser?.displayName}');
        print('Datos cargados - EmpresaId: ${_currentUser?.empresaId}');
        print('Datos cargados - EmpresaNombre: ${_currentUser?.empresaNombre}');
        print('Datos cargados - Rol: ${_currentUser?.rol}');
      } else {
        print('⚠️ USUARIO NO ENCONTRADO EN FIRESTORE');
        print('El usuario con UID $uid no existe en la colección "usuarios"');
        _error = 'Usuario no encontrado en la base de datos';
      }
    } catch (e) {
      print('❌ Error cargando datos del usuario: $e');
      _error = 'Error cargando datos del usuario';
    }
  }

  // Iniciar sesión - CON SOLUCIÓN TEMPORAL
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔐 Intentando login con: $email');

    // SOLUCIÓN TEMPORAL: Login simulado para testing
    if (email == 'admin@inventario.com' && password == '123456') {
      print('✅ Login simulado exitoso - Credenciales de prueba');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay de red
      
      // Crear usuario simulado
      _currentUser = UserModel(
        uid: 'test_uid_001',
        email: email,
        displayName: 'Administrador',
        empresaId: 'empresa_test_001',
        empresaNombre: 'Empresa de Prueba',
        rol: 'admin',
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ Login exitoso, UID: ${result.user!.uid}');
        await _loadUserData(result.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Error de Firebase: ${e.code} - ${e.message}');
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      _isLoading = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Registrar usuario
  Future<bool> signUp(String email, String password, String displayName, String empresaId, String empresaNombre) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('📝 Registrando nuevo usuario: $email');

    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ Usuario registrado exitosamente, UID: ${result.user!.uid}');
        
        // Crear documento del usuario en Firestore
        final userData = UserModel(
          uid: result.user!.uid,
          email: email,
          displayName: displayName,
          empresaId: empresaId,
          empresaNombre: empresaNombre,
          rol: 'usuario',
        );

        await _firestore.collection('usuarios').doc(result.user!.uid).set(userData.toFirestore());
        print('✅ Documento de usuario creado en Firestore');
        
        await _loadUserData(result.user!.uid);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Error de Firebase al registrar: ${e.code} - ${e.message}');
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error inesperado al registrar: $e');
      _isLoading = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      print('🚪 Cerrando sesión...');
      await _firebaseAuth.signOut();
      _currentUser = null;
      _user = null;
      print('✅ Sesión cerrada exitosamente');
      notifyListeners();
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      _error = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('📧 Enviando email de restablecimiento a: $email');

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Email de restablecimiento enviado');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Error enviando email: ${e.code} - ${e.message}');
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      _isLoading = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualizar datos del usuario
  Future<bool> updateUserData(UserModel userData) async {
    try {
      print('🔄 Actualizando datos del usuario: ${_user!.uid}');
      await _firestore.collection('usuarios').doc(_user!.uid).update(userData.toFirestore());
      _currentUser = userData;
      print('✅ Datos actualizados exitosamente');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error al actualizar datos: $e');
      _error = 'Error al actualizar datos: $e';
      notifyListeners();
      return false;
    }
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener mensaje de error en español
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }

  // Método temporal para crear usuario de prueba
  Future<void> createTestUser() async {
    try {
      print('🛠️ Creando usuario de prueba...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: 'admin@inventario.com',
        password: '123456',
      );
      
      // Crear documento en Firestore
      final userData = UserModel(
        uid: userCredential.user!.uid,
        email: 'admin@inventario.com',
        displayName: 'Administrador',
        empresaId: 'empresa_test_001',
        empresaNombre: 'Empresa de Prueba',
        rol: 'admin',
      );
      
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set(userData.toFirestore());
      print('✅ Usuario de prueba creado exitosamente en Firebase');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ Usuario de prueba ya existe en Firebase');
      } else {
        print('❌ Error creando usuario de prueba en Firebase: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('❌ Error inesperado creando usuario de prueba: $e');
    }
  }
}