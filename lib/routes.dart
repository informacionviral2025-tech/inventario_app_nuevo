// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/articulos/articulos_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/inventario/inventario_screen.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/articulos/nuevo_articulo_screen.dart';
import 'screens/articulos/editar_articulo_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String articulos = '/articulos';
  static const String entradas = '/entradas';
  static const String salidas = '/salidas';
  static const String traspasos = '/traspasos';
  static const String inventario = '/inventario';
  static const String reportes = '/reportes';
  static const String nuevoArticulo = '/nuevo-articulo';
  static const String editarArticulo = '/editar-articulo';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case home:
        final empresaId = args?['empresaId'] as String? ?? '';
        final empresaNombre = args?['empresaNombre'] as String? ?? 'Mi Empresa';
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            empresaId: empresaId, 
            empresaNombre: empresaNombre
          ),
        );

      case articulos:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ArticulosScreen(empresaId: empresaId),
        );

      case entradas:
        final empresaId = args?['empresaId'] as String? ?? '';
        final empresaNombre = args?['empresaNombre'] as String? ?? 'Mi Empresa';
        return MaterialPageRoute(
          builder: (_) => EntradasScreen(
            empresaId: empresaId,
            empresaNombre: empresaNombre
          ),
        );

      case salidas:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SalidasInventarioScreen(empresaId: empresaId),
        );

      case traspasos:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => TraspasoScreen(empresaId: empresaId),
        );

      case inventario:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => InventarioScreen(empresaId: empresaId),
        );

      case reportes:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ReportesScreen(empresaId: empresaId),
        );

      case nuevoArticulo:
        final empresaId = args?['empresaId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => NuevoArticuloScreen(empresaId: empresaId),
        );

      case editarArticulo:
        final empresaId = args?['empresaId'] as String? ?? '';
        final articuloId = args?['articuloId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EditarArticuloScreen(
            empresaId: empresaId,
            articuloId: articuloId,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Métodos de navegación
  static void goToHome(BuildContext context, String empresaId, {String? empresaNombre}) {
    Navigator.pushReplacementNamed(
      context,
      home,
      arguments: {
        'empresaId': empresaId,
        'empresaNombre': empresaNombre ?? 'Mi Empresa',
      },
    );
  }

  static void goToArticulos(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      articulos,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToEntradas(BuildContext context, String empresaId, {String? empresaNombre}) {
    Navigator.pushNamed(
      context,
      entradas,
      arguments: {
        'empresaId': empresaId,
        'empresaNombre': empresaNombre ?? 'Mi Empresa',
      },
    );
  }

  static void goToSalidas(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      salidas,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToTraspasos(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      traspasos,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToInventario(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      inventario,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToReportes(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      reportes,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToNuevoArticulo(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context,
      nuevoArticulo,
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToEditarArticulo(BuildContext context, String empresaId, String articuloId) {
    Navigator.pushNamed(
      context,
      editarArticulo,
      arguments: {
        'empresaId': empresaId,
        'articuloId': articuloId,
      },
    );
  }
}