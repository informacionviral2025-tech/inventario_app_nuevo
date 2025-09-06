// lib/screens/tabs/obras_tab.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../../models/obra.dart';
import '../../services/obra_service.dart';
// CORREGIDO - Estos imports deben existir o ser creados
import '../obra/obra_list_screen.dart';
import '../obra/obra_form_screen.dart';
import '../obra/obra_detail_screen.dart';

class ObrasTab extends StatefulWidget {
  final String empresaId;

  const ObrasTab({super.key, required this.empresaId}); // CORREGIDO

  @override
  State<ObrasTab> createState() => _ObrasTabState();
}

class _ObrasTabState extends State<ObrasTab> {
  late ObraService _obraService;
  String _filtroEstado = 'todas';

  @override
  void initState() {
    super.initState();
    _obraService = ObraService(widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFiltros(),
              Expanded(
                child: _buildListaObras(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevaObra,
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Obra', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Obras',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Administra tus proyectos y su inventario',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _verTodasLasObras,
                icon: const Icon(Icons.view_list, color: Colors.white),
                tooltip: 'Ver lista completa',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEstadisticas(),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    return FutureBuilder<Map<String, int>>(
      future: _obraService.getEstadisticasObras(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return const Text('Error al cargar estadísticas', style: TextStyle(color: Colors.white));
        }
        final stats = snapshot.data ?? {'total': 0, 'activas': 0, 'pausadas': 0, 'finalizadas': 0};
        return Row(
          children: [
            _buildStatCard('${stats['total']}', 'Total', Icons.work_outline),
            const SizedBox(width: 12),
            _buildStatCard('${stats['activas']}', 'Activas', Icons.play_circle, Colors.green),
            const SizedBox(width: 12),
            _buildStatCard('${stats['pausadas']}', 'Pausadas', Icons.pause_circle, Colors.orange),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, [Color? color]) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFiltroChip('todas', 'Todas'),
            const SizedBox(width: 8),
            _buildFiltroChip('activa', 'Activas'),
            const SizedBox(width: 8),
            _buildFiltroChip('pausada', 'Pausadas'),
            const SizedBox(width: 8),
            _buildFiltroChip('finalizada', 'Finalizadas'),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String valor, String label) {
    final isSelected = _filtroEstado == valor;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue.shade700 : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroEstado = valor;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: Colors.white,
      checkmarkColor: Colors.blue.shade700,
      side: BorderSide(color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildListaObras() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StreamBuilder<List<Obra>>(
        stream: _filtroEstado == 'todas' 
            ? _obraService.getObras() 
            : _obraService.getObrasPorEstado(_filtroEstado),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final obras = snapshot.data ?? [];
          if (obras.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: obras.length,
            itemBuilder: (context, index) {
              final obra = obras[index];
              return _buildObraCard(obra);
            },
          );
        },
      ),
    );
  }

  Widget _buildObraCard(Obra obra) {
    final estadoColor = _getEstadoColor(obra.estado);
    final totalArticulos = obra.stock.length;
    final totalUnidades = obra.stock.values
        .fold<int>(0, (sum, info) => sum + (info is int ? info : 0));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _verDetalleObra(obra),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      obra.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      obra.estado.toUpperCase(),
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (obra.cliente?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(obra.cliente!, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (obra.direccion?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        obra.direccion!,
                        style: TextStyle(color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory, size: 20, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text('$totalArticulos artículos'),
                    const SizedBox(width: 16),
                    Icon(Icons.apps, size: 20, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text('$totalUnidades unidades'),
                    const Spacer(),
                    Text(
                      _formatearFecha(obra.fechaCreacion),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _verDetalleObra(obra),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver inventario'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editarObra(obra),
                    icon: const Icon(Icons.edit, size: 20),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  ),
                  IconButton(
                    onPressed: () => _mostrarMenuObra(obra),
                    icon: const Icon(Icons.more_vert, size: 20),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay obras registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primera obra para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _crearNuevaObra,
            icon: const Icon(Icons.add),
            label: const Text('Crear Primera Obra'),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return Colors.green;
      case 'pausada':
        return Colors.orange;
      case 'finalizada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  void _verDetalleObra(Obra obra) {
    if (obra.firebaseId == null || obra.firebaseId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: La obra no tiene un ID válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObraDetailScreen(
          empresaId: widget.empresaId,
          obraId: obra.firebaseId!,
        ),
      ),
    );
  }

  void _editarObra(Obra obra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObraFormScreen(
          empresaId: widget.empresaId,
          obra: obra,
        ),
      ),
    ).then((resultado) {
      if (resultado == true && mounted) {
        setState(() {});
      }
    });
  }

  void _crearNuevaObra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObraFormScreen(
          empresaId: widget.empresaId,
        ),
      ),
    ).then((resultado) {
      if (resultado == true && mounted) {
        setState(() {});
      }
    });
  }

  void _verTodasLasObras() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObraListScreen(
          empresaId: widget.empresaId,
          empresaNombre: 'Mi Empresa',
        ),
      ),
    );
  }

  void _mostrarMenuObra(Obra obra) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              obra.nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Ver inventario'),
              onTap: () {
                Navigator.pop(context);
                _verDetalleObra(obra);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar obra'),
              onTap: () {
                Navigator.pop(context);
                _editarObra(obra);
              },
            ),
            ListTile(
              leading: const Icon(Icons.change_circle),
              title: const Text('Cambiar estado'),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstadoObra(obra);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarEstadoObra(Obra obra) {
    if (obra.firebaseId == null || obra.firebaseId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: La obra no tiene un ID válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Activa'),
              onTap: () => _actualizarEstado(obra.firebaseId!, 'activa'),
            ),
            ListTile(
              leading: const Icon(Icons.pause, color: Colors.orange),
              title: const Text('Pausada'),
              onTap: () => _actualizarEstado(obra.firebaseId!, 'pausada'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: const Text('Finalizada'),
              onTap: () => _actualizarEstado(obra.firebaseId!, 'finalizada'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _actualizarEstado(String obraId, String nuevoEstado) async {
    Navigator.pop(context);
    try {
      await _obraService.cambiarEstadoObra(obraId, nuevoEstado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}