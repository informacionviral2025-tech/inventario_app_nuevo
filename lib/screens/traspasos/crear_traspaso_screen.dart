// lib/screens/traspasos/crear_traspaso_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/traspaso_service.dart';
import '../../services/obra_service.dart';
import '../../services/articulo_service.dart';
import '../../models/articulo.dart';
import '../../models/obra.dart';

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
  late final TraspasoService _traspasoService;
  late final ObraService _obraService;
  late final ArticuloService _articuloService;

  String _tipoOrigen = 'empresa';
  String _tipoDestino = 'obra';
  String? _origenSeleccionado;
  String? _destinoSeleccionado;

  List<Obra> _obrasDisponibles = [];
  List<Articulo> _articulosDisponibles = [];
  Map<String, int> _articulosSeleccionados = {};

  bool _cargandoObras = false;
  bool _cargandoArticulos = false;

  @override
  void initState() {
    super.initState();
    _traspasoService = TraspasoService();
    _obraService = ObraService(widget.empresaId);
    _articuloService = ArticuloService(widget.empresaId);
    _cargarObras();
    _cargarArticulos();
  }

  Future<void> _cargarObras() async {
    setState(() => _cargandoObras = true);
    try {
      final obras = await _obraService.getObrasActivas().first;
      setState(() {
        _obrasDisponibles = obras;
      });
    } catch (e) {
      _mostrarError('Error al cargar obras: $e');
    } finally {
      setState(() => _cargandoObras = false);
    }
  }

  Future<void> _cargarArticulos() async {
    setState(() => _cargandoArticulos = true);
    try {
      final articulos = await _articuloService.getArticulosActivos().first;
      setState(() {
        _articulosDisponibles = articulos;
      });
    } catch (e) {
      _mostrarError('Error al cargar artículos: $e');
    } finally {
      setState(() => _cargandoArticulos = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traspaso'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSeccionTipos(),
            const SizedBox(height: 20),
            _buildSeccionOrigen(),
            const SizedBox(height: 16),
            _buildSeccionDestino(),
            const SizedBox(height: 20),
            _buildSeccionArticulos(),
            const SizedBox(height: 24),
            _buildBotonesAccion(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTipos() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Traspaso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Origen:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        value: _tipoOrigen,
                        items: const [
                          DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                          DropdownMenuItem(value: 'obra', child: Text('Obra')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoOrigen = value!;
                            _origenSeleccionado = null;
                            _articulosSeleccionados.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Destino:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        value: _tipoDestino,
                        items: const [
                          DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                          DropdownMenuItem(value: 'obra', child: Text('Obra')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoDestino = value!;
                            _destinoSeleccionado = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionOrigen() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Origen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_tipoOrigen == 'empresa')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Stock General de la Empresa',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              _buildDropdownObras(
                value: _origenSeleccionado,
                hint: 'Seleccionar obra origen',
                onChanged: (value) {
                  setState(() {
                    _origenSeleccionado = value;
                    _articulosSeleccionados.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionDestino() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Destino',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_tipoDestino == 'empresa')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Stock General de la Empresa',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              _buildDropdownObras(
                value: _destinoSeleccionado,
                hint: 'Seleccionar obra destino',
                onChanged: (value) {
                  setState(() => _destinoSeleccionado = value);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownObras({
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    if (_cargandoObras) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hint,
        isDense: true,
      ),
      value: value,
      items: _obrasDisponibles.map((obra) {
        return DropdownMenuItem(
          value: obra.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                obra.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                obra.direccion ?? 'Sin dirección',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSeccionArticulos() {
    if (_tipoOrigen == 'obra' && _origenSeleccionado == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Selecciona primero la obra origen',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Artículos a Traspasar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_articulosSeleccionados.isNotEmpty)
                  Chip(
                    label: Text('${_articulosSeleccionados.length} seleccionados'),
                    backgroundColor: Colors.blue.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_cargandoArticulos)
              const Center(child: CircularProgressIndicator())
            else if (_articulosDisponibles.isEmpty)
              const Text('No hay artículos disponibles')
            else
              ..._articulosDisponibles.map(_buildArticuloItem).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildArticuloItem(Articulo articulo) {
    final cantidad = _articulosSeleccionados[articulo.firebaseId!] ?? 0;
    final stockDisponible = articulo.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: cantidad > 0 ? Colors.blue.shade50 : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Stock disponible: $stockDisponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (articulo.descripcion != null && articulo.descripcion!.isNotEmpty)
                  Text(
                    articulo.descripcion!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: cantidad > 0
                    ? () {
                        setState(() {
                          _articulosSeleccionados[articulo.firebaseId!] = cantidad - 1;
                          if (_articulosSeleccionados[articulo.firebaseId!] == 0) {
                            _articulosSeleccionados.remove(articulo.firebaseId!);
                          }
                        });
                      }
                    : null,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$cantidad',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: cantidad < stockDisponible
                    ? () {
                        setState(() {
                          _articulosSeleccionados[articulo.firebaseId!] = cantidad + 1;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion() {
    final puedeCrearTraspaso = _articulosSeleccionados.isNotEmpty &&
        (_tipoOrigen == 'empresa' || _origenSeleccionado != null) &&
        (_tipoDestino == 'empresa' || _destinoSeleccionado != null);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: puedeCrearTraspaso ? _crearTraspaso : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear Traspaso'),
          ),
        ),
      ],
    );
  }

  Future<void> _crearTraspaso() async {
    try {
      // Determinar IDs de origen y destino
      String origenId;
      String destinoId;

      if (_tipoOrigen == 'empresa') {
        origenId = widget.empresaId;
      } else {
        origenId = _origenSeleccionado!;
      }

      if (_tipoDestino == 'empresa') {
        destinoId = widget.empresaId;
      } else {
        destinoId = _destinoSeleccionado!;
      }

      // Crear el traspaso
      await _traspasoService.crearTraspaso(
        origenId: origenId,
        destinoId: destinoId,
        tipoOrigen: _tipoOrigen,
        tipoDestino: _tipoDestino,
        articulos: _articulosSeleccionados,
        usuario: 'Usuario Actual', // Aquí deberías pasar el usuario actual
      );

      _mostrarExito('Traspaso creado exitosamente');
      Navigator.of(context).pop();
    } catch (e) {
      _mostrarError('Error al crear traspaso: $e');
    }
  }
}