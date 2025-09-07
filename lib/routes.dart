// lib/routers.dart (actualizado)
import 'package:flutter/material.dart';

// Screens principales
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// Inventario
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/obra/obras_screen.dart';
import 'screens/clientes/clientes_screen.dart';
import 'screens/proveedores/proveedores_screen.dart';
import 'screens/articulos_screen.dart';

// Tareas
import 'screens/tasks/tasks_screen.dart';

// Rutas centralizadas
import 'routes/app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.entradasInventario:
        return MaterialPageRoute(builder: (_) => const EntradasScreen());
      case AppRoutes.salidasInventario:
        return MaterialPageRoute(builder: (_) => const SalidasInventarioScreen());
      case AppRoutes.traspasos:
        return MaterialPageRoute(builder: (_) => const TraspasoScreen());
      case AppRoutes.obras:
        return MaterialPageRoute(builder: (_) => const ObrasScreen());
      case AppRoutes.clientes:
        return MaterialPageRoute(builder: (_) => const ClientesScreen());
      case AppRoutes.proveedores:
        return MaterialPageRoute(builder: (_) => const ProveedoresScreen());
      case AppRoutes.articulos:
        return MaterialPageRoute(builder: (_) => const ArticulosScreen());
      case AppRoutes.tareas:
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
