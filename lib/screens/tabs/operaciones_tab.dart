// lib/screens/tabs/operaciones_tab.dart
import 'package:flutter/material.dart';
import '../entradas/entradas_inventario_screen.dart';
import '../salidas_inventario_screen.dart';
import '../traspasos/traspaso_screen.dart';
import '../albaranes/lista_albaranes_screen.dart';
import '../scanner/integrated_scanner_screen.dart';

class OperacionesTab extends StatelessWidget {
  final String empresaId;
  final String empresaNombre;

  const OperacionesTab({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildOperationsGrid(context),
          const SizedBox(height: 20),
          _buildQuickActions(context),
        ],
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
            colors: [Colors.green.shade600, Colors.green.shade800],
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
                    Icons.swap_horiz,
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
                        'Operaciones de Inventario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona entradas, salidas y movimientos',
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

  Widget _buildOperationsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operaciones Principales',
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
          childAspectRatio: 1.2,
          children: [
            _buildOperationCard(
              'Entradas',
              Icons.input,
              Colors.green,
              'Registrar entrada de stock',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntradaInventarioScreen(
                    empresaId: empresaId,
                    empresaNombre: empresaNombre,
                  ),
                ),
              ),
            ),
            _buildOperationCard(
              'Salidas',
              Icons.output,
              Colors.red,
              'Registrar salida de stock',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalidasInventarioScreen(empresaId: empresaId),
                ),
              ),
            ),
            _buildOperationCard(
              'Traspasos',
              Icons.swap_horiz,
              Colors.blue,
              'Mover stock entre ubicaciones',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TraspasoScreen(empresaId: empresaId),
                ),
              ),
            ),
            _buildOperationCard(
              'Albaranes',
              Icons.receipt_long,
              Colors.amber,
              'Gestionar albaranes de proveedor',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListaAlbaranesScreen(
                    empresaId: empresaId,
                    empresaNombre: empresaNombre,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Escáner Entrada',
                Icons.qr_code_scanner,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntegratedScannerScreen(
                      empresaId: empresaId,
                      empresaNombre: empresaNombre,
                      mode: ScannerMode.entrada,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Escáner Salida',
                Icons.qr_code_scanner,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntegratedScannerScreen(
                      empresaId: empresaId,
                      empresaNombre: empresaNombre,
                      mode: ScannerMode.salida,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Nuevo Albarán',
                Icons.add_box,
                Colors.amber,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaAlbaranesScreen(
                      empresaId: empresaId,
                      empresaNombre: empresaNombre,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Inventario Físico',
                Icons.checklist,
                Colors.purple,
                () => _showInventoryDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
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
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
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

  void _showInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventario Físico'),
        content: const Text('Esta funcionalidad permitirá realizar inventarios físicos y ajustar diferencias.'),
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
