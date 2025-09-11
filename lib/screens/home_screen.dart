// lib/screens/home_screen.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/unified_inventory_provider.dart';
import '../widgets/sync_status_widget.dart';
import '../widgets/advanced_stats_widget.dart';
import '../widgets/tasks_stats_widget.dart';
import '../widgets/obras_stats_widget.dart';

class HomeScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const HomeScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los artículos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      provider.setEmpresa(widget.empresaId, widget.empresaNombre);
      provider.loadArticulos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inventoryProvider = Provider.of<UnifiedInventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario - ${widget.empresaNombre}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          const SyncButton(),
          const SyncStatusWidget(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await inventoryProvider.loadArticulos(forceRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authProvider),
              const SizedBox(height: 20),
              _buildStatsCards(inventoryProvider),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              const AdvancedStatsWidget(),
              const SizedBox(height: 20),
              TasksStatsWidget(empresaId: widget.empresaId),
              const SizedBox(height: 20),
              ObrasStatsWidget(empresaId: widget.empresaId),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              authProvider.currentUser?.displayName ?? 'Usuario',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Empresa: ${widget.empresaNombre}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(UnifiedInventoryProvider inventoryProvider) {
    if (inventoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Artículos',
            '${inventoryProvider.totalArticulos}',
            Icons.inventory,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Stock Total',
            '${inventoryProvider.totalStock}',
            Icons.warehouse,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Stock Bajo',
            '${inventoryProvider.articulosStockBajo}',
            Icons.warning,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Entradas',
              Icons.add_circle,
              Colors.green,
              () => Navigator.pushNamed(
                context,
                '/entradas',
                arguments: {
                  'empresaId': widget.empresaId,
                  'empresaNombre': widget.empresaNombre,
                },
              ),
            ),
            _buildActionCard(
              'Salidas',
              Icons.remove_circle,
              Colors.red,
              () => Navigator.pushNamed(
                context,
                '/salidas',
                arguments: {
                  'empresaId': widget.empresaId,
                  'empresaNombre': widget.empresaNombre,
                },
              ),
            ),
            _buildActionCard(
              'Traspasos',
              Icons.swap_horiz,
              Colors.blue,
              () => Navigator.pushNamed(
                context,
                '/traspasos',
                arguments: {
                  'empresaId': widget.empresaId,
                  'empresaNombre': widget.empresaNombre,
                },
              ),
            ),
            _buildActionCard(
              'Inventario',
              Icons.inventory_2,
              Colors.purple,
              () => Navigator.pushNamed(
                context,
                '/inventario',
                arguments: {
                  'empresaId': widget.empresaId,
                  'empresaNombre': widget.empresaNombre,
                },
              ),
            ),
            _buildActionCard(
              'Albaranes',
              Icons.receipt_long,
              Colors.amber,
              () => Navigator.pushNamed(
                context,
                '/albaranes',
                arguments: {
                  'empresaId': widget.empresaId,
                  'empresaNombre': widget.empresaNombre,
                },
              ),
            ),
            _buildActionCard(
              'Proveedores',
              Icons.local_shipping,
              Colors.cyan,
              () => Navigator.pushNamed(
                context,
                '/proveedores',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
            _buildActionCard(
              'Clientes',
              Icons.people,
              Colors.pink,
              () => Navigator.pushNamed(
                context,
                '/clientes',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
            _buildActionCard(
              'Escáner',
              Icons.qr_code_scanner,
              Colors.indigo,
              () => _mostrarOpcionesScanner(),
            ),
            _buildActionCard(
              'Tareas',
              Icons.task_alt,
              Colors.teal,
              () => Navigator.pushNamed(
                context,
                '/tasks',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
            _buildActionCard(
              'Obras',
              Icons.construction,
              Colors.brown,
              () => Navigator.pushNamed(
                context,
                '/obras',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
            _buildActionCard(
              'Reportes',
              Icons.assessment,
              Colors.indigo,
              () => Navigator.pushNamed(
                context,
                '/reportes',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
            _buildActionCard(
              'Ajustes',
              Icons.settings,
              Colors.grey,
              () => Navigator.pushNamed(
                context,
                '/ajustes',
                arguments: {
                  'empresaId': widget.empresaId,
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  'Entrada de mercancía',
                  'Se registraron 25 artículos',
                  Icons.add_circle,
                  Colors.green,
                  'Hace 2 horas',
                ),
                const Divider(),
                _buildActivityItem(
                  'Traspaso completado',
                  'Traspaso T-001 completado',
                  Icons.swap_horiz,
                  Colors.blue,
                  'Hace 4 horas',
                ),
                const Divider(),
                _buildActivityItem(
                  'Stock bajo detectado',
                  '3 artículos con stock bajo',
                  Icons.warning,
                  Colors.orange,
                  'Hace 1 día',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesScanner() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones del Escáner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Entrada de Stock'),
              subtitle: const Text('Escanear para agregar stock'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/scanner/entrada',
                  arguments: {
                    'empresaId': widget.empresaId,
                    'empresaNombre': widget.empresaNombre,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              title: const Text('Salida de Stock'),
              subtitle: const Text('Escanear para retirar stock'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/scanner/salida',
                  arguments: {
                    'empresaId': widget.empresaId,
                    'empresaNombre': widget.empresaNombre,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Búsqueda'),
              subtitle: const Text('Escanear para buscar información'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/scanner/busqueda',
                  arguments: {
                    'empresaId': widget.empresaId,
                    'empresaNombre': widget.empresaNombre,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt),
          label: 'Tareas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: 'Obras',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en inicio
            break;
          case 1:
            Navigator.pushNamed(
              context,
              '/inventario',
              arguments: {
                'empresaId': widget.empresaId,
                'empresaNombre': widget.empresaNombre,
              },
            );
            break;
          case 2:
            Navigator.pushNamed(
              context,
              '/tasks',
              arguments: {
                'empresaId': widget.empresaId,
              },
            );
            break;
          case 3:
            Navigator.pushNamed(
              context,
              '/obras',
              arguments: {
                'empresaId': widget.empresaId,
              },
            );
            break;
          case 4:
            Navigator.pushNamed(context, '/ajustes');
            break;
        }
      },
    );
  }
}
