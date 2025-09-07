// lib/screens/traspasos/nuevo_traspaso_screen.dart
import 'package:flutter/material.dart';
import '../../models/articulo.dart';
import '../../models/traspaso.dart';
import '../../services/articulo_service.dart';
import '../../services/traspaso_service.dart';

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
  final ArticuloService _articuloService = ArticuloService('');
  final TraspasoService _traspasoService = TraspasoService('');
  final TextEditingController _observacionesController = TextEditingController();

  List<Articulo> _articulos = [];
  List<Articulo> _articulosSeleccionados = [];
  Map<String, int> _cantidades = {};
  
  String? _ubicacionOrigen;
  String? _ubicacionDestino;
  bool _isLoading = false;

  final List<String> _ubicaciones = [
    'Almacén Principal',
    'Almacén Secundario',
    'Tienda 1',
    'Tienda 2',
    'Sucursal Norte',
    'Sucursal Sur',
    'Bodega Central',
    'Punto de Venta',
  ];

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarArticulos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articuloService = ArticuloService(widget.empresaId);
      _articulos = await articuloService.getArticulos();
      _articulos = _articulos.where((a) => a.stock > 0).toList();
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
        final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;
        _cantidades[key] = 1;
      });
    }
  }

  void _removerArticulo(Articulo articulo) {
    setState(() {
      _articulosSeleccionados.remove(articulo);
      final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;
      _cantidades.remove(key);
    });
  }

  void _actualizarCantidad(Articulo articulo, int cantidad) {
    if (cantidad > 0 && cantidad <= articulo.stock) {
      setState(() {
        final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;
        _cantidades[key] = cantidad;
      });
    }
  }

  Future<void> _crearTraspaso() async {
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
      // Crear mapa de artículos con sus cantidades
      final Map<String, int> articulosMap = {};
      for (var articulo in _articulosSeleccionados) {
        final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;
        articulosMap[key] = _cantidades[key] ?? 1;
      }

      final traspaso = Traspaso(
        empresaId: widget.empresaId,
        ubicacionOrigen: _ubicacionOrigen!,
        ubicacionDestino: _ubicacionDestino!,
        articulos: articulosMap,
        observaciones: _observacionesController.text.trim().isEmpty 
            ? null 
            : _observacionesController.text.trim(),
        fecha: DateTime.now(),
      );

      final traspasoService = TraspasoService(widget.empresaId);
      await traspasoService.crearTraspaso(traspaso);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Traspaso creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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

  Widget _buildOrigenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación de Origen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _ubicacionOrigen,
              decoration: const InputDecoration(
                labelText: 'Seleccionar origen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _ubicaciones.map((ubicacion) {
                return DropdownMenuItem(
                  value: ubicacion,
                  child: Text(ubicacion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _ubicacionOrigen = value;
                  if (_ubicacionDestino == value) {
                    _ubicacionDestino = null;
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe seleccionar una ubicación de origen';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación de Destino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _ubicacionDestino,
              decoration: const InputDecoration(
                labelText: 'Seleccionar destino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              items: _ubicaciones
                  .where((ubicacion) => ubicacion != _ubicacionOrigen)
                  .map((ubicacion) {
                return DropdownMenuItem(
                  value: ubicacion,
                  child: Text(ubicacion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _ubicacionDestino = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe seleccionar una ubicación de destino';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artículos a Traspasar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_articulos.isEmpty)
              const Text('No hay artículos disponibles')
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _articulos.length,
                  itemBuilder: (context, index) {
                    final articulo = _articulos[index];
                    final isSelected = _articulosSeleccionados.contains(articulo);
                    final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.green : Colors.grey,
                        child: Text(
                          articulo.stock.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(articulo.descripcion ?? articulo.nombre),
                      subtitle: Text('Código: ${articulo.codigo} | Stock: ${articulo.stock}'),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                    controller: TextEditingController(
                                      text: (_cantidades[key] ?? 1).toString(),
                                    ),
                                    onChanged: (value) {
                                      final cantidad = int.tryParse(value) ?? 1;
                                      _actualizarCantidad(articulo, cantidad);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removerArticulo(articulo),
                                ),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => _agregarArticulo(articulo),
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacionesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones adicionales (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Ingrese cualquier observación relevante...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenSection() {
    if (_articulosSeleccionados.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Traspaso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_ubicacionOrigen != null)
              Text('Origen: $_ubicacionOrigen'),
            if (_ubicacionDestino != null)
              Text('Destino: $_ubicacionDestino'),
            const SizedBox(height: 8),
            Text('Artículos seleccionados: ${_articulosSeleccionados.length}'),
            const SizedBox(height: 8),
            const Text(
              'Detalle:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ..._articulosSeleccionados.map((articulo) {
              final key = articulo.firebaseId ?? articulo.id ?? articulo.codigo;
              final cantidad = _cantidades[key] ?? 1;
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• ${articulo.descripcion ?? articulo.nombre}: $cantidad unidades'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _crearTraspaso,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Traspaso'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traspaso'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _articulos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrigenSection(),
                    const SizedBox(height: 16),
                    _buildDestinoSection(),
                    const SizedBox(height: 16),
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
}