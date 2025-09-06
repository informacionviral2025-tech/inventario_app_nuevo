// lib/screens/entradas/detalle_albaran_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/albaran_proveedor.dart';
import '../../services/albaran_proveedor_service.dart';
import '../albaranes/crear_albaran_screen.dart';

class DetalleAlbaranScreen extends StatefulWidget {
  final String empresaId;
  final AlbaranProveedor albaran;

  const DetalleAlbaranScreen({
    Key? key,
    required this.empresaId,
    required this.albaran,
  }) : super(key: key);

  @override
  State<DetalleAlbaranScreen> createState() => _DetalleAlbaranScreenState();
}

class _DetalleAlbaranScreenState extends State<DetalleAlbaranScreen> {
  final AlbaranProveedorService _albaranService = AlbaranProveedorService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albarán #${widget.albaran.numeroAlbaran}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (widget.albaran.esPendiente)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'procesar',
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Procesar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancelar',
                  child: ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Cancelar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildArticulosCard(),
            const SizedBox(height: 16),
            _buildTotalesCard(),
            if (widget.albaran.observaciones?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildObservacionesCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: widget.albaran.esPendiente
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _procesarAlbaran,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isProcessing ? 'Procesando...' : 'Procesar Albarán'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.albaran.colorEstado,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado: ${widget.albaran.estadoTexto}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.albaran.fechaProcesado != null)
                    Text(
                      'Procesado: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.albaran.fechaProcesado!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Número:', widget.albaran.numeroAlbaran),
            _buildInfoRow('Proveedor:', widget.albaran.proveedorNombre),
            _buildInfoRow(
              'Fecha:',
              DateFormat('dd/MM/yyyy').format(widget.albaran.fechaAlbaran),
            ),
            _buildInfoRow(
              'Registrado:',
              DateFormat('dd/MM/yyyy HH:mm').format(widget.albaran.fechaRegistro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildArticulosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Artículos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.albaran.lineas.length} líneas',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.albaran.lineas.map((linea) => _buildLineaItem(linea)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineaItem(LineaAlbaran linea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  linea.articuloNombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${linea.totalLinea.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (linea.articuloCodigo.isNotEmpty)
            Text(
              'Código: ${linea.articuloCodigo}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          Row(
            children: [
              Text('Cantidad: ${linea.cantidad}'),
              const SizedBox(width: 16),
              Text('Precio: ${linea.precioUnitario.toStringAsFixed(2)} €'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Totales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTotalRow('Subtotal:', widget.albaran.subtotalFormateado),
            _buildTotalRow(
              'IVA (${widget.albaran.iva}%):',
              widget.albaran.ivaFormateado,
            ),
            const Divider(),
            _buildTotalRow(
              'Total:',
              widget.albaran.totalFormateado,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservacionesCard() {
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
            const SizedBox(height: 8),
            Text(widget.albaran.observaciones!),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'editar':
        await _editarAlbaran();
        break;
      case 'procesar':
        await _procesarAlbaran();
        break;
      case 'cancelar':
        await _cancelarAlbaran();
        break;
    }
  }

  Future<void> _editarAlbaran() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearAlbaranScreen(
          empresaId: widget.empresaId,
          empresaNombre: '',
          albaran: widget.albaran,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true); // Refrescar la lista
    }
  }

  Future<void> _procesarAlbaran() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Procesar Albarán'),
        content: const Text('¿Estás seguro de que quieres procesar este albarán? '
            'Esta acción actualizará el stock de los artículos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Procesar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      await _albaranService.procesarAlbaran(widget.empresaId, widget.albaran.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Albarán procesado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Refrescar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _cancelarAlbaran() async {
    if (widget.albaran.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: El albarán no tiene un ID válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Albarán'),
        content: const Text('¿Estás seguro de que quieres cancelar este albarán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Albarán'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      await _albaranService.cancelarAlbaran(widget.empresaId, widget.albaran.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Albarán cancelado correctamente'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Refrescar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}