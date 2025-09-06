// lib/widgets/articulo_card.dart
import 'package:flutter/material.dart';
import '../models/articulo.dart';

class ArticuloCard extends StatelessWidget {
  final Articulo articulo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showStockLevel;
  final bool showPrice;
  final bool showActions;

  const ArticuloCard({
    Key? key,
    required this.articulo,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showStockLevel = true,
    this.showPrice = true,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Indicador de estado de stock
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: articulo.colorEstadoStock,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Imagen o ícono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: articulo.colorEstadoStock.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getArticleIcon(),
                    color: articulo.colorEstadoStock,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (articulo.codigo.isNotEmpty)
                      Text(
                        'Código: ${articulo.codigo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    
                    if (articulo.descripcion != null && articulo.descripcion!.isNotEmpty)
                      Text(
                        articulo.descripcion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 4),
                    
                    // Categoría
                    if (articulo.categoria.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          articulo.categoria,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Stock y precio
              if (showStockLevel || showPrice)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showStockLevel)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: articulo.colorEstadoStock.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${articulo.stock} ${articulo.unidad}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: articulo.colorEstadoStock,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    if (showPrice && showStockLevel)
                      const SizedBox(height: 4),
                    
                    if (showPrice)
                      Text(
                        '€${articulo.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              
              // Acciones
              if (showActions && (onEdit != null || onDelete != null))
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getArticleIcon() {
    if (articulo.categoria.toLowerCase().contains('herramient')) {
      return Icons.build;
    } else if (articulo.categoria.toLowerCase().contains('electric')) {
      return Icons.electrical_services;
    } else if (articulo.categoria.toLowerCase().contains('fontaner')) {
      return Icons.plumbing;
    } else if (articulo.categoria.toLowerCase().contains('químic')) {
      return Icons.science;
    }
    return Icons.inventory_2;
  }
}