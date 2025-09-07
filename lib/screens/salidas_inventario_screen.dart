// lib/screens/salidas_inventario_screen.dart
import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/articulo_service.dart';
import '../routes/app_routes.dart';

class SalidasInventarioScreen extends StatefulWidget {
  final String empresaId;

  const SalidasInventarioScreen({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  State<SalidasInventarioScreen> createState() => _SalidasInventarioScreenState();
}

class _SalidasInventarioScreenState extends State<SalidasInventarioScreen> {
  final ArticuloService _articuloService = ArticuloService('');
  final TextEditingController _searchController = TextEditingController();
  
  List<Articulo> _articulos = [];
  List<Articulo> _articulosSeleccionados = [];
  Map<String, int> _cantidadesSalida = {};
  bool _isLoading = false;
  bool _showScanner = false;

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarArticulos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articuloService = ArticuloService(widget.empresaId);
      _articulos = await articuloService.getArticulos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar artículos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _agregarArticulo(Articulo articulo) {
    if (!_articulosSeleccionados.contains(articulo)) {
      setState(() {
        _articulosSeleccionados.add(articulo);
        _cantidadesSalida[articulo.id ?? articulo.firebaseId ?? ''] = 1;
      });
    }
  }

  void _removerArticulo(Articulo articulo) {
    setState(() {
      _articulosSeleccionados.remove(articulo);
      _cantidadesSalida.remove(articulo.id ?? articulo.firebaseId ?? '');
    });
  }

  void _actualizarCantidad(Articulo articulo, int cantidad) {
    if (cantidad > 0 && cantidad <= articulo.stock) {
      setState(() {
        _cantidadesSalida[articulo.id ?? articulo.firebaseId ?? ''] = cantidad;
      });
    }
  }

  Future<void> _ejecutarSalidas() async {
    if (_articulosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay artículos seleccionados')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final articuloService = ArticuloService(widget.empresaId);
      
      for (var articulo in _articulosSeleccionados) {
        final key = articulo.id ?? articulo.firebaseId ?? '';
        final cantidad = _cantidadesSalida[key] ?? 0;
        final nuevoStock = articulo.stock - cantidad;
        
        if (nuevoStock >= 0) {
          final articuloActualizado = articulo.copyWith(
            stock: nuevoStock,
            fechaModificacion: DateTime.now(),
          );
          await articuloService.updateArticulo(articuloActualizado);
        }
      }

      // Limpiar selecciones
      setState(() {
        _articulosSeleccionados.clear();
        _cantidadesSalida.clear();
      });

      // Recargar artículos
      await _cargarArticulos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salidas ejecutadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al ejecutar salidas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Articulo> _filtrarArticulos() {
    if (_searchController.text.isEmpty) {
      return _articulos;
    }
    
    final query = _searchController.text.toLowerCase();
    return _articulos.where((articulo) {
      return articulo.codigo.toLowerCase().contains(query) ||
             (articulo.descripcion?.toLowerCase().contains(query) ?? false) ||
             articulo.nombre.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildScanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Escanear código de barras',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Funcionalidad próximamente',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticulosList() {
    final articulosFiltrados = _filtrarArticulos();
    
    if (articulosFiltrados.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No se encontraron artículos'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: articulosFiltrados.length,
        itemBuilder: (context, index) {
          final articulo = articulosFiltrados[index];
          final isSelected = _articulosSeleccionados.contains(articulo);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: articulo.stock > (articulo.stockMinimo ?? 0)
                    ? Colors.green
                    : Colors.red,
                child: Text(
                  articulo.stock.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                articulo.descripcion ?? articulo.nombre,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Código: ${articulo.codigo}'),
                  Text('Stock disponible: ${articulo.stock}'),
                  if (articulo.categoria != null)
                    Text('Categoría: ${articulo.categoria}'),
                ],
              ),
              trailing: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(8),
                            ),
                            controller: TextEditingController(
                              text: (_cantidadesSalida[articulo.id ?? articulo.firebaseId ?? ''] ?? 1).toString(),
                            ),
                            onChanged: (value) {
                              final cantidad = int.tryParse(value) ?? 1;
                              _actualizarCantidad(articulo, cantidad);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removerArticulo(articulo),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: articulo.stock > 0 
                          ? () => _agregarArticulo(articulo)
                          : null,
                    ),
              onTap: articulo.stock > 0 && !isSelected
                  ? () => _agregarArticulo(articulo)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumen() {
    if (_articulosSeleccionados.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de salidas (${_articulosSeleccionados.length} artículos)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._articulosSeleccionados.map((articulo) {
            final key = articulo.id ?? articulo.firebaseId ?? '';
            final cantidad = _cantidadesSalida[key] ?? 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${articulo.descripcion ?? articulo.nombre}: $cantidad unidades',
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salidas de Inventario'),
        actions: [
          IconButton(
            icon: Icon(_showScanner ? Icons.list : Icons.qr_code_scanner),
            onPressed: () {
              setState(() {
                _showScanner = !_showScanner;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_showScanner) ...[
                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar artículo',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  _buildArticulosList(),
                ] else ...[
                  _buildScanner(),
                  const Divider(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Funcionalidad de escáner\npróximamente disponible',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showScanner = false;
                              });
                            },
                            child: const Text('Volver a la lista'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                _buildResumen(),
              ],
            ),
      floatingActionButton: _articulosSeleccionados.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _ejecutarSalidas,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isLoading ? 'Procesando...' : 'Ejecutar Salidas'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}