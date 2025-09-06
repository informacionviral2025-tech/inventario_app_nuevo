// lib/utils/debug_auth_helper.dart - HERRAMIENTAS DE DEBUGGING
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugAuthHelper {
  static const Map<String, String> validCredentials = {
    'admin': 'admin123',
    'gerente': 'gerente123',
    'empleado': 'empleado123',
    'supervisor': 'supervisor123',
    'almacenero': 'almacen123',
  };

  /// Verificar si las credenciales son correctas localmente
  static bool verifyLocalCredentials(String username, String password) {
    final userLower = username.toLowerCase().trim();
    final passTrimmed = password.trim();
    
    debugPrint('=== VERIFICACIÓN LOCAL ===');
    debugPrint('Usuario ingresado: "$userLower"');
    debugPrint('Contraseña ingresada: "$passTrimmed"');
    debugPrint('Usuario existe: ${validCredentials.containsKey(userLower)}');
    
    if (validCredentials.containsKey(userLower)) {
      final expectedPass = validCredentials[userLower]!;
      debugPrint('Contraseña esperada: "$expectedPass"');
      debugPrint('Contraseñas coinciden: ${expectedPass == passTrimmed}');
      return expectedPass == passTrimmed;
    }
    
    debugPrint('Usuario no encontrado');
    return false;
  }

  /// Imprimir estado actual de Firebase Auth
  static void printFirebaseAuthState() {
    final auth = FirebaseAuth.instance;
    debugPrint('=== ESTADO FIREBASE AUTH ===');
    debugPrint('Usuario actual: ${auth.currentUser?.email ?? 'null'}');
    debugPrint('UID: ${auth.currentUser?.uid ?? 'null'}');
    debugPrint('Display Name: ${auth.currentUser?.displayName ?? 'null'}');
    debugPrint('Email verificado: ${auth.currentUser?.emailVerified ?? false}');
    debugPrint('Autenticado: ${auth.currentUser != null}');
    debugPrint('============================');
  }

  /// Limpiar sesión de Firebase
  static Future<void> clearFirebaseAuth() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Sesión de Firebase limpiada');
    } catch (e) {
      debugPrint('❌ Error limpiando sesión: $e');
    }
  }

  /// Imprimir todos los usuarios válidos
  static void printValidUsers() {
    debugPrint('=== USUARIOS VÁLIDOS ===');
    validCredentials.forEach((user, pass) {
      debugPrint('$user -> $pass');
    });
    debugPrint('========================');
  }

  /// Test completo de credenciales
  static void testAllCredentials() {
    debugPrint('=== TESTING TODAS LAS CREDENCIALES ===');
    
    final testCases = [
      ['admin', 'admin123'],
      ['Admin', 'admin123'], // Test case sensitive
      ['gerente', 'gerente123'],
      ['empleado', 'empleado123'],
      ['supervisor', 'supervisor123'],
      ['almacenero', 'almacen123'],
      ['admin', 'wrong'], // Test contraseña incorrecta
      ['noexiste', 'password'], // Test usuario inexistente
    ];

    for (final testCase in testCases) {
      final user = testCase[0];
      final pass = testCase[1];
      final result = verifyLocalCredentials(user, pass);
      debugPrint('$user/$pass -> ${result ? "✅" : "❌"}');
    }
    
    debugPrint('=====================================');
  }

  /// Generar email para Firebase a partir de username
  static String generateFirebaseEmail(String username) {
    return '${username.toLowerCase()}@inventario-app.local';
  }

  /// Test específico para un usuario
  static void testSpecificUser(String username, String password) {
    debugPrint('=== TEST ESPECÍFICO ===');
    debugPrint('Usuario: $username');
    debugPrint('Contraseña: $password');
    
    // Test local
    final localResult = verifyLocalCredentials(username, password);
    debugPrint('Verificación local: ${localResult ? "✅" : "❌"}');
    
    // Generar email
    final email = generateFirebaseEmail(username);
    debugPrint('Email generado: $email');
    
    // Estado actual de Firebase
    printFirebaseAuthState();
    
    debugPrint('=====================');
  }

  /// Diagnóstico completo del sistema
  static void fullDiagnostic() {
    debugPrint('\n🔍 === DIAGNÓSTICO COMPLETO === 🔍');
    
    // 1. Usuarios válidos
    printValidUsers();
    
    // 2. Estado de Firebase
    printFirebaseAuthState();
    
    // 3. Test de credenciales
    testAllCredentials();
    
    debugPrint('🔍 === FIN DIAGNÓSTICO === 🔍\n');
  }

  /// Simular proceso de login paso a paso
  static void simulateLogin(String username, String password) {
    debugPrint('\n🚀 === SIMULACIÓN DE LOGIN === 🚀');
    debugPrint('Usuario: "$username"');
    debugPrint('Contraseña: "$password"');
    
    // Paso 1: Normalizar datos
    final userLower = username.toLowerCase().trim();
    final passTrimmed = password.trim();
    debugPrint('PASO 1 - Normalización:');
    debugPrint('  Usuario normalizado: "$userLower"');
    debugPrint('  Contraseña normalizada: "$passTrimmed"');
    
    // Paso 2: Verificar usuario existe
    debugPrint('PASO 2 - Verificar usuario:');
    final userExists = validCredentials.containsKey(userLower);
    debugPrint('  Usuario existe: ${userExists ? "✅" : "❌"}');
    
    if (!userExists) {
      debugPrint('  Usuarios disponibles: ${validCredentials.keys.toList()}');
      debugPrint('🚀 === FIN SIMULACIÓN (FALLÓ) === 🚀\n');
      return;
    }
    
    // Paso 3: Verificar contraseña
    debugPrint('PASO 3 - Verificar contraseña:');
    final expectedPass = validCredentials[userLower]!;
    final passMatch = expectedPass == passTrimmed;
    debugPrint('  Contraseña esperada: "$expectedPass"');
    debugPrint('  Contraseña recibida: "$passTrimmed"');
    debugPrint('  Contraseñas coinciden: ${passMatch ? "✅" : "❌"}');
    
    if (!passMatch) {
      debugPrint('🚀 === FIN SIMULACIÓN (FALLÓ) === 🚀\n');
      return;
    }
    
    // Paso 4: Generar email para Firebase
    debugPrint('PASO 4 - Generar email:');
    final email = generateFirebaseEmail(userLower);
    debugPrint('  Email generado: "$email"');
    
    // Paso 5: Estado actual
    debugPrint('PASO 5 - Estado actual:');
    printFirebaseAuthState();
    
    debugPrint('✅ Simulación completada exitosamente');
    debugPrint('🚀 === FIN SIMULACIÓN (ÉXITO) === 🚀\n');
  }
}