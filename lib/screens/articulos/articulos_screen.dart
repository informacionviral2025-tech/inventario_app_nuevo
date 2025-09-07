import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/articulo.dart';
import '../articulos/editar_articulo_screen.dart';

class ArticulosScreen extends StatefulWidget {
  final String empresaId;

  const ArticulosScreen({Key? key, required this.empresaId}) : super(key: key);

  @override
  State<ArticulosScreen> createState() => _ArticulosScreenState();
}

class _ArticulosScreenState extends State<ArticulosScreen> {
  String _searchQuery = '';
  String _filtroCategoria = 'Todas';
  bool _mostrarSoloStockBajo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false)
          .loadArticulos(widget.empresaId);
    });
  }

  List<Articulo> _filtrarArticulos(List<Articulo> articulos) {
    var articulosFiltrados = articulos.where((articulo) {
      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nombre = articulo.nombre.toLowerCase();
        final categoria = (articulo.categoria ?? '').toLowerCase();
        if (!nombre.contains(query) && !categoria.contains(query)) {
          return false;
        }
      }

      // Filtro por categoría
      if (_filtroCategoria != 'Todas') {
        final articuloCategoria = (articulo.categoria ?? '').toLowerCase();
        final filtroCategoria = _filtroCategoria.toLowerCase();
        if (articuloCategoria != filtroCategoria) {
          return false;
        }
      }

      // Filtro por stock bajo
      if (_mostrarSoloStockBajo) {
        final stockMinimo = articulo.stockMinimo ?? 0;
        if (articulo.stock > stockMinimo) {
          return false;
        }
      }

      return true;
    }).toList();

    return articulosFiltrados;
  }

  List<String> _obtenerCategorias(List<Articulo> articulos) {
    final categorias = articulos
        .map((articulo) => articulo.categoria)
        .where((categoria) => categoria != null && categoria!.isNotEmpty)
        .map((categoria) => categoria!)
        .toSet()
        .toList();

    categorias.sort();
    return ['Todas', ...categorias];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/agregar-articulo',
                arguments: {'empresaId': widget.empresaId},
              );
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          if (inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inventoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${inventoryProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      inventoryProvider.clearError();
                      inventoryProvider.loadArticulos(widget.empresaId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final articulos = inventoryProvider.articulos;
          final categorias = _obtenerCategorias(articulos);
          final articulosFiltrados = _filtrarArticulos(articulos);

          return Column(
            children: [
              // Barra de búsqueda y filtros
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Campo de búsqueda
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar artículos...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filtros en fila
                    Row(
                      children: [
                        // Filtro de categoría
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _filtroCategoria,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: categorias.map((categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _filtroCategoria = value ?? 'Todas';
                              });
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Filtro de stock bajo
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text(
                              'Stock bajo',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _mostrarSoloStockBajo,
                            onChanged: (value) {
                              setState(() {
                                _mostrarSoloStockBajo = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Contador de resultados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                color: Colors.blue[50],
                child: Text(
                  '${articulosFiltrados.length} artículo${articulosFiltrados.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Lista de artículos
              Expanded(
                child: articulosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _filtroCategoria != 'Todas' || _mostrarSoloStockBajo
                                  ? Icons.search_off
                                  : Icons.inventory_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _filtroCategoria != 'Todas' || _mostrarSoloStockBajo
                                  ? 'No se encontraron artículos con los filtros aplicados'
                                  : 'No hay artículos registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: articulosFiltrados.length,
                        itemBuilder: (context, index) {
                          final articulo = articulosFiltrados[index];
                          return _buildArticuloCard(articulo);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/agregar-articulo',
            arguments: {'empresaId': widget.empresaId},
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildArticuloCard(Articulo articulo) {
    final stockMinimo = articulo.stockMinimo ?? 0;
    final stockBajo = articulo.stock <= stockMinimo;
    final esActivo = articulo.activo == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _mostrarDetallesArticulo(articulo),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de estado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: !esActivo
                      ? Colors.grey[300]
                      : stockBajo
                          ? Colors.orange[100]
                          : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  size: 24,
                  color: !esActivo
                      ? Colors.grey[600]
                      : stockBajo
                          ? Colors.orange[700]
                          : Colors.green[700],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del artículo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      articulo.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !esActivo ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Categoría
                    if (articulo.categoria != null && articulo.categoria!.isNotEmpty)
                      Text(
                        articulo.categoria!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 4),
                    
                    // Stock
                    Row(
                      children: [
                        Text(
                          'Stock: ${articulo.stock}',
                          style: TextStyle(
                            fontSize: 14,
                            color: stockBajo ? Colors.orange[700] : Colors.grey[700],
                            fontWeight: stockBajo ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (stockMinimo > 0) ...[
                          Text(
                            ' (mín: $stockMinimo)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Precio
                    if (articulo.precio > 0)
                      Text(
                        '\$${articulo.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    // Estado inactivo
                    if (!esActivo)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: Text(
                          'INACTIVO',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Indicadores y menú
              Column(
                children: [
                  // Indicador de stock bajo
                  if (stockBajo)
                    Icon(
                      Icons.warning,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Menú de opciones
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'editar':
                          _editarArticulo(articulo);
                          break;
                        case 'eliminar':
                          _confirmarEliminacion(articulo);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetallesArticulo(Articulo articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(articulo.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Código', articulo.codigo),
            if (articulo.descripcion != null && articulo.descripcion!.isNotEmpty)
              _buildDetailRow('Descripción', articulo.descripcion!),
            if (articulo.categoria != null && articulo.categoria!.isNotEmpty)
              _buildDetailRow('Categoría', articulo.categoria!),
            _buildDetailRow('Stock actual', articulo.stock.toString()),
            if (articulo.stockMinimo != null && articulo.stockMinimo! > 0)
              _buildDetailRow('Stock mínimo', articulo.stockMinimo.toString()),
            _buildDetailRow('Precio', '\$${articulo.precio.toStringAsFixed(2)}'),
            if (articulo.codigoBarras != null && articulo.codigoBarras!.isNotEmpty)
              _buildDetailRow('Código de barras', articulo.codigoBarras!),
            _buildDetailRow('Estado', articulo.activo == true ? 'Activo' : 'Inactivo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editarArticulo(articulo);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editarArticulo(Articulo articulo) {
    Navigator.pushNamed(
      context,
      '/editar-articulo',
      arguments: {
        'empresaId': widget.empresaId,
        'empresaNombre': 'Mi Empresa', // Puedes pasar el nombre real
        'articulo': articulo,
      },
    );
  }

  void _confirmarEliminacion(Articulo articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar "${articulo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _eliminarArticulo(articulo);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarArticulo(Articulo articulo) async {
    try {
      if (articulo.id != null) {
        await Provider.of<InventoryProvider>(context, listen: false)
            .deleteArticulo(articulo.id!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artículo "${articulo.nombre}" eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el artículo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}