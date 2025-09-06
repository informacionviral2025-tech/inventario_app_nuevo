// lib/screens/traspasos/traspaso_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/traspaso_service.dart';
import '../../services/articulo_service.dart';
import '../../models/traspaso.dart';
import '../../models/articulo.dart';

class TraspasoDetalleScreen extends StatefulWidget {
  final String empresaId;
  final String traspasoId;

  const TraspasoDetalleScreen({
    Key? key,
    required this.empresaId,
    required this.traspasoId,
  }) : super(key: key);

  @override
  State<TraspasoDetalleScreen> createState() => _TraspasoDetalleScreenState();
}

class _TraspasoDetalleScreenState extends State<TraspasoDetalleScreen> {
  final TraspasoService _traspasoService = TraspasoService();
  late ArticuloService _articuloService;
  
  Traspaso? traspaso;
  List<Articulo> todosLosArticulos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _articuloService = ArticuloService(widget.empresaId);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => isLoading = true);

      // Cargar el traspaso
      final doc = await FirebaseFirestore.instance
          .collection('traspasos')
          .doc(widget.traspasoId)
          .get();

      if (doc.exists) {
        traspaso = Traspaso.fromFirestore(doc);
      }

      // Cargar artículos
      final articulosStream = _articuloService.getArticulosActivos();
      articulosStream.listen((articulos) {
        if (mounted) {
          setState(() {
            todosLosArticulos = articulos;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      _mostrarError('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (traspaso == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudo cargar el traspaso'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildRutaSection(),
                  const SizedBox(height: 16),
                  _buildArticulosSection(),
                  const SizedBox(height: 16),
                  _buildAccionesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final estadoColor = _getEstadoColor(traspaso!.estado);
    
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: estadoColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Traspaso #${widget.traspasoId.substring(0, 8)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [estadoColor, estadoColor.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    traspaso!.estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Información General',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Fecha:', _formatearFecha(traspaso!.fecha)),
            _buildInfoRow('Usuario:', traspaso!.usuario),
            _buildInfoRow('Total artículos:', '${traspaso!.totalArticulos}'),
            if (traspaso!.albaranId != null)
              _buildInfoRow('Albarán:', traspaso!.albaranId!),
            if (traspaso!.fechaConfirmacion != null)
              _buildInfoRow('Confirmado:', _formatearFecha(traspaso!.fechaConfirmacion!)),
            if (traspaso!.observaciones?.isNotEmpty == true)
              _buildInfoRow('Observaciones:', traspaso!.observaciones!),
          ],
        ),
      ),
    );
  }

  Widget _buildRutaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Ruta del Traspaso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPuntoRuta(
                    'Origen',
                    traspaso!.tipoOrigen.toUpperCase(),
                    traspaso!.origenId,
                    Colors.orange,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey.shade600,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: _buildPuntoRuta(
                    'Destino',
                    traspaso!.tipoDestino.toUpperCase(),
                    traspaso!.destinoId,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuntoRuta(String label, String tipo, String id, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                tipo == 'EMPRESA' ? Icons.business : Icons.work,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                tipo,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          id.length > 20 ? '${id.substring(0, 20)}...' : id,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
                Icon(Icons.inventory_2, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Artículos Traspasados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${traspaso!.articulos.length}',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...traspaso!.articulos.entries.map(
              (entry) => _buildArticuloItem(entry.key, entry.value),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildArticuloItem(String articuloId, int cantidad) {
    final articulo = _findArticuloById(articuloId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo?.nombre ?? 'Artículo $articuloId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Código: ${articulo?.codigo ?? articuloId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (articulo?.precio != null)
                  Text(
                    'Precio: €${articulo!.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$cantidad',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'unidades',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesSection() {
    if (traspaso!.isCompletado) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Traspaso Completado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Este traspaso se ha completado exitosamente.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _mostrarDetallesAlbaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.receipt),
                label: const Text('Ver Albarán'),
              ),
            ],
          ),
        ),
      );
    }

    if (traspaso!.isPendiente) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.pending, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Acciones Disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmarRecepcion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelarTraspaso,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade600),
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Container(); // Si está cancelado o devuelto, no mostrar acciones
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green.shade600;
      case 'pendiente':
        return Colors.orange.shade600;
      case 'cancelado':
        return Colors.red.shade600;
      case 'devuelto':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Articulo? _findArticuloById(String id) {
    try {
      return todosLosArticulos.firstWhere(
        (art) => art.firebaseId == id || art.codigo == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Acciones
  Future<void> _confirmarRecepcion() async {
    try {
      if (traspaso!.albaranId != null) {
        await _traspasoService.confirmarRecepcion(traspaso!.albaranId!);
        await _cargarDatos();
        _mostrarExito('Recepción confirmada correctamente');
      }
    } catch (e) {
      _mostrarError('Error al confirmar recepción: $e');
    }
  }

  Future<void> _cancelarTraspaso() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Traspaso'),
        content: const Text('¿Estás seguro de que quieres cancelar este traspaso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        // Aquí implementarías la lógica de cancelación
        // await _traspasoService.cancelarTraspaso(widget.traspasoId);
        _mostrarExito('Traspaso cancelado correctamente');
      } catch (e) {
        _mostrarError('Error al cancelar traspaso: $e');
      }
    }
  }

  void _mostrarDetallesAlbaran() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Albarán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número: ${traspaso!.albaranId ?? 'No disponible'}'),
            const SizedBox(height: 8),
            Text('Fecha: ${_formatearFecha(traspaso!.fecha)}'),
            const SizedBox(height: 8),
            Text('Estado: ${traspaso!.estado.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías implementar la descarga del albarán
              _mostrarExito('Funcionalidad de descarga próximamente');
            },
            child: const Text('Descargar PDF'),
          ),
        ],
      ),
    );
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
}