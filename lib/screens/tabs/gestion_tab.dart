// lib/screens/tabs/gestion_tab.dart
import 'package:flutter/material.dart';
import '../proveedores/gestion_proveedores_screen.dart';
import '../clientes/clientes_screen.dart';
import '../vehiculos/vehiculos_screen.dart';
import '../tasks/tasks_screen.dart';
import '../obra/obras_screen.dart';

class GestionTab extends StatelessWidget {
  final String empresaId;
  final String empresaNombre;

  const GestionTab({
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
          _buildManagementSections(context),
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
            colors: [Colors.orange.shade600, Colors.orange.shade800],
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
                    Icons.business,
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
                        'Gestión Empresarial',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Administra proveedores, clientes, obras y recursos',
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

  Widget _buildManagementSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Relaciones Comerciales',
          Icons.handshake,
          Colors.blue,
          [
            _buildManagementCard(
              'Proveedores',
              Icons.local_shipping,
              Colors.cyan,
              'Gestiona proveedores y compras',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GestionProveedoresScreen(empresaId: empresaId),
                ),
              ),
            ),
            _buildManagementCard(
              'Clientes',
              Icons.people,
              Colors.pink,
              'Gestiona clientes y ventas',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientesScreen(empresaId: empresaId),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Proyectos y Recursos',
          Icons.construction,
          Colors.green,
          [
            _buildManagementCard(
              'Obras',
              Icons.construction,
              Colors.brown,
              'Gestiona proyectos y obras',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObrasScreen(empresaId: empresaId),
                ),
              ),
            ),
            _buildManagementCard(
              'Tareas',
              Icons.task_alt,
              Colors.teal,
              'Organiza tareas y responsabilidades',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TasksScreen(empresaId: empresaId),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Flota y Recursos',
          Icons.directions_car,
          Colors.purple,
          [
            _buildManagementCard(
              'Vehículos',
              Icons.directions_car,
              Colors.indigo,
              'Gestiona flota de vehículos',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehiculosScreen(empresaId: empresaId),
                ),
              ),
            ),
            _buildManagementCard(
              'Máquinas',
              Icons.build,
              Colors.grey,
              'Gestiona maquinaria y equipos',
              () => _showMachinesDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: children,
        ),
      ],
    );
  }

  Widget _buildManagementCard(
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

  void _showMachinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Máquinas'),
        content: const Text('Esta funcionalidad permitirá gestionar maquinaria y equipos de la empresa.'),
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
