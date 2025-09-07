import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/traspasos/nuevo_traspaso_screen.dart';
import 'screens/obra/obras_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final empresaId = args?['empresaId'] as String?;
    final empresaNombre = args?['empresaNombre'] as String?;

    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case '/home':
        if (empresaId != null && empresaNombre != null) {
          return MaterialPageRoute(
            builder: (_) => HomeScreen(
              empresaId: empresaId,
              empresaNombre: empresaNombre,
            ),
          );
        }
        // Si no hay parámetros, redirigir al login
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/entradas':
        if (empresaId != null && empresaNombre != null) {
          return MaterialPageRoute(
            builder: (_) => EntradasScreen(
              empresaId: empresaId,
              empresaNombre: empresaNombre,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/salidas':
        if (empresaId != null && empresaNombre != null) {
          return MaterialPageRoute(
            builder: (_) => SalidasInventarioScreen(
              empresaId: empresaId,
              empresaNombre: empresaNombre,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/traspasos':
        return MaterialPageRoute(
          builder: (_) => const TraspasoScreen(),
        );

      case '/traspasos/nuevo':
        return MaterialPageRoute(
          builder: (_) => const NuevoTraspasoScreen(),
        );

      case '/obras':
        return MaterialPageRoute(
          builder: (_) => const ObrasScreen(),
        );

      case '/inventario':
        // Por ahora redirige a home, después se puede crear una pantalla específica
        if (empresaId != null && empresaNombre != null) {
          return MaterialPageRoute(
            builder: (_) => HomeScreen(
              empresaId: empresaId,
              empresaNombre: empresaNombre,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/ajustes':
        return MaterialPageRoute(
          builder: (_) => const AjustesScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}

// Pantalla temporal de ajustes
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Pantalla de Ajustes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}