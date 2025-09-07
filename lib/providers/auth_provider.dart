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
    // Escuchar cambios en el estado de autenticación
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    
    if (user != null) {
      // Cargar datos del usuario desde Firestore
      await _loadUserData(user.uid);
    } else {
      _currentUser = null;
    }
    
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      _error = 'Error cargando datos del usuario';
    }
  }

  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _loadUserData(result.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
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

    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
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
        await _loadUserData(result.user!.uid);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualizar datos del usuario
  Future<bool> updateUserData(UserModel userData) async {
    try {
      await _firestore.collection('usuarios').doc(_user!.uid).update(userData.toFirestore());
      _currentUser = userData;
      notifyListeners();
      return true;
    } catch (e) {
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
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}