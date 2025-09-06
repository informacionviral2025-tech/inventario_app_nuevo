// lib/widgets/inventario_dashboard.dart
import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';

class InventarioDashboard extends StatelessWidget {
  final String empresaId;
  final VoidCallback? onStockBajoPressed;
  final VoidCallback? onSinStockPressed;

  const InventarioDashboard({
    Key? key,
    required this.empresaId,
    this.onStockBajoPressed,
    this.onSinStockPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final articuloService = ArticuloService(empresaId);

    return FutureBuilder<Map<String, dynamic>>(
      future: articuloService.getEstadisticas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Error al cargar estadísticas'),
            ),
          );
        }

        final stats = snapshot.data ?? {
          'totalArticulos': 0,
          'valorTotal': 0.0,
          'stockTotal': 0,
          'stockBajo': 0,
          'sinStock': 0,
          'articulosCriticos': 0,
        };
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de Inventario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Primera fila de estadísticas
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Total Artículos',
                      stats['totalArticulos'].toString(),
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      context,
                      'Valor Total',
                      '€${stats['valorTotal'].toStringAsFixed(2)}',
                      Icons.euro,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Segunda fila de estadísticas
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Stock Total',
                      stats['stockTotal'].toString(),
                      Icons.layers,
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      context,
                      'Stock Bajo',
                      stats['stockBajo'].toString(),
                      Icons.warning,
                      Colors.orange,
                      onTap: onStockBajoPressed,
                    ),
                  ],
                ),
                
                // Alertas
                if (stats['sinStock'] > 0 || stats['articulosCriticos'] > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      if (stats['sinStock'] > 0)
                        _buildAlertItem(
                          context,
                          '${stats['sinStock']} artículos sin stock',
                          Icons.block,
                          Colors.red,
                          onSinStockPressed,
                        ),
                      if (stats['articulosCriticos'] > 0)
                        _buildAlertItem(
                          context,
                          '${stats['articulosCriticos']} artículos en stock crítico',
                          Icons.error,
                          Colors.red,
                          onStockBajoPressed,
                        ),
                    ],
                  ),
                ],
                
                // Última actualización
                if (snapshot.hasData)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Actualizado: ${DateTime.now().toString().substring(0, 16)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}