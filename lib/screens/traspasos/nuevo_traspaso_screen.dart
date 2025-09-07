import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/articulo.dart';
import '../../models/traspaso.dart';
import '../../services/articulo_service.dart';
import '../../services/traspaso_service.dart';

class NuevoTraspasoScreen extends StatefulWidget {
  const NuevoTraspasoScreen({super.key});

  @override
  State<NuevoTraspasoScreen> createState() => _NuevoTraspasoScreenState();
}

class _NuevoTraspasoScreenState extends State<NuevoTraspasoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ArticuloService _articuloService = ArticuloService();
  final TraspasoService _traspasoService = TraspasoService();
  
  String _tipoOrigen = 'almacen';
  String _almacenOrigen = '';
  String _obraOrigen = '';
  String _tipoDestino = 'almacen';
  String _almacenDestino = '';
  String _obraDestino = '';
  String _observaciones = '';
  
  List<String> _almacenes = ['Almacén Central', 'Almacén Norte', 'Almacén Sur'];
  List<String> _obras = ['Obra 1', 'Obra 2', 'Obra 3'];
  List<Articulo> _articulos = [];
  List<Articulo> _articulosSeleccionados = [];
  Map<String, int> _cantidades = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArticulos();
  }

  Future<void> _loadArticulos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final empresaId = authProvider.currentUser?.empresaId ?? '';
      _articulos = await _articuloService.getArticulos(empresaId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar artículos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _agregarArticulo(Articulo articulo) {
    if (!_articulosSeleccionados.contains(articulo)) {
      setState(() {
        _articulosSeleccionados.add(articulo);
        _cantidades[articulo.firebaseId ?? articulo.codigo] = 1;
      });
    }
  }

  void _removerArticulo(Articulo articulo) {
    setState(() {
      _articulosSeleccionados.remove(articulo);
      _cantidades.remove(articulo.firebaseId ?? articulo.codigo);
    });
  }

  void _actualizarCantidad(Articulo articulo, int cantidad) {
    setState(() {
      _cantidades[articulo.firebaseId ?? articulo.codigo] = cantidad;
    });
  }

  Future<void> _guardarTraspaso() async {
    if (!_formKey.currentState!.validate()) return;
    if (_articulosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos un artículo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final empresaId = authProvider.currentUser?.empresaId ?? '';
      final usuario = authProvider.currentUser?.displayName ?? '';

      // Determinar origen y destino
      String origenId = _tipoOrigen == 'almacen' ? _almacenOrigen : _obraOrigen;
      String destinoId = _tipoDestino == 'almacen' ? _almacenDestino : _obraDestino;

      // Crear mapa de artículos con cantidades
      Map<String, int> articulosMap = {};
      for (final articulo in _articulosSeleccionados) {
        final id = articulo.firebaseId ?? articulo.codigo;
        articulosMap[id] = _cantidades[id] ?? 1;
      }

      final traspaso = Traspaso(
        empresaId: empresaId,
        tipoOrigen: _tipoOrigen,
        origenId: origenId,
        tipoDestino: _tipoDestino,
        destinoId: destinoId,
        articulos: articulosMap,
        usuario: usuario,
        fecha: DateTime.now(),
        observaciones: _observaciones.isNotEmpty ? _observaciones : null,
      );

      await _traspasoService.crearTraspaso(traspaso);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Traspaso creado exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear traspaso: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traspaso'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrigenSection(),
                    const SizedBox(height: 16),
                    _buildDestinoSection(),
                    const SizedBox(height: 24),
                    _buildArticulosSection(),
                    const SizedBox(height: 16),
                    _buildObservacionesSection(),
                    const SizedBox(height: 16),
                    _buildResumenSection(),
                    const SizedBox(height: 24),
                    _buildBotonesAccion(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrigenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Origen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoOrigen,
              decoration: const InputDecoration(
                labelText: 'Tipo de Origen',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'almacen', child: Text('Almacén')),
                DropdownMenuItem(value: 'obra', child: Text('Obra')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoOrigen = value!;
                  _almacenOrigen = '';
                  _obraOrigen = '';
                });
              },
            ),
            const SizedBox(height: 16),
            if (_tipoOrigen == 'almacen') ...[
              DropdownButtonFormField<String>(
                value: _almacenOrigen.isEmpty ? null : _almacenOrigen,
                decoration: const InputDecoration(
                  labelText: 'Almacén de Origen',
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
                    ? 'Seleccione un almacén de origen'
                    : null,
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                value: _obraOrigen.isEmpty ? null : _obraOrigen,
                decoration: const InputDecoration(
                  labelText: 'Obra de Origen',
                  border: OutlineInputBorder(),
                ),
                items: _obras.map((obra) {
                  return DropdownMenuItem(
                    value: obra,
                    child: Text(obra),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _obraOrigen = value ?? '';
                  });
                },
                validator: (value) => value?.isEmpty == true
                    ? 'Seleccione una obra de origen'
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDestinoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Destino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoDestino,
              decoration: const InputDecoration(
                labelText: 'Tipo de Destino',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'almacen', child: Text('Almacén')),
                DropdownMenuItem(value: 'obra', child: Text('Obra')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoDestino = value!;
                  _almacenDestino = '';
                  _obraDestino = '';
                });
              },
            ),
            const SizedBox(height: 16),
            if (_tipoDestino == 'almacen') ...[
              DropdownButtonFormField<String>(
                value: _almacenDestino.isEmpty ? null : _almacenDestino,
                decoration: const InputDecoration(
                  labelText: 'Almacén de Destino',
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
                    _almacenDestino = value ?? '';
                  });
                },
                validator: (value) => value?.isEmpty == true
                    ? 'Seleccione un almacén de destino'
                    : null,
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                value: _obraDestino.isEmpty ? null : _obraDestino,
                decoration: const InputDecoration(
                  labelText: 'Obra de Destino',
                  border: OutlineInputBorder(),
                ),
                items: _obras.map((obra) {
                  return DropdownMenuItem(
                    value: obra,
                    child: Text(obra),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _obraDestino = value ?? '';
                  });
                },
                validator: (value) => value?.isEmpty == true
                    ? 'Seleccione una obra de destino'
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Artículos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _mostrarDialogoSeleccionArticulos,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_articulosSeleccionados.isEmpty)
              const Center(
                child: Text(
                  'No hay artículos seleccionados',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articulosSeleccionados.length,
                itemBuilder: (context, index) {
                  final articulo = _articulosSeleccionados[index];
                  final id = articulo.firebaseId ?? articulo.codigo;
                  final cantidad = _cantidades[id] ?? 1;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(articulo.descripcion),
                      subtitle: Text('Código: ${articulo.codigo}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: cantidad > 1
                                ? () => _actualizarCantidad(articulo, cantidad - 1)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text('$cantidad'),
                          IconButton(
                            onPressed: () => _actualizarCantidad(articulo, cantidad + 1),
                            icon: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _removerArticulo(articulo),
                            icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildObservacionesSection() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Observaciones (opcional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _observaciones = value,
    );
  }

  Widget _buildResumenSection() {
    final totalArticulos = _cantidades.values.fold<int>(0, (sum, cantidad) => sum + cantidad);
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Traspaso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total de artículos: $totalArticulos'),
            const SizedBox(height: 8),
            Text('Tipos de artículos: ${_articulosSeleccionados.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarTraspaso,
            child: const Text('Crear Traspaso'),
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoSeleccionArticulos() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Seleccionar Artículos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _articulos.length,
                  itemBuilder: (context, index) {
                    final articulo = _articulos[index];
                    final yaSeleccionado = _articulosSeleccionados.contains(articulo);

                    return Card(
                      child: ListTile(
                        title: Text(articulo.descripcion),
                        subtitle: Text(
                          'Código: ${articulo.codigo}\nStock: ${articulo.stock}',
                        ),
                        trailing: yaSeleccionado
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.add),
                        onTap: yaSeleccionado
                            ? null
                            : () {
                                _agregarArticulo(articulo);
                                Navigator.pop(context);
                              },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}