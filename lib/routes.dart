// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/articulos/articulos_screen.dart';
import 'screens/articulos/nuevo_articulo_screen.dart';
import 'screens/articulos/editar_articulo_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/entradas/entradas_inventario_screen.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/traspasos/nuevo_traspaso_screen.dart';
import 'models/articulo.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => const LoginScreen(),
      '/home': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return HomeScreen(empresaId: empresaId, empresaNombre: empresaNombre);
      },
      '/articulos': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return ArticulosScreen(empresaId: empresaId);
      },
      '/agregar-articulo': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return NuevoArticuloScreen(empresaId: empresaId);
      },
      '/editar-articulo': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final articuloId = args?['articuloId'] ?? '';
        
        return Scaffold(
          appBar: AppBar(title: const Text('Cargando...')),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
      '/entradas': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return EntradasScreen(empresaId: empresaId, empresaNombre: empresaNombre);
      },
      '/salidas': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return SalidasInventarioScreen(empresaId: empresaId);
      },
      '/inventario': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        // Cambiar a la pantalla correcta o crear EntradasInventarioScreen
        return EntradasScreen(empresaId: empresaId, empresaNombre: '');
      },
      '/reportes': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return ReportesScreen(empresaId: empresaId);
      },
      '/traspasos': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return TraspasoScreen(empresaId: empresaId);
      },
      '/nuevo-traspaso': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return NuevoTraspasoScreen(empresaId: empresaId);
      },
    };
  }
}