// lib/screens/traspasos/traspaso_screen.dart
import 'package:flutter/material.dart';
import '../../services/traspaso_service.dart';
import 'nuevo_traspaso_screen.dart';

class TraspasoScreen extends StatefulWidget {
  final String empresaId;
  final String? obraId; // Opcional para cuando se viene desde una obra específica

  const TraspasoScreen({
    super.key, 
    required this.empresaId,
    this.obraId,
  });

  @override
  State<TraspasoScreen> createState() => _TraspasoScreenState();
}

class _TraspasoScreenState extends State<TraspasoScreen> 
    with SingleTickerProviderStateMixin {
  late final TraspasoService _traspasoService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _traspasoService = TraspasoService();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traspasos'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Traspasos', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'Albaranes', icon: Icon(Icons.receipt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTraspasos(),
          _buildAlbaranes(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoTraspasoScreen(
                empresaId: widget.empresaId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Traspaso'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildTraspasos() {
    return Column(
      children: [
        _buildEstadisticasTraspasos(),
        Expanded(
          child: _buildListaTraspasos(),
        ),
      ],
    );
  }

  Widget _buildAlbaranes() {
    return Column(
      children: [
        _buildFiltrosAlbaranes(),
        Expanded(
          child: _buildListaAlbaranes(),
        ),
      ],
    );
  }

  Widget _buildEstadisticasTraspasos() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Enviados', '0', Icons.upload, Colors.orange),
          _buildStatCard('Recibidos', '0', Icons.download, Colors.green),
          _buildStatCard('Pendientes', '0', Icons.pending, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildFiltrosAlbaranes() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Filtrar por estado',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: null,
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                DropdownMenuItem(value: 'confirmado', child: Text('Confirmados')),
                DropdownMenuItem(value: 'devuelto', child: Text('Devueltos')),
              ],
              onChanged: (value) {
                // Implementar filtro
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
    );
  }

  Widget _buildListaTraspasos() {
    // Si viene desde una obra específica, mostrar solo los traspasos de esa obra
    final entidadId = widget.obraId ?? widget.empresaId;
    final tipoEntidad = widget.obraId != null ? 'obra' : 'empresa';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _traspasoService.obtenerHistorialTraspasos(
        entidadId: entidadId,
        tipoEntidad: tipoEntidad,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay traspasos registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NuevoTraspasoScreen(
                          empresaId: widget.empresaId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear el primero'),
                ),
              ],
            ),
          );
        }

        final traspasos = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: traspasos.length,
          itemBuilder: (context, index) {
            return _buildTraspasoCard(traspasos[index]);
          },
        );
      },
    );
  }

  Widget _buildListaAlbaranes() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _traspasoService.obtenerAlbaranes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay albaranes registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final albaranes = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: albaranes.length,
          itemBuilder: (context, index) {
            return _buildAlbaranCard(albaranes[index]);
          },
        );
      },
    );
  }

  Widget _buildTraspasoCard(Map<String, dynamic> traspaso) {
    final fecha = traspaso['fecha'] as Timestamp?;
    final fechaStr = fecha?.toDate().toString().split(' ')[0] ?? 'Sin fecha';
    final estado = traspaso['estado'] ?? 'desconocido';
    final rol = traspaso['rol'] ?? 'origen';
    
    Color estadoColor;
    IconData estadoIcon;
    
    switch (estado) {
      case 'completado':
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle;
        break;
      case 'pendiente':
        estadoColor = Colors.orange;
        estadoIcon = Icons.pending;
        break;
      case 'devuelto':
        estadoColor = Colors.red;
        estadoIcon = Icons.undo;
        break;
      default:
        estadoColor = Colors.grey;
        estadoIcon = Icons.help;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor.withOpacity(0.1),
          child: Icon(estadoIcon, color: estadoColor),
        ),
        title: Row(
          children: [
            Icon(
              rol == 'origen' ? Icons.upload : Icons.download,
              size: 16,
              color: rol == 'origen' ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              rol == 'origen' ? 'Enviado' : 'Recibido',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: $fechaStr'),
            Text('Estado: ${estado.toUpperCase()}'),
            Text('Artículos: ${(traspaso['articulos'] as Map?)?.length ?? 0}'),
            if (traspaso['usuario'] != null)
              Text('Usuario: ${traspaso['usuario']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _manejarAccionTraspaso(value, traspaso),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver detalles'),
                dense: true,
              ),
            ),
            if (estado == 'completado')
              const PopupMenuItem(
                value: 'devolver',
                child: ListTile(
                  leading: Icon(Icons.undo, color: Colors.red),
                  title: Text('Devolver', style: TextStyle(color: Colors.red)),
                  dense: true,
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAlbaranCard(Map<String, dynamic> albaran) {
    final fecha = albaran['fecha'] as Timestamp?;
    final fechaStr = fecha?.toDate().toString().split(' ')[0] ?? 'Sin fecha';
    final numero = albaran['numero'] ?? 'Sin número';
    final estado = albaran['estado'] ?? 'pendiente';
    
    Color estadoColor;
    switch (estado) {
      case 'confirmado':
        estadoColor = Colors.green;
        break;
      case 'pendiente':
        estadoColor = Colors.orange;
        break;
      case 'devuelto':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor.withOpacity(0.1),
          child: Icon(Icons.receipt, color: estadoColor),
        ),
        title: Text(
          numero,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: $fechaStr'),
            Text('Estado: ${estado.toUpperCase()}'),
            if (albaran['origen'] != null)
              Text('Origen: ${albaran['origen']['nombre'] ?? 'Sin nombre'}'),
            if (albaran['destino'] != null)
              Text('Destino: ${albaran['destino']['nombre'] ?? 'Sin nombre'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _manejarAccionAlbaran(value, albaran),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver detalles'),
                dense: true,
              ),
            ),
            if (estado == 'pendiente')
              const PopupMenuItem(
                value: 'confirmar',
                child: ListTile(
                  leading: Icon(Icons.check, color: Colors.green),
                  title: Text('Confirmar recepción'),
                  dense: true,
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _manejarAccionTraspaso(String accion, Map<String, dynamic> traspaso) async {
    switch (accion) {
      case 'ver':
        _mostrarDetallesTraspaso(traspaso);
        break;
      case 'devolver':
        _confirmarDevolucionTraspaso(traspaso);
        break;
    }
  }

  void _manejarAccionAlbaran(String accion, Map<String, dynamic> albaran) async {
    switch (accion) {
      case 'ver':
        _mostrarDetallesAlbaran(albaran);
        break;
      case 'confirmar':
        _confirmarRecepcion(albaran);
        break;
    }
  }

  void _mostrarDetallesTraspaso(Map<String, dynamic> traspaso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Traspaso'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${traspaso['id']}'),
              Text('Estado: ${traspaso['estado']}'),
              Text('Usuario: ${traspaso['usuario'] ?? 'Sin usuario'}'),
              const SizedBox(height: 16),
              const Text('Artículos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...((traspaso['articulos'] as Map<String, dynamic>?) ?? {}).entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesAlbaran(Map<String, dynamic> albaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Albarán ${albaran['numero'] ?? 'Sin número'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estado: ${albaran['estado']}'),
              Text('Usuario: ${albaran['usuario'] ?? 'Sin usuario'}'),
              const SizedBox(height: 16),
              if (albaran['origen'] != null) ...[
                const Text('Origen:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  ${albaran['origen']['nombre']}'),
                const SizedBox(height: 8),
              ],
              if (albaran['destino'] != null) ...[
                const Text('Destino:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  ${albaran['destino']['nombre']}'),
                const SizedBox(height: 8),
              ],
              const Text('Artículos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...((albaran['articulos'] as Map<String, dynamic>?) ?? {}).entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarDevolucionTraspaso(Map<String, dynamic> traspaso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Devolución'),
        content: const Text(
          '¿Está seguro de devolver este traspaso? Esta acción revertirá los cambios en el stock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _traspasoService.devolverTraspaso(traspaso['id']);
                _mostrarMensaje('Traspaso devuelto correctamente', Colors.green);
              } catch (e) {
                _mostrarMensaje('Error al devolver: $e', Colors.red);
              }
            },
            child: const Text('Devolver', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmarRecepcion(Map<String, dynamic> albaran) async {
    try {
      await _traspasoService.confirmarRecepcion(albaran['id']);
      _mostrarMensaje('Recepción confirmada correctamente', Colors.green);
    } catch (e) {
      _mostrarMensaje('Error al confirmar: $e', Colors.red);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }
}