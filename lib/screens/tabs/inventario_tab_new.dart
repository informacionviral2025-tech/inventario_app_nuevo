// lib/screens/tabs/inventario_tab_new.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_inventory_provider.dart';
import '../../widgets/advanced_stats_widget.dart';
import '../articulos/gestion_articulos_screen.dart';
import '../scanner/integrated_scanner_screen.dart';

class InventarioTab extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const InventarioTab({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<InventarioTab> createState() => _InventarioTabState();
}

class _InventarioTabState extends State<InventarioTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      provider.setEmpresa(widget.empresaId, widget.empresaNombre);
      provider.loadArticulos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<UnifiedInventoryProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        await inventoryProvider.loadArticulos(forceRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatsCards(inventoryProvider),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            const AdvancedStatsWidget(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Inventario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controla tu stock y artículos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(UnifiedInventoryProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Artículos',
            '${provider.articulos.length}',
            Icons.inventory_2,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Stock Bajo',
            '${provider.articulos.where((a) => a.stock <= a.stockMinimo).length}',
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sin Stock',
            '${provider.articulos.where((a) => a.stock <= 0).length}',
            Icons.error,
            Colors.red,
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Gestionar Artículos',
              Icons.inventory_2,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GestionArticulosScreen(empresaId: widget.empresaId),
                ),
              ),
            ),
            _buildActionCard(
              'Escáner',
              Icons.qr_code_scanner,
              Colors.purple,
              () => _showScannerOptions(),
            ),
            _buildActionCard(
              'Buscar Artículo',
              Icons.search,
              Colors.green,
              () => _showSearchDialog(),
            ),
            _buildActionCard(
              'Ajustar Stock',
              Icons.edit,
              Colors.orange,
              () => _showStockAdjustmentDialog(),
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
                  Icons.add_circle,
                  Colors.green,
                  'Entrada de stock',
                  'Cemento Portland - 100 unidades',
                  'Hace 2 horas',
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.remove_circle,
                  Colors.red,
                  'Salida de stock',
                  'Ladrillos cerámicos - 50 unidades',
                  'Hace 4 horas',
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.swap_horiz,
                  Colors.blue,
                  'Traspaso',
                  'Varillas acero - Almacén 1 → Almacén 2',
                  'Ayer',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showScannerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de Escáner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildScannerOption(
              'Entrada de Stock',
              Icons.input,
              Colors.green,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntegratedScannerScreen(
                      empresaId: widget.empresaId,
                      empresaNombre: widget.empresaNombre,
                      mode: ScannerMode.entrada,
                    ),
                  ),
                );
              },
            ),
            _buildScannerOption(
              'Salida de Stock',
              Icons.output,
              Colors.red,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntegratedScannerScreen(
                      empresaId: widget.empresaId,
                      empresaNombre: widget.empresaNombre,
                      mode: ScannerMode.salida,
                    ),
                  ),
                );
              },
            ),
            _buildScannerOption(
              'Buscar Artículo',
              Icons.search,
              Colors.blue,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntegratedScannerScreen(
                      empresaId: widget.empresaId,
                      empresaNombre: widget.empresaNombre,
                      mode: ScannerMode.busqueda,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Artículo'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Código, nombre o descripción...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar búsqueda
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Stock'),
        content: const Text('Esta funcionalidad permitirá ajustar el stock de artículos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

enum ScannerMode { entrada, salida, busqueda }
