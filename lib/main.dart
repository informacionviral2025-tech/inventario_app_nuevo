// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';

// Rutas
import 'routes.dart';
import 'routes/app_routes.dart';

// Pantallas iniciales
import 'screens/login_screen.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        // 🔜 Aquí después añadiremos más Providers (ej: vehículos, obras, etc.)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventario App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.generateRoute,
        // ❌ eliminado "home" porque ya usas initialRoute
      ),
    );
  }
}
