// lib/screens/obra/obra_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/obra.dart';
import '../../services/obra_service.dart';
import '../albaranes/lista_albaranes_screen.dart';
import '../articulos/articulos_por_obra_screen.dart';
import '../tareas/tareas_obra_screen.dart';
import 'editar_obra_screen.dart';

class ObraDetailScreen extends StatefulWidget {
  final String empresaId;
  final String obraId;

  const ObraDetailScreen({
    Key? key,
    required this.empresaId,
    required this.obraId,
  }) : super(key: key);

  @override
  State<ObraDetailScreen> createState() => _ObraDetailScreenState();
}

class _ObraDetailScreenState extends State<ObraDetailScreen> {
  late final ObraService _obraService; // Cambiado a late
  Obra? _obra;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obraService = ObraService(widget.empresaId); // Inicializado en initState
    _loadObra();
  }

  Future<void> _loadObra() async {
    try {
      final obra = await _obraService.getObra(widget.obraId);
      if (mounted) {
        setState(() {
          _obra = obra;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar obra: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_obra == null) {
      return const Scaffold(
        body: Center(child: Text('Obra no encontrada')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_obra!.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarObra,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _mostrarConfirmacionEliminar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Obra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Código:', _obra!.codigoObra ?? 'No especificado'),
            _buildInfoRow('Nombre:', _obra!.nombre),
            _buildInfoRow('Cliente:', _obra!.cliente ?? 'No especificado'),
            _buildInfoRow('Estado:', _obra!.estado),
            if (_obra!.fechaInicio != null)
              _buildInfoRow('Fecha Inicio:', _formatDate(_obra!.fechaInicio!)),
            if (_obra!.fechaFin != null)
              _buildInfoRow('Fecha Fin:', _formatDate(_obra!.fechaFin!)),
            if (_obra!.fechaFinPrevista != null)
              _buildInfoRow('Fecha Fin Prevista:', _formatDate(_obra!.fechaFinPrevista!)),
            _buildInfoRow('Presupuesto:', '€${(_obra!.presupuesto ?? 0.0).toStringAsFixed(2)}'), // Cambiado a € para consistencia
            if (_obra!.descripcion != null)
              _buildInfoRow('Descripción:', _obra!.descripcion!),
            if (_obra!.direccion != null)
              _buildInfoRow('Dirección:', _obra!.direccion!),
            if (_obra!.telefono != null)
              _buildInfoRow('Teléfono:', _obra!.telefono!),
            if (_obra!.responsable != null)
              _buildInfoRow('Responsable:', _obra!.responsable!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _obraService.getEstadisticasObra(widget.empresaId, widget.obraId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final stats = snapshot.data ?? {};
                return Column(
                  children: [
                    _buildStatRow('Tareas Completadas:', '${stats['tareasCompletadas'] ?? 0}/${stats['totalTareas'] ?? 0}'),
                    _buildStatRow('Materiales Usados:', '${stats['materialesUsados'] ?? 0}'),
                    _buildStatRow('Coste Total:', '€${stats['costeTotal']?.toStringAsFixed(2) ?? '0.00'}'), // Cambiado a €
                    _buildStatRow('Horas Trabajadas:', '${stats['horasTrabajadas'] ?? 0} h'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navegarAListaAlbaranes(),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Ver Albaranes'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navegarAArticulos(),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Ver Materiales'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navegarATareas(),
                  icon: const Icon(Icons.task),
                  label: const Text('Ver Tareas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _editarObra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarObraScreen(
          empresaId: widget.empresaId,
          obra: _obra!,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() => _loadObra());
      }
    });
  }

  void _mostrarConfirmacionEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Obra'),
        content: Text('¿Estás seguro de que deseas eliminar la obra "${_obra!.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _obraService.eliminarObra(widget.obraId);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Obra eliminada correctamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navegarAListaAlbaranes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaAlbaranesScreen(
          empresaId: widget.empresaId,
          empresaNombre: _obra!.nombre,
        ),
      ),
    );
  }

  void _navegarAArticulos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticulosPorObraScreen(
          empresaId: widget.empresaId,
          obraId: widget.obraId,
          obraNombre: _obra!.nombre,
        ),
      ),
    );
  }

  void _navegarATareas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TareasObraScreen(
          empresaId: widget.empresaId,
          obraId: widget.obraId,
          obraNombre: _obra!.nombre,
        ),
      ),
    );
  }
}
