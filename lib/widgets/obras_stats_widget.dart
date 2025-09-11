// lib/widgets/obras_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';
import '../models/obra.dart';

class ObrasStatsWidget extends StatelessWidget {
  final String empresaId;

  const ObrasStatsWidget({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ObraProvider>(
      builder: (context, provider, child) {
        final obras = provider.obras;
        final obrasActivas = provider.obrasActivas;
        final obrasPausadas = provider.obrasPausadas;
        final obrasFinalizadas = provider.obrasFinalizadas;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.construction, color: Colors.brown),
                    const SizedBox(width: 8),
                    const Text(
                      'Gestión de Obras',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.cargarObras(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Estadísticas principales
                _buildStatsGrid(obras, obrasActivas, obrasPausadas, obrasFinalizadas),
                const SizedBox(height: 16),
                
                // Obras activas (si las hay)
                if (obrasActivas.isNotEmpty) ...[
                  _buildActiveObrasSection(obrasActivas),
                  const SizedBox(height: 16),
                ],
                
                // Acceso rápido
                _buildQuickActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    List<Obra> allObras,
    List<Obra> obrasActivas,
    List<Obra> obrasPausadas,
    List<Obra> obrasFinalizadas,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(
          'Total',
          '${allObras.length}',
          Icons.list_alt,
          Colors.blue,
        ),
        _buildStatCard(
          'Activas',
          '${obrasActivas.length}',
          Icons.play_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Pausadas',
          '${obrasPausadas.length}',
          Icons.pause_circle,
          Colors.orange,
        ),
        _buildStatCard(
          'Finalizadas',
          '${obrasFinalizadas.length}',
          Icons.check_circle,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveObrasSection(List<Obra> obrasActivas) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'Obras Activas (${obrasActivas.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...obrasActivas.take(3).map((obra) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${obra.nombre}',
              style: const TextStyle(fontSize: 12),
            ),
          )),
          if (obrasActivas.length > 3)
            Text(
              '... y ${obrasActivas.length - 3} más',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/obras',
                  arguments: {'empresaId': empresaId},
                ),
                icon: const Icon(Icons.list),
                label: const Text('Ver Todas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implementar creación rápida de obra
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función en desarrollo')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Obra'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



