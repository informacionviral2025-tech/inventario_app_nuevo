// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/articulos_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/traspasos/nuevo_traspaso_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/nuevo_articulo_screen.dart';
import 'screens/editar_articulo_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String articulos = '/articulos';
  static const String entradas = '/entradas';
  static const String salidas = '/salidas';
  static const String traspasos = '/traspasos';
  static const String nuevoTraspaso = '/nuevo_traspaso';
  static const String reportes = '/reportes';
  static const String nuevoArticulo = '/nuevo_articulo';
  static const String editarArticulo = '/editar_articulo';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return HomeScreen(empresaId: empresaId);
      },
      articulos: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return ArticulosScreen(empresaId: empresaId);
      },
      entradas: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return EntradasScreen(empresaId: empresaId);
      },
      salidas: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return SalidasInventarioScreen(empresaId: empresaId);
      },
      traspasos: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return TraspasoScreen(empresaId: empresaId);
      },
      nuevoTraspaso: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return NuevoTraspasoScreen(empresaId: empresaId);
      },
      reportes: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return ReportesScreen(empresaId: empresaId);
      },
      nuevoArticulo: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String empresaId = '';
        
        if (args is Map<String, dynamic>) {
          empresaId = args['empresaId'] ?? '';
        } else if (args is String) {
          empresaId = args;
        }
        
        return NuevoArticuloScreen(empresaId: empresaId);
      },
      editarArticulo: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
        final empresaId = args['empresaId'] as String? ?? '';
        final articuloId = args['articuloId'] as String? ?? '';
        
        return EditarArticuloScreen(
          empresaId: empresaId,
          articuloId: articuloId,
        );
      },
    };
  }

  // Método de utilidad para navegar con argumentos
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  // Método de utilidad para reemplazar ruta
  static Future<T?> navigateAndReplace<T extends Object?>(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, Object?>(
      context, 
      routeName, 
      arguments: arguments,
    );
  }

  // Método de utilidad para limpiar stack y navegar
  static Future<T?> navigateAndClearStack<T extends Object?>(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }
}