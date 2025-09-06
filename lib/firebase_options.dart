// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuración para Web (reemplaza con tu configuración real)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-api-key',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: '123456789',
    appId: 'your-app-id',
  );

  // Configuración para Android (reemplaza con tu configuración real)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
  );

  // Configuración para iOS (reemplaza con tu configuración real)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.inventarioAppNuevo',
  );

  // Configuración para macOS (reemplaza con tu configuración real)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.inventarioAppNuevo',
  );
}

// Función para inicializar Firebase
Future<void> initializeFirebase() async {
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configurar Firestore
    if (kDebugMode) {
      print('Firebase inicializado correctamente');
      
      // Solo en modo debug, usar emulator si está disponible
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      } catch (e) {
        // Los emuladores no están disponibles, usar Firebase real
        print('Emuladores no disponibles, usando Firebase real');
      }
    }

    // Configurar settings de Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

  } catch (e) {
    if (kDebugMode) {
      print('Error inicializando Firebase: $e');
    }
    rethrow;
  }
}