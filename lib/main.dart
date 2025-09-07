// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/inventory_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider que se inicializa cuando se necesita una empresaId
        ChangeNotifierProxyProvider<void, InventoryProvider?>(
          create: (context) => null,
          update: (context, _, previous) => previous,
        ),
      ],
      child: MaterialApp(
        title: 'Sistema de Inventario',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: AppRoute.getRoutes),
        onGenerateRoute: (settings) {
          // Manejar rutas que necesitan argumentos especiales
          final String routeName = settings.name ?? '';
          final dynamic arguments = settings.arguments;

          // Para rutas que necesitan InventoryProvider
          if (routeName.contains('/home') || 
              routeName.contains('/articulos') || 
              routeName.contains('/entradas') ||
              routeName.contains('/salidas') ||
              routeName.contains('/traspasos') ||
              routeName.contains('/reportes')) {
            
            String empresaId = '';
            if (arguments is Map<String, dynamic>) {
              empresaId = arguments['empresaId'] ?? '';
            } else if (arguments is String) {
              empresaId = arguments;
            }

            if (empresaId.isNotEmpty) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => InventoryProvider(empresaId),
                  child: AppRoutes.getRoutes()[routeName]!(context),
                ),
              );
            }
          }

          // Para rutas normales, usar el builder por defecto
          final routeBuilder = AppRoutes.getRoutes()[routeName];
          if (routeBuilder != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: routeBuilder,
            );
          }

          // Ruta no encontrada
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Pantalla no encontrada'),
              ),
            ),
          );
        },
      ),
    );
  }
}