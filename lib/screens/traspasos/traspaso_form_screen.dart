// lib/screens/traspasos/traspaso_form_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/traspaso_service.dart';
import '../../services/articulo_service.dart';
import '../../services/obra_service.dart';
import '../../models/articulo.dart';
import '../../models/obra.dart';

class TraspasoFormScreen extends StatefulWidget {
  final String origenId;
  final String tipoOrigen;
  final String? destinoId;
  final String? tipoDestino;
  final String? articuloPreseleccionado;
  final int? cantidadMaxima;

  const TraspasoFormScreen({
    super.key,
    required this.origenId,
    required this.tipoOrigen,
    this.destinoId,
    this.tipoDestino,
    this.articuloPreseleccionado,
    this.cantidadMaxima,
  });

  @override
  State<TraspasoFormScreen> createState() => _TraspasoFormScreenState();
}

class _TraspasoFormScreenState extends State<TraspasoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _traspasoService = TraspasoService();
  
  // Controladores
  final _observacionesController = TextEditingController();
  final _articuloController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Estado del formulario
  String? _destinoId;
  String _tipoDestino = 'obra';
  Map<String, int> _articulosSeleccionados = {};
  List<Articulo> _todosLosArticulos = [];
  List<Obra> _obrasDisponibles = [];
  bool _isLoading = false;

  // Servicios
  late ArticuloService _articuloService;
  late ObraService _obraService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeForm();
    _cargarDatos();
  }

  void _initializeServices() {
    // Determinar el empresaId basado en el contexto
    final empresaId = widget.tipoOrigen == 'empresa' 
        ? widget.origenId 
        : widget.destinoId ?? widget.origenId;
    
    _articuloService = ArticuloService(empresaId);
    _obraService = ObraService(empresaId);
  }

  void _initializeForm() {
    _destinoId = widget.destinoId;
    _tipoDestino = widget.tipoDestino ?? 'obra';
    
    // Si hay un artículo preseleccionado, agregarlo
    if (widget.articuloPreseleccionado != null) {
      _articulosSeleccionados[widget.articuloPreseleccionado!] = 
          widget.cantidadMaxima ?? 1;
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar artículos
      final articulosStream = _articuloService.getArticulosActivos();
      articulosStream.listen((articulos) {
        if (mounted) {
          setState(() => _todosLosArticulos = articulos);
        }
      });

      // Cargar obras disponibles
      final obrasStream = _obraService.getObrasPorEstado('activa');
      obrasStream.listen((obras) {
        if (mounted) {
          setState(() {
            _obrasDisponibles = obras.where((o) => o.firebaseId != widget.origenId).toList();
          });
        }
      });
    } catch (e) {
      _mostrarError('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traspaso'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Header con información del origen
          _buildOrigenHeader(),
          
          // Formulario principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDestinoSection(),
                  const SizedBox(height: 24),
                  _buildArticulosSection(),
                  const SizedBox(height: 24),
                  _buildObservacionesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrigenHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Origen del Traspaso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.tipoOrigen == 'empresa' ? Icons.business : Icons.work,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.tipoOrigen == 'empresa' ? 'Empresa' : 'Obra',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.origenId,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
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
            Text(
              'Destino',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Selector de tipo de destino
            DropdownButtonFormField<String?>(
              value: _tipoDestino,
              decoration: const InputDecoration(
                labelText: 'Tipo de destino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: const [
                DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                DropdownMenuItem(value: 'obra', child: Text('Obra')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoDestino = value!;
                  _destinoId = null; // Resetear selección
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Selector de destino específico
            if (_tipoDestino == 'obra')
              _buildSelectorObra()
            else
              _buildSelectorEmpresa(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorObra() {
    return DropdownButtonFormField<String>(
      value: _destinoId,
      decoration: const InputDecoration(
        labelText: 'Seleccionar obra',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.work),
      ),
      validator: (value) => value == null ? 'Selecciona una obra' : null,
      items: _obrasDisponibles.map((obra) {
        return DropdownMenuItem(
          value: obra.firebaseId as String?,
          child: Text(obra.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _destinoId = value);
      },
    );
  }

  Widget _buildSelectorEmpresa() {
    return TextFormField(
      initialValue: _destinoId,
      decoration: const InputDecoration(
        labelText: 'ID de la empresa',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
        hintText: 'Ingresa el ID de la empresa destino',
      ),
      validator: (value) => 
          value?.isEmpty == true ? 'Ingresa el ID de la empresa' : null,
      onChanged: (value) => _destinoId = value.trim(),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Artículos a Traspasar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_articulosSeleccionados.length} seleccionados',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Formulario para agregar artículos
            _buildAgregarArticuloForm(),
            
            const SizedBox(height: 16),
            
            // Lista de artículos seleccionados
            if (_articulosSeleccionados.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Artículos Seleccionados:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ..._articulosSeleccionados.entries.map(
                (entry) => _buildArticuloSeleccionado(entry.key, entry.value),
              ).toList(),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay artículos seleccionados',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgregarArticuloForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _articuloController,
                decoration: const InputDecoration(
                  labelText: 'Código del artículo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _escanearArticulo,
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Escanear código',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _agregarArticulo,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticuloSeleccionado(String articuloId, int cantidad) {
    final articulo = _findArticuloById(articuloId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo?.nombre ?? 'Artículo $articuloId',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Código: $articuloId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$cantidad',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removerArticulo(articuloId),
            icon: const Icon(Icons.close),
            iconSize: 20,
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade700,
            ),
          ),
        ],
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
            Text(
              'Observaciones (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                hintText: 'Notas adicionales sobre el traspaso...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _puedeCrearTraspaso() ? _crearTraspaso : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Crear Traspaso',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de funcionalidad

  Future<void> _escanearArticulo() async {
    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("Escanear código"),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            body: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final codigo = barcodes.first.rawValue;
                  if (codigo != null) {
                    Navigator.pop(context, codigo);
                  }
                }
              },
            ),
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _articuloController.text = result;
        });
      }
    } catch (e) {
      _mostrarError('Error al escanear código: $e');
    }
  }

  void _agregarArticulo() {
    final articuloId = _articuloController.text.trim();
    final cantidadTexto = _cantidadController.text.trim();
    
    if (articuloId.isEmpty) {
      _mostrarError('Ingresa el código del artículo');
      return;
    }
    
    final cantidad = int.tryParse(cantidadTexto);
    if (cantidad == null || cantidad <= 0) {
      _mostrarError('Ingresa una cantidad válida');
      return;
    }

    // Validar cantidad máxima si está definida
    if (widget.cantidadMaxima != null && 
        articuloId == widget.articuloPreseleccionado) {
      final cantidadActual = _articulosSeleccionados[articuloId] ?? 0;
      if (cantidadActual + cantidad > widget.cantidadMaxima!) {
        _mostrarError(
          'Cantidad máxima disponible: ${widget.cantidadMaxima! - cantidadActual}'
        );
        return;
      }
    }

    setState(() {
      _articulosSeleccionados.update(
        articuloId,
        (existente) => existente + cantidad,
        ifAbsent: () => cantidad,
      );
    });

    // Limpiar formulario
    _articuloController.clear();
    _cantidadController.clear();
    
    _mostrarExito('Artículo agregado correctamente');
  }

  void _removerArticulo(String articuloId) {
    setState(() {
      _articulosSeleccionados.remove(articuloId);
    });
  }

  bool _puedeCrearTraspaso() {
    return _formKey.currentState?.validate() == true &&
           _destinoId != null &&
           _destinoId!.isNotEmpty &&
           _articulosSeleccionados.isNotEmpty;
  }

  Future<void> _crearTraspaso() async {
    if (!_puedeCrearTraspaso()) return;

    setState(() => _isLoading = true);

    try {
      await _traspasoService.crearTraspaso(
        origenId: widget.origenId,
        destinoId: _destinoId!,
        tipoOrigen: widget.tipoOrigen,
        tipoDestino: _tipoDestino,
        articulos: _articulosSeleccionados,
        usuario: 'Usuario actual', // TODO: usar usuario real
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _mostrarError('Error al crear traspaso: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Articulo? _findArticuloById(String id) {
    try {
      return _todosLosArticulos.firstWhere(
        (art) => art.firebaseId == id || art.codigo == id,
      );
    } catch (e) {
      return null;
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _articuloController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}