// lib/screens/albaranes/lista_albaranes_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/albaran_proveedor.dart';
import '../../services/albaran_proveedor_service.dart';
import 'crear_albaran_screen.dart';

class ListaAlbaranesScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const ListaAlbaranesScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  State<ListaAlbaranesScreen> createState() => _ListaAlbaranesScreenState();
}

class _ListaAlbaranesScreenState extends State<ListaAlbaranesScreen> {
  final AlbaranProveedorService _albaranService = AlbaranProveedorService();
  String _filtroEstado = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albaranes de Proveedor'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filtroEstado = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('Todos')),
              const PopupMenuItem(value: 'pendiente', child: Text('Pendientes')),
              const PopupMenuItem(value: 'procesado', child: Text('Procesados')),
              const PopupMenuItem(value: 'parcial', child: Text('Parciales')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsRow(),
          Expanded(child: _buildAlbaranesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nuevoAlbaran(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Albarán'),
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<List<AlbaranProveedor>>(
      stream: _albaranService.getAlbaranes(widget.empresaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final albaranes = snapshot.data!;
        final total = albaranes.length;
        final pendientes = albaranes.where((a) => a.estaPendiente).length;
        final procesados = albaranes.where((a) => a.estaProcesado).length;
        final parciales = albaranes.where((a) => a.estaParcialment).length;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              _buildStatCard('Total', total.toString(), Icons.receipt, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Pendientes', pendientes.toString(), Icons.pending, Colors.orange),
              const SizedBox(width: 8),
              _buildStatCard('Procesados', procesados.toString(), Icons.check_circle, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Parciales', parciales.toString(), Icons.hourglass_empty, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbaranesList() {
    return StreamBuilder<List<AlbaranProveedor>>(
      stream: _albaranService.getAlbaranes(widget.empresaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final albaranes = snapshot.data ?? [];
        
        // Filtrar por estado
        var filteredAlbaranes = albaranes;
        if (_filtroEstado != 'todos') {
          filteredAlbaranes = albaranes.where((a) => a.estado == _filtroEstado).toList();
        }

        if (filteredAlbaranes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay albaranes'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAlbaranes.length,
          itemBuilder: (context, index) {
            final albaran = filteredAlbaranes[index];
            return _buildAlbaranCard(albaran);
          },
        );
      },
    );
  }

  Widget _buildAlbaranCard(AlbaranProveedor albaran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _verDetalles(albaran),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: albaran.colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: albaran.colorEstado,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Albarán #${albaran.numeroAlbaran}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          albaran.proveedorNombre,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: albaran.colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: albaran.colorEstado),
                    ),
                    child: Text(
                      albaran.estadoTexto,
                      style: TextStyle(
                        color: albaran.colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha: ${albaran.fechaAlbaran.toString().substring(0, 10)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Total: ${albaran.totalFormateado}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${albaran.articulosRecibidos}/${albaran.totalArticulos}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Artículos',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              if (albaran.estaPendiente || albaran.estaParcialment) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editarAlbaran(albaran),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _confirmarProcesar(albaran),
                      child: const Text('Procesar'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _nuevoAlbaran() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearAlbaranScreen(
          empresaId: widget.empresaId,
          empresaNombre: widget.empresaNombre,
        ),
      ),
    );
    
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Albarán creado exitosamente')),
      );
    }
  }

  void _verDetalles(AlbaranProveedor albaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Albarán #${albaran.numeroAlbaran}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleRow('Proveedor', albaran.proveedorNombre),
              _buildDetalleRow('Fecha Albarán', albaran.fechaAlbaran.toString().substring(0, 10)),
              _buildDetalleRow('Fecha Recepción', albaran.fechaRecepcion.toString().substring(0, 10)),
              _buildDetalleRow('Estado', albaran.estadoTexto),
              if (albaran.observaciones != null) ...[
                _buildDetalleRow('Observaciones', albaran.observaciones!),
              ],
              const Divider(),
              const Text(
                'Artículos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...albaran.lineas.map((linea) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(linea.articuloNombre),
                    ),
                    Text('${linea.cantidad} unidades'),
                    const SizedBox(width: 8),
                    Text('\$${linea.precioUnitario.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              _buildDetalleRow('Subtotal', albaran.subtotalFormateado),
              _buildDetalleRow('IVA', '${albaran.iva}%'),
              _buildDetalleRow('Total', albaran.totalFormateado),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _editarAlbaran(AlbaranProveedor albaran) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearAlbaranScreen(
          empresaId: widget.empresaId,
          empresaNombre: widget.empresaNombre,
          albaran: albaran,
        ),
      ),
    );
    
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Albarán actualizado')),
      );
    }
  }

  void _confirmarProcesar(AlbaranProveedor albaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Procesar Albarán'),
        content: Text(
          '¿Está seguro de procesar el albarán #${albaran.numeroAlbaran}? '
          'Esto actualizará el inventario con ${albaran.totalArticulos} artículos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _procesarAlbaran(albaran.id!);
            },
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }

  void _procesarAlbaran(String albaranId) async {
    try {
      await _albaranService.procesarAlbaran(widget.empresaId, albaranId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Albarán procesado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}