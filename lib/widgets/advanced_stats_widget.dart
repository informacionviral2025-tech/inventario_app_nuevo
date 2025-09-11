// lib/widgets/advanced_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/unified_inventory_provider.dart';

class AdvancedStatsWidget extends StatelessWidget {
  const AdvancedStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedInventoryProvider>(
      builder: (context, provider, child) {
        final stats = provider.estadisticasDetalladas;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Estadísticas Detalladas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.loadArticulos(forceRefresh: true),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Estadísticas principales
                _buildStatsGrid(stats),
                const SizedBox(height: 16),
                
                // Gráfico de categorías
                _buildCategoryChart(stats['categorias'] as Map<String, int>),
                const SizedBox(height: 16),
                
                // Alertas de stock
                _buildStockAlerts(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(
          'Total Artículos',
          '${stats['totalArticulos']}',
          Icons.inventory_2,
          Colors.blue,
        ),
        _buildStatCard(
          'Stock Total',
          '${stats['totalStock']}',
          Icons.warehouse,
          Colors.green,
        ),
        _buildStatCard(
          'Valor Total',
          '€${(stats['valorTotalInventario'] as double).toStringAsFixed(2)}',
          Icons.euro,
          Colors.purple,
        ),
        _buildStatCard(
          'Stock Bajo',
          '${stats['articulosStockBajo']}',
          Icons.warning,
          Colors.orange,
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

  Widget _buildCategoryChart(Map<String, int> categorias) {
    if (categorias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución por Categorías',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categorias.entries.map((entry) {
          final total = categorias.values.fold(0, (sum, count) => sum + count);
          final percentage = (entry.value / total * 100).round();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: entry.value / total,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(entry.key),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value} ($percentage%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStockAlerts(Map<String, dynamic> stats) {
    final stockBajo = stats['stockBajo'] as List;
    final sinStock = stats['sinStock'] as List;

    if (stockBajo.isEmpty && sinStock.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas de Stock',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (sinStock.isNotEmpty) ...[
          _buildAlertSection(
            'Sin Stock',
            sinStock,
            Colors.red,
            Icons.error,
          ),
          const SizedBox(height: 8),
        ],
        
        if (stockBajo.isNotEmpty) ...[
          _buildAlertSection(
            'Stock Bajo',
            stockBajo,
            Colors.orange,
            Icons.warning,
          ),
        ],
      ],
    );
  }

  Widget _buildAlertSection(String title, List items, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                '$title (${items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${item.nombre} (Stock: ${item.stock})',
              style: const TextStyle(fontSize: 12),
            ),
          )),
          if (items.length > 3)
            Text(
              '... y ${items.length - 3} más',
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

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}

