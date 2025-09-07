// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/salidas_inventario_screen.dart';
import '../screens/traspasos/traspaso_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String salidas = '/salidas';
  static const String traspasos = '/traspasos';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            empresaId: args['empresaId'],
            empresaNombre: args['empresaNombre'],
          ),
        );

      case salidas:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SalidasInventarioScreen(
            empresaId: args['empresaId'],
            empresaNombre: args['empresaNombre'],
          ),
        );

      case traspasos:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TraspasoScreen(
            empresaId: args['empresaId'],
            empresaNombre: args['empresaNombre'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
