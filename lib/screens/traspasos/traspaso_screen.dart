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

  // --- Métodos de construcción de UI ---
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

  // Lista de traspasos
  Widget _buildListaTraspasos() {
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
}

// --- Tarjetas ---
Widget _buildTraspasoCard(Map<String, dynamic> traspaso) {
  return Card(
    child: ListTile(
      title: Text(traspaso['descripcion'] ?? 'Sin descripción'),
      subtitle: Text('Cantidad: ${traspaso['cantidad'] ?? 0}'),
      trailing: const Icon(Icons.swap_horiz),
    ),
  );
}

Widget _buildAlbaranCard(Map<String, dynamic> albaran) {
  return Card(
    child: ListTile(
      title: Text(albaran['descripcion'] ?? 'Sin descripción'),
      subtitle: Text('Proveedor: ${albaran['proveedor'] ?? 'N/A'}'),
      trailing: const Icon(Icons.receipt),
    ),
  );
}
