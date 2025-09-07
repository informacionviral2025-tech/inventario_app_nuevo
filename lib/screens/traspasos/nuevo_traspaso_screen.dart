import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/articulo.dart';
import '../../models/traspaso.dart';
import '../../services/articulo_service.dart';
import '../../services/traspaso_service.dart';

class NuevoTraspasoScreen extends StatefulWidget {
  final String empresaId;

  const NuevoTraspasoScreen({super.key, required this.empresaId});

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
    setState(() { _isLoading = true; });
    try {
      _articulos = await _articuloService.getArticulos(widget.empresaId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar artículos: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
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

    setState(() { _isLoading = true; });
    try {
      final usuario = 'Usuario Demo';
      String origenId = _tipoOrigen == 'almacen' ? _almacenOrigen : _obraOrigen;
      String destinoId = _tipoDestino == 'almacen' ? _almacenDestino : _obraDestino;

      Map<String, int> articulosMap = {};
      for (final articulo in _articulosSeleccionados) {
        final id = articulo.firebaseId ?? articulo.codigo;
        articulosMap[id] = _cantidades[id] ?? 1;
      }

      final traspaso = Traspaso(
        empresaId: widget.empresaId,
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
      if (mounted) { setState(() { _isLoading = false; }); }
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

  // --- Aquí van los métodos _buildOrigenSection, _buildDestinoSection, _buildArticulosSection, _buildObservacionesSection, _buildResumenSection, _buildBotonesAccion, _mostrarDialogoSeleccionArticulos ---
  // Se mantienen exactamente como los tenías, solo que ahora recibe empresaId desde widget.empresaId
}
