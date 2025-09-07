import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/articulo.dart';
import '../../routes.dart';

class ArticulosScreen extends StatefulWidget {
  final String empresaId;

  const ArticulosScreen({Key? key, required this.empresaId}) : super(key: key);

  @override
  State<ArticulosScreen> createState() => _ArticulosScreenState();
}

class _ArticulosScreenState extends State<ArticulosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filtroCategoria = 'Todas';
  bool _soloStockBajo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      inventoryProvider.initializeService(widget.empresaId);
      inventoryProvider.loadArticulos(widget.empresaId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Articulo> _getArticulosFiltrados(List<Articulo> articulos) {
    List<Articulo> filtrados = articulos;

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((articulo) {
        return articulo.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               articulo.codigo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               articulo.categoria.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtro por categoría
    if (_filtroCategoria != 'Todas') {
      filtrados = filtrados.where((articulo) =>
          articulo.categoria.toLowerCase() == _filtroCategoria.toLowerCase()).toList();
    }

    // Filtro por stock bajo
    if (_soloStockBajo) {
      filtrados = filtrados.where((articulo) =>
          articulo.stock <= articulo.stockMinimo).toList();
    }

    return filtrados;
  }

  List<String> _getCategorias(List<Articulo> articulos) {
    final categorias = articulos.map((a) => a.categoria).toSet().toList();
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
            onPressed: () {
              AppRoutes.goToNuevoArticulo(context, widget.empresaId);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo artículo',
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
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
                      inventoryProvider.loadArticulos(widget.empresaId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final articulos = inventoryProvider.articulos;
          final articulosFiltrados = _getArticulosFiltrados(articulos);
          final categorias = _getCategorias(articulos);

          return Column(
            children: [
              // Filtros
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Barra de búsqueda
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar artículos...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Filtros adicionales
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _filtroCategoria,
                            isExpanded: true,
                            items: categorias.map((categoria) {
                              return DropdownMenuItem(
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
                        FilterChip(
                          label: const Text('Stock bajo'),
                          selected: _soloStockBajo,
                          onSelected: (selected) {
                            setState(() {
                              _soloStockBajo = selected;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
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
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              articulos.isEmpty 
                                  ? 'No hay artículos registrados'
                                  : 'No se encontraron artículos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (articulos.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  AppRoutes.goToNuevoArticulo(context, widget.empresaId);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Crear primer artículo'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => inventoryProvider.refresh(),
                        child: ListView.builder(
                          itemCount: articulosFiltrados.length,
                          itemBuilder: (context, index) {
                            final articulo = articulosFiltrados[index];
                            final stockBajo = articulo.stock <= articulo.stockMinimo;
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: stockBajo ? Colors.red : Colors.blue,
                                  child: Text(
                                    articulo.nombre.isNotEmpty 
                                        ? articulo.nombre[0].toUpperCase()
                                        : 'A',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  articulo.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: articulo.activo ? null : Colors.grey,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Código: ${articulo.codigo}'),
                                    Text('Categoría: ${articulo.categoria}'),
                                    Row(
                                      children: [
                                        Text(
                                          'Stock: ${articulo.stock}',
                                          style: TextStyle(
                                            color: stockBajo ? Colors.red : null,
                                            fontWeight: stockBajo ? FontWeight.bold : null,
                                          ),
                                        ),
                                        if (stockBajo) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.warning,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (articulo.precio > 0)
                                      Text(
                                        '\$${articulo.precio.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    if (!articulo.activo)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Inactivo',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  AppRoutes.goToEditarArticulo(
                                    context,
                                    widget.empresaId,
                                    articulo.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.goToNuevoArticulo(context, widget.empresaId);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}