import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/traspaso.dart';
import '../../models/articulo.dart';

class NuevoTraspasoScreen extends StatefulWidget {
  final String empresaId;

  const NuevoTraspasoScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<NuevoTraspasoScreen> createState() => _NuevoTraspasoScreenState();
}

class _NuevoTraspasoScreenState extends State<NuevoTraspasoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();
  
  String _almacenOrigen = '';
  String _almacenDestino = '';
  List<ItemTraspaso> _items = [];
  List<String> _almacenes = [];
  List<Articulo> _articulos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar almacenes
      final almacenesSnapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('almacenes')
          .get();

      // Cargar artículos
      final articulosSnapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .get();

      setState(() {
        _almacenes = almacenesSnapshot.docs
            .map((doc) => doc.data()['nombre'] as String)
            .toList();
        _articulos = articulosSnapshot.docs
            .map((doc) => Articulo.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        articulos: _articulos,
        onItemAdded: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveTraspaso() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un artículo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final traspaso = Traspaso(
        id: '',
        numeroTraspaso: _generateTraspasoNumber(),
        almacenOrigen: _almacenOrigen,
        almacenDestino: _almacenDestino,
        items: _items,
        estado: EstadoTraspaso.pendiente,
        observaciones: _observacionesController.text.trim(),
        fechaCreacion: DateTime.now(),
        creadoPor: 'usuario_actual', // Aquí deberías usar el ID del usuario actual
      );

      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('traspasos')
          .add(traspaso.toMap());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Traspaso creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear traspaso: $e'),
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

  String _generateTraspasoNumber() {
    final now = DateTime.now();
    return 'TRP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traspaso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTraspaso,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _almacenDestino.isEmpty ? null : _almacenDestino,
              decoration: const InputDecoration(
                labelText: 'Almacén Destino *',
                border: OutlineInputBorder(),
              ),
              items: _almacenes.where((almacen) => almacen != _almacenOrigen).map((almacen) {
                return DropdownMenuItem(
                  value: almacen,
                  child: Text(almacen),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _almacenDestino = value ?? '';
                });
              },
              validator: (value) => value?.isEmpty == true 
                  ? 'Seleccione el almacén destino' 
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artículos (${_items.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay artículos agregados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.nombreArticulo),
                      subtitle: Text('Código: ${item.codigoArticulo}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cantidad: ${item.cantidad}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemDialog extends StatefulWidget {
  final List<Articulo> articulos;
  final Function(ItemTraspaso) onItemAdded;

  const _ItemDialog({
    required this.articulos,
    required this.onItemAdded,
  });

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _cantidadController = TextEditingController();
  Articulo? _selectedArticulo;

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedArticulo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un artículo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese una cantidad válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (cantidad > _selectedArticulo!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock insuficiente. Stock actual: ${_selectedArticulo!.stock}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final item = ItemTraspaso(
      articuloId: _selectedArticulo!.id,
      nombreArticulo: _selectedArticulo!.nombre,
      codigoArticulo: _selectedArticulo!.codigo,
      cantidad: cantidad,
    );

    widget.onItemAdded(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Artículo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Articulo>(
            value: _selectedArticulo,
            decoration: const InputDecoration(
              labelText: 'Artículo *',
              border: OutlineInputBorder(),
            ),
            items: widget.articulos.map((articulo) {
              return DropdownMenuItem(
                value: articulo,
                child: Text('${articulo.nombre} (${articulo.codigo})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedArticulo = value;
              });
            },
          ),
          if (_selectedArticulo != null) ...[
            const SizedBox(height: 8),
            Text(
              'Stock disponible: ${_selectedArticulo!.stock}',
              style: TextStyle(
                color: _selectedArticulo!.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _cantidadController,
            decoration: const InputDecoration(
              labelText: 'Cantidad *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}FormField<String>(
              value: _almacenOrigen.isEmpty ? null : _almacenOrigen,
              decoration: const InputDecoration(
                labelText: 'Almacén Origen *',
                border: OutlineInputBorder(),
              ),
              items: _almacenes.map((almacen) {
                return DropdownMenuItem(
                  value: almacen,
                  child: Text(almacen),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _almacenOrigen = value ?? '';
                });
              },
              validator: (value) => value?.isEmpty == true 
                  ? 'Seleccione el almacén origen' 
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButton