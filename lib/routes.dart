// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/articulos/articulos_screen.dart';
import 'screens/articulos/nuevo_articulo_screen.dart';
import 'screens/articulos/editar_articulo_screen.dart';
import 'screens/entradas/entradas_screen.dart';
import 'screens/entradas/entradas_inventario_screen.dart';
import 'screens/salidas_inventario_screen.dart';
import 'screens/entradas/entradas_inventario_screen.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/traspasos/traspaso_screen.dart';
import 'screens/traspasos/nuevo_traspaso_screen.dart';
import 'screens/scanner/integrated_scanner_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/obra/obras_screen.dart';
import 'screens/albaranes/recepcion_albaran_scan_screen.dart';
import 'screens/albaranes/lista_albaranes_screen.dart';
import 'screens/proveedores/gestion_proveedores_screen.dart';
import 'screens/clientes/clientes_screen.dart';
import 'screens/tabs/configuracion_tab.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/usuarios/gestion_usuarios_screen.dart';
import 'models/articulo.dart';

class AppRoutes {
  // Función helper para cargar pantalla de edición
  static Widget _loadEditarArticuloScreen(String empresaId, String articuloId) {
    // Por ahora retornamos un placeholder hasta que se implemente la pantalla real
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Artículo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Editar artículo: $articuloId'),
            const SizedBox(height: 8),
            Text('Empresa: $empresaId'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar navegación a pantalla de edición real
              },
              child: const Text('Implementar Edición'),
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => const LoginScreen(),
      '/home': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return MainNavigationScreen(empresaId: empresaId, empresaNombre: empresaNombre);
      },
      '/albaranes/recepcion-scan': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        final albaranId = args?['albaranId'];
        final numeroAlbaran = args?['numeroAlbaran'];
        return RecepcionAlbaranScanScreen(
          empresaId: empresaId,
          empresaNombre: empresaNombre,
          albaranId: albaranId,
          numeroAlbaran: numeroAlbaran,
        );
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
        
        // Usar la pantalla de edición
        return _loadEditarArticuloScreen(empresaId, articuloId);
      },
      '/entradas': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return EntradaInventarioScreen(empresaId: empresaId, empresaNombre: empresaNombre);
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
      // Rutas del escáner integrado
      '/scanner/entrada': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return IntegratedScannerScreen(
          empresaId: empresaId,
          empresaNombre: empresaNombre,
          mode: ScannerMode.entrada,
        );
      },
      '/scanner/salida': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return IntegratedScannerScreen(
          empresaId: empresaId,
          empresaNombre: empresaNombre,
          mode: ScannerMode.salida,
        );
      },
      '/scanner/busqueda': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return IntegratedScannerScreen(
          empresaId: empresaId,
          empresaNombre: empresaNombre,
          mode: ScannerMode.busqueda,
        );
      },
      // Rutas para tareas
      '/tasks': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return TasksScreen(empresaId: empresaId);
      },
      // Rutas para obras
      '/obras': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return ObrasScreen(empresaId: empresaId);
      },
      // Rutas para albaranes
      '/albaranes': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        final empresaNombre = args?['empresaNombre'] ?? '';
        return ListaAlbaranesScreen(empresaId: empresaId, empresaNombre: empresaNombre);
      },
      // Rutas para proveedores
      '/proveedores': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return GestionProveedoresScreen(empresaId: empresaId);
      },
      // Rutas para clientes
      '/clientes': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return ClientesScreen(empresaId: empresaId);
      },
      // Rutas para ajustes
      '/ajustes': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return Scaffold(
          appBar: AppBar(title: const Text('Ajustes')),
          body: ConfiguracionTab(empresaId: empresaId),
        );
      },
      // Rutas para gestión de usuarios
      '/usuarios': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final empresaId = args?['empresaId'] ?? '';
        return GestionUsuariosScreen(empresaId: empresaId);
      },
    };
  }
}