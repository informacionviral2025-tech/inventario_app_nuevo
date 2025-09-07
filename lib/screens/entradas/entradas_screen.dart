// lib/screens/entradas/entradas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/articulo.dart';

class EntradasScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const EntradasScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  final _searchController = TextEditingController();
  List<Articulo> _articulos = [];
  List<Articulo> _articulosFiltrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticulos();
  }

  Future<void> _loadArticulos() async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadArticulos(widget.empresaId);
    
    setState(() {
      _articulos = inventoryProvider.articulos;
      _articulosFiltrados = _articulos;
      _isLoading = false;
    });
  }

  void _filterArticulos(String query) {
    setState(() {
      if (query.isEmpty) {
        _articulosFiltrados = _articulos;
      } else {
        _articulosFiltrados = _articulos.where((articulo) =>
          articulo.descripcion.toLowerCase().contains(query.toLowerCase()) ||
          articulo.codigo.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entradas - ${widget.empresaNombre}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar artículos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterArticulos,
            ),
          ),
          
          // Lista de artículos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _articulosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron artículos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _articulosFiltrados.length,
                        itemBuilder: (context, index) {
                          final articulo = _articulosFiltrados[index];
                          return _buildArticuloCard(articulo);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoEntradaMasiva(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Entrada Masiva'),
      ),
    );
  }

  Widget _buildArticuloCard(Articulo articulo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            articulo.codigo.substring(0, 2).toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          articulo.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${articulo.codigo}'),
            Text('Stock actual: ${articulo.stock}'),
            if (articulo.ubicacion != null)
              Text('Ubicación: ${articulo.ubicacion}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _mostrarDialogoEntrada(articulo),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _mostrarDialogoEntrada(Articulo articulo) {
    final cantidadController = TextEditingController();
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Entrada'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                articulo.descripcion,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Código: ${articulo.codigo}'),
              Text('Stock actual: ${articulo.stock}'),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a ingresar',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cantidad = int.tryParse(cantidadController.text);
              if (cantidad != null && cantidad > 0) {
                await _registrarEntrada(
                  articulo,
                  cantidad,
                  observacionesController.text,
                );
                if (mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad válida')),
                );
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEntradaMasiva() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrada Masiva'),
        content: const Text(
          'Esta función permite registrar múltiples entradas de una vez. '
          '¿Desea continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí se abriría una pantalla para entrada masiva
              _mostrarPantallaEntradaMasiva();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _mostrarPantallaEntradaMasiva() {
    // Por ahora mostrar un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de entrada masiva en desarrollo'),
      ),
    );
  }

  Future<void> _registrarEntrada(Articulo articulo, int cantidad, String observaciones) async {
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final nuevoStock = articulo.stock + cantidad;
      
      final articuloActualizado = articulo.copyWith(stock: nuevoStock);
      
      final success = await inventoryProvider.updateArticulo(articuloActualizado, widget.empresaId);
      
      if (success) {
        // Actualizar la lista local
        setState(() {
          final index = _articulos.indexWhere((a) => a.firebaseId == articulo.firebaseId);
          if (index != -1) {
            _articulos[index] = articuloActualizado;
          }
          _filterArticulos(_searchController.text);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrada registrada: +$cantidad unidades'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Aquí se podría registrar el movimiento en un historial
        _registrarMovimiento(articulo, cantidad, 'entrada', observaciones);
      } else {
        throw Exception('Error al actualizar el artículo');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar entrada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registrarMovimiento(
    Articulo articulo,
    int cantidad,
    String tipo,
    String observaciones,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // TODO: Implementar servicio de movimientos
      // Por ahora solo imprimir en consola
      print('Movimiento registrado:');
      print('Artículo: ${articulo.descripcion}');
      print('Tipo: $tipo');
      print('Cantidad: $cantidad');
      print('Usuario: ${authProvider.currentUser?.displayName}');
      print('Fecha: ${DateTime.now()}');
      print('Observaciones: $observaciones');
    } catch (e) {
      print('Error al registrar movimiento: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}