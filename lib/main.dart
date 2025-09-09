// lib/main.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart'; // NECESARIO AGREGAR ESTE
import 'screens/login_screen.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => InventoryProvider()), // AGREGAR ESTO
      ],
      child: MaterialApp(
        title: 'Inventario App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // CAMBIAR: usar initialRoute en lugar de home
        initialRoute: '/',
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}