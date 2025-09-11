// lib/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sync_status_widget.dart';
import 'tabs/inventario_tab.dart';
import 'tabs/operaciones_tab.dart';
import 'tabs/gestion_tab.dart';
import 'tabs/configuracion_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const MainNavigationScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventario Pro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.empresaNombre,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: _getTabColor(_currentIndex),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const SyncButton(),
          const SyncStatusWidget(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) => _onMenuAction(value, authProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Mi Perfil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Ayuda'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Inventario',
            ),
            Tab(
              icon: Icon(Icons.swap_horiz),
              text: 'Operaciones',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Gestión',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Configuración',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InventarioTab(
            empresaId: widget.empresaId,
            empresaNombre: widget.empresaNombre,
          ),
          OperacionesTab(
            empresaId: widget.empresaId,
            empresaNombre: widget.empresaNombre,
          ),
          GestionTab(
            empresaId: widget.empresaId,
            empresaNombre: widget.empresaNombre,
          ),
          ConfiguracionTab(empresaId: widget.empresaId),
        ],
      ),
    );
  }

  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue.shade600; // Inventario
      case 1:
        return Colors.green.shade600; // Operaciones
      case 2:
        return Colors.orange.shade600; // Gestión
      case 3:
        return Colors.purple.shade600; // Configuración
      default:
        return Colors.blue.shade600;
    }
  }

  void _onMenuAction(String action, AuthProvider authProvider) {
    switch (action) {
      case 'profile':
        _showProfileDialog();
        break;
      case 'settings':
        _tabController.animateTo(3); // Ir a Configuración
        break;
      case 'help':
        _showHelpDialog();
        break;
      case 'logout':
        _showLogoutDialog(authProvider);
        break;
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mi Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Usuario: ${Provider.of<AuthProvider>(context, listen: false).user?.email ?? "N/A"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Empresa: ${widget.empresaNombre}'),
            const SizedBox(height: 8),
            Text('ID Empresa: ${widget.empresaId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Inventario Pro - Guía Rápida',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text('📦 Inventario: Gestiona artículos, stock y ubicaciones'),
              SizedBox(height: 8),
              Text('🔄 Operaciones: Entradas, salidas, traspasos y albaranes'),
              SizedBox(height: 8),
              Text('🏢 Gestión: Proveedores, clientes, obras y tareas'),
              SizedBox(height: 8),
              Text('⚙️ Configuración: Usuarios, ajustes y preferencias'),
              SizedBox(height: 16),
              Text(
                'Para más ayuda, contacta con soporte técnico.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sync),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Sincronizando datos...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
