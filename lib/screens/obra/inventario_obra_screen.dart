// lib/screens/obra/inventario_obra_screen.dart
import 'package:flutter/material.dart';
import '../../models/obra.dart';
import '../../services/obra_service.dart';
import '../../services/articulo_service.dart';
import '../../models/articulo.dart';

class InventarioObraScreen extends StatefulWidget {
  final String empresaId;
  final Obra obra;

  const InventarioObraScreen({
    Key? key,
    required this.empresaId,
    required this.obra,
  }) : super(key: key);

  @override
  State<InventarioObraScreen> createState() => _InventarioObraScreenState();
}

class _InventarioObraScreenState extends State<InventarioObraScreen> {
  late final ObraService _obraService;
  late final ArticuloService _articuloService;
  Map<String, dynamic> _inventario = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obraService = ObraService(widget.empresaId);
    _articuloService = ArticuloService(widget.empresaId);
    _loadInventario();
  }

  Future<void> _loadInventario() async {
    try {
      final inventario = await _obraService.getInventarioObra(widget.obra.id);
      setState(() {
        _inventario = inventario;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar inventario: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario - ${widget.obra.nombre}'),
        actions: [
          IconButton(
            onPressed: _loadInventario,
            icon: const Icon(Icons.refresh),
          ),
          if (widget.obra.estado != 'finalizada')
            IconButton(
              onPressed: () => _agregarArticulo(context),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inventario.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No hay artículos en esta obra'),
                      const SizedBox(height: 8),
                      if (widget.obra.estado != 'finalizada')
                        ElevatedButton(
                          onPressed: () => _agregarArticulo(context),
                          child: const Text('Agregar Artículo'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _inventario.length,
                  itemBuilder: (context, index) {
                    final entry = _inventario.entries.elementAt(index);
                    final articulo = entry.value['articulo'] as Articulo;
                    final cantidad = entry.value['cantidad'] as int;
                    
                    return _buildInventarioItem(articulo, cantidad);
                  },
                ),
      floatingActionButton: widget.obra.estado != 'finalizada'
          ? FloatingActionButton.extended(
              onPressed: () => _agregarArticulo(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Artículo'),
            )
          : null,
    );
  }

  Widget _buildInventarioItem(Articulo articulo, int cantidad) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(articulo.nombre[0]),
        ),
        title: Text(articulo.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${cantidad} ${articulo.unidadMedida}'),
            Text('€${articulo.precio.toStringAsFixed(2)} cada uno'),
          ],
        ),
        trailing: widget.obra.estado != 'finalizada'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _modificarStock(articulo, cantidad),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _devolverStock(articulo, cantidad),
                    icon: const Icon(Icons.keyboard_return, color: Colors.orange),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _agregarArticulo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AgregarArticuloDialog(
        empresaId: widget.empresaId,
        obra: widget.obra,
        onSave: _loadInventario,
      ),
    );
  }

  void _modificarStock(Articulo articulo, int cantidadActual) {
    showDialog(
      context: context,
      builder: (context) => _ModificarStockDialog(
        articulo: articulo,
        cantidadActual: cantidadActual,
        obra: widget.obra,
        onSave: _loadInventario,
      ),
    );
  }

  void _devolverStock(Articulo articulo, int cantidadMaxima) {
    showDialog(
      context: context,
      builder: (context) => _DevolucionDialog(
        articulo: articulo,
        cantidadMaxima: cantidadMaxima,
        obra: widget.obra,
        onSave: _loadInventario,
      ),
    );
  }
}

// Diálogos auxiliares
class _AgregarArticuloDialog extends StatelessWidget {
  final String empresaId;
  final Obra obra;
  final VoidCallback onSave;

  const _AgregarArticuloDialog({
    Key? key,
    required this.empresaId,
    required this.obra,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final articuloService = ArticuloService(empresaId);

    return AlertDialog(
      title: const Text('Agregar Artículo a Obra'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Articulo>>(
          future: articuloService.getArticulosActivos().first,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            
            final articulos = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: articulos.length,
              itemBuilder: (context, index) {
                final articulo = articulos[index];
                return ListTile(
                  title: Text(articulo.nombre),
                  subtitle: Text('Stock disponible: ${articulo.stock}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _agregarArticuloObra(context, articulo),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _agregarArticuloObra(BuildContext context, Articulo articulo) {
    final cantidadController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${articulo.nombre}'),
        content: TextField(
          controller: cantidadController,
          decoration: InputDecoration(
            labelText: 'Cantidad',
            hintText: 'Máx: ${articulo.stock}',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              if (cantidad > 0 && cantidad <= articulo.stock) {
                final obraService = ObraService(empresaId);
                final articuloService = ArticuloService(empresaId);
                
                await obraService.agregarStockObra(obra.id, articulo.firebaseId!, cantidad);
                await articuloService.decrementarStock(
                  articulo.firebaseId!, 
                  cantidad, 
                  motivo: 'Traspaso a obra ${obra.nombre}'
                );
                
                Navigator.pop(context);
                Navigator.pop(context);
                onSave();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class _ModificarStockDialog extends StatelessWidget {
  final Articulo articulo;
  final int cantidadActual;
  final Obra obra;
  final VoidCallback onSave;

  const _ModificarStockDialog({
    Key? key,
    required this.articulo,
    required this.cantidadActual,
    required this.obra,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cantidadController = TextEditingController(text: cantidadActual.toString());
    
    return AlertDialog(
      title: Text('Modificar ${articulo.nombre}'),
      content: TextField(
        controller: cantidadController,
        decoration: const InputDecoration(labelText: 'Nueva cantidad'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final nuevaCantidad = int.tryParse(cantidadController.text) ?? 0;
            if (nuevaCantidad >= 0) {
              final obraService = ObraService(obra.empresaId);
              final articuloService = ArticuloService(obra.empresaId);
              
              final diferencia = nuevaCantidad - cantidadActual;
              
              if (diferencia > 0) {
                // Agregar desde almacén
                await obraService.agregarStockObra(obra.id, articulo.firebaseId!, diferencia);
                await articuloService.decrementarStock(
                  articulo.firebaseId!, 
                  diferencia, 
                  motivo: 'Ajuste en obra ${obra.nombre}'
                );
              } else if (diferencia < 0) {
                // Devolver al almacén
                await obraService.reducirStockObra(obra.id, articulo.firebaseId!, -diferencia);
                await articuloService.incrementarStock(
                  articulo.firebaseId!, 
                  -diferencia, 
                  motivo: 'Ajuste desde obra ${obra.nombre}'
                );
              }
              
              Navigator.pop(context);
              onSave();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _DevolucionDialog extends StatelessWidget {
  final Articulo articulo;
  final int cantidadMaxima;
  final Obra obra;
  final VoidCallback onSave;

  const _DevolucionDialog({
    Key? key,
    required this.articulo,
    required this.cantidadMaxima,
    required this.obra,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cantidadController = TextEditingController(text: cantidadMaxima.toString());
    
    return AlertDialog(
      title: Text('Devolver ${articulo.nombre}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Disponible: $cantidadMaxima ${articulo.unidadMedida}'),
          TextField(
            controller: cantidadController,
            decoration: const InputDecoration(labelText: 'Cantidad a devolver'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final cantidad = int.tryParse(cantidadController.text) ?? 0;
            if (cantidad > 0 && cantidad <= cantidadMaxima) {
              final obraService = ObraService(obra.empresaId);
              final articuloService = ArticuloService(obra.empresaId);
              
              await obraService.reducirStockObra(obra.id, articulo.firebaseId!, cantidad);
              await articuloService.incrementarStock(
                articulo.firebaseId!, 
                cantidad, 
                motivo: 'Devolución desde obra ${obra.nombre}'
              );
              
              Navigator.pop(context);
              onSave();
            }
          },
          child: const Text('Devolver'),
        ),
      ],
    );
  }
}