import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/articulo.dart';

class ArticulosScreen extends StatefulWidget {
  final String empresaId;

  const ArticulosScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<ArticulosScreen> createState() => _ArticulosScreenState();
}

class _ArticulosScreenState extends State<ArticulosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Articulo> _articulos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticulos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticulos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .orderBy('nombre')
          .get();

      setState(() {
        _articulos = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Articulo.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar artículos: $e'),
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

  List<Articulo> get _filteredArticulos {
    if (_searchQuery.isEmpty) {
      return _articulos;
    }
    return _articulos.where((articulo) {
      return articulo.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          articulo.codigo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          articulo.categoria.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showArticuloDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar artículos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredArticulos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay artículos disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredArticulos.length,
                        itemBuilder: (context, index) {
                          final articulo = _filteredArticulos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStockColor(articulo.stock),
                                child: Text(
                                  articulo.stock.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                articulo.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Código: ${articulo.codigo}'),
                                  Text('Categoría: ${articulo.categoria}'),
                                  Text(
                                    'Precio: €${articulo.precio.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showArticuloDialog(articulo: articulo);
                                      break;
                                    case 'delete':
                                      _confirmDelete(articulo);
                                      break;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    if (stock < 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  void _showArticuloDialog({Articulo? articulo}) {
    showDialog(
      context: context,
      builder: (context) => ArticuloDialog(
        empresaId: widget.empresaId,
        articulo: articulo,
        onSaved: () {
          _loadArticulos();
        },
      ),
    );
  }

  void _confirmDelete(Articulo articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el artículo "${articulo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteArticulo(articulo);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArticulo(Articulo articulo) async {
    try {
      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articulo.id)
          .delete();

      _loadArticulos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artículo eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ArticuloDialog extends StatefulWidget {
  final String empresaId;
  final Articulo? articulo;
  final VoidCallback onSaved;

  const ArticuloDialog({
    super.key,
    required this.empresaId,
    this.articulo,
    required this.onSaved,
  });

  @override
  State<ArticuloDialog> createState() => _ArticuloDialogState();
}

class _ArticuloDialogState extends State<ArticuloDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.articulo != null) {
      final articulo = widget.articulo!;
      _nombreController.text = articulo.nombre;
      _codigoController.text = articulo.codigo;
      _categoriaController.text = articulo.categoria;
      _precioController.text = articulo.precio.toString();
      _stockController.text = articulo.stock.toString();
      _descripcionController.text = articulo.descripcion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _categoriaController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveArticulo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final articulo = Articulo(
        id: widget.articulo?.id ?? '',
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim(),
        categoria: _categoriaController.text.trim(),
        precio: double.parse(_precioController.text),
        stock: int.parse(_stockController.text),
        descripcion: _descripcionController.text.trim().isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        fechaCreacion: widget.articulo?.fechaCreacion ?? DateTime.now(),
        fechaModificacion: DateTime.now(),
      );

      if (widget.articulo != null) {
        // Actualizar
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .doc(widget.articulo!.id)
            .update(articulo.toMap());
      } else {
        // Crear nuevo
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .add(articulo.toMap());
      }

      widget.onSaved();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.articulo != null 
                ? 'Artículo actualizado exitosamente'
                : 'Artículo creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.articulo != null ? 'Editar Artículo' : 'Nuevo Artículo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'El nombre es requerido' 
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'El código es requerido' 
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'La categoría es requerida' 
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'El precio es requerido';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'El stock es requerido';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Stock inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveArticulo,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.articulo != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }
}