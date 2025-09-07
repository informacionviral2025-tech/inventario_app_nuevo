// lib/utils/app_router.dart
import 'package:flutter/material.dart';

class AppRouter {
  static void goToHome(BuildContext context, String empresaId) {
    Navigator.pushReplacementNamed(
      context, 
      '/home',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  static void goToArticulos(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/articulos',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToEntradas(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/entradas',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToSalidas(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/salidas',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToTraspasos(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/traspasos',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToReportes(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/reportes',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToNuevoArticulo(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/nuevo_articulo',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goToEditarArticulo(BuildContext context, String empresaId, String articuloId) {
    Navigator.pushNamed(
      context, 
      '/editar_articulo',
      arguments: {
        'empresaId': empresaId,
        'articuloId': articuloId,
      },
    );
  }

  static void goToNuevoTraspaso(BuildContext context, String empresaId) {
    Navigator.pushNamed(
      context, 
      '/nuevo_traspaso',
      arguments: {'empresaId': empresaId},
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  // Método para extraer empresaId de los argumentos
  static String? getEmpresaId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args['empresaId'] as String?;
    }
    if (args is String) {
      return args;
    }
    return null;
  }

  // Método para extraer argumentos
  static Map<String, dynamic>? getArguments(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args;
    }
    return null;
  }
}