// lib/routers.dart (actualizado)
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/proveedores/proveedores_screen.dart';
import 'screens/articulos/articulos_screen.dart';
import 'screens/obra/obras_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String entradas = '/entradas';
  static const String salidas = '/salidas';
  static const String traspasos = '/traspasos';
  static const String clientes = '/clientes';
  static const String proveedores = '/proveedores';
  static const String articulos = '/articulos';
  static const String obras = '/obras';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extraer argumentos si existen
    final args = settings.arguments as Map<String, dynamic>?;
    final empresaId = args?['empresaId'] as String?;

    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(empresaId: empresaId ?? ''),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case entradas:
        return MaterialPageRoute(
          builder: (_) => EntradasScreen(empresaId: empresaId ?? ''),
        );
      case salidas:
        return MaterialPageRoute(
          builder: (_) => SalidasInventarioScreen(empresaId: empresaId ?? ''),
        );
      case traspasos:
        return MaterialPageRoute(
          builder: (_) => TraspasoScreen(empresaId: empresaId ?? ''),
        );
      case proveedores:
        return MaterialPageRoute(
          builder: (_) => ProveedoresScreen(empresaId: empresaId ?? ''),
        );
      case articulos:
        return MaterialPageRoute(
          builder: (_) => ArticulosScreen(empresaId: empresaId ?? ''),
        );
      case obras:
        return MaterialPageRoute(
          builder: (_) => ObrasScreen(empresaId: empresaId ?? ''),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Página no encontrada'),
            ),
          ),
        );
    }
  }

  // Métodos helper para navegación
  static void goToHome(BuildContext context, String empresaId) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (route) => false,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToObraDetail(BuildContext context, String obraId) {
    Navigator.pushNamed(
      context,
      '/obra-detail',
      arguments: {'obraId': obraId},
    );
  }
}