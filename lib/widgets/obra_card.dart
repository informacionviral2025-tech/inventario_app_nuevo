import 'package:flutter/material.dart';
import '../models/obra.dart';

class ObraCard extends StatelessWidget {
  final Obra obra;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ObraCard({
    super.key,
    required this.obra,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                obra.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (obra.cliente != null) ...[
                Text(
                  'Cliente: ${obra.cliente}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                obra.direccion,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEstadoChip(obra.estado),
                  Text(
                    'Stock: ${obra.totalArticulosEnStock}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado) {
      case 'activa':
        color = Colors.green;
      case 'pausada':
        color = Colors.orange;
      case 'finalizada':
        color = Colors.grey;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}