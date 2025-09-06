// lib/routers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/empresa_provider.dart';
import 'screens/login_screen.dart';
import 'screens/empresa_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/obra/obras_screen.dart';
import 'screens/obra/obra_detail_screen.dart';
import 'screens/articulos/gestion_articulos_screen.dart';
import 'screens/proveedores/proveedores_screen.dart';
import 'screens/clientes/clientes_screen.dart';

class AppRouter {
  static String get initialRoute {
    return '/login';
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return _buildRoute(settings, (_) => const LoginScreen());

      case '/empresa-selection':
        return _buildRoute(settings, (_) => const EmpresaSelectionScreen(), 
          requireAuth: true);

      case '/home':
        if (args is Map<String, String>) {
          return _buildRoute(settings, (_) => HomeScreen(
            empresaId: args['empresaId']!,
            empresaNombre: args['empresaNombre']!,
          ), requireAuth: true);
        }
        return _errorRoute(settings, 'Argumentos inválidos para HomeScreen');

      case '/obras':
        return _buildRoute(settings, (_) => const ObrasScreen(), 
          requireAuth: true);

      case '/obra-detail':
        if (args is String) {
          return _buildRoute(settings, (context) {
            final empresaProvider = Provider.of<EmpresaProvider>(context, listen: false);
            if (empresaProvider.empresaSeleccionada == null) {
              return const Center(child: Text('No hay empresa seleccionada'));
            }
            return ObraDetailScreen(
              empresaId: empresaProvider.empresaSeleccionada!.id,
              obraId: args,
            );
          }, requireAuth: true);
        }
        return _errorRoute(settings, 'Argumento inválido para ObraDetail');

      case '/articulos':
        if (args is String) {
          return _buildRoute(settings, (_) => GestionArticulosScreen(empresaId: args), 
            requireAuth: true);
        }
        return _errorRoute(settings, 'Argumento inválido para GestionArticulosScreen');

      case '/proveedores':
        return _buildRoute(settings, (context) {
          final empresaProvider = Provider.of<EmpresaProvider>(context, listen: false);
          if (empresaProvider.empresaSeleccionada == null) {
            return const Center(child: Text('No hay empresa seleccionada'));
          }
          return ProveedoresScreen(
            empresaId: empresaProvider.empresaSeleccionada!.id,
          );
        }, requireAuth: true);

      case '/clientes':
        return _buildRoute(settings, (_) => const ClientesScreen(), 
          requireAuth: true);

      case '/scanner':
        return _buildRoute(settings, (_) => const ScannerScreen(), 
          requireAuth: true);

      default:
        return _errorRoute(settings, 'Ruta no encontrada');
    }
  }

  static MaterialPageRoute _buildRoute(
    RouteSettings settings,
    WidgetBuilder builder, {
    bool requireAuth = false,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        if (requireAuth) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
        }
        return builder(context);
      },
    );
  }

  static MaterialPageRoute _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  static void goToHome(BuildContext context, String empresaId, String empresaNombre) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: {
        'empresaId': empresaId,
        'empresaNombre': empresaNombre,
      },
    );
  }

  static void goToEmpresaSelection(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/empresa-selection',
      (route) => false,
    );
  }

  static Future<void> goToObraDetail(BuildContext context, String obraId) async {
    await Navigator.pushNamed(
      context,
      '/obra-detail',
      arguments: obraId,
    );
  }

  static Future<void> goToArticulos(BuildContext context, String empresaId) async {
    await Navigator.pushNamed(context, '/articulos', arguments: empresaId);
  }

  static Future<void> goToProveedores(BuildContext context) async {
    await Navigator.pushNamed(context, '/proveedores');
  }

  static Future<void> goToClientes(BuildContext context) async {
    await Navigator.pushNamed(context, '/clientes');
  }

  static Future<void> goToScanner(BuildContext context) async {
    await Navigator.pushNamed(context, '/scanner');
  }

  static void popToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.settings.name == '/home');
  }

  static void replaceWith(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static T? getArguments<T>(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments is T) {
      return route.settings.arguments as T;
    }
    return null;
  }

  static bool isCurrentRoute(BuildContext context, String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }
}

extension RouterExtension on BuildContext {
  void goTo(String routeName, {dynamic arguments}) {
    Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  void goToReplacement(String routeName, {dynamic arguments}) {
    Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
  }

  void goToAndRemoveUntil(String routeName, {dynamic arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop([dynamic result]) {
    Navigator.pop(this, result);
  }

  bool canPop() {
    return Navigator.canPop(this);
  }
}