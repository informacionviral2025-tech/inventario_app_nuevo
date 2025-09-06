// lib/screens/entradas/entradas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/albaran_proveedor.dart';
import '../../services/albaran_proveedor_service.dart';
import '../albaranes/crear_albaran_screen.dart';
import 'detalle_albaran_screen.dart';

class EntradasScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const EntradasScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AlbaranProveedorService _albaranService = AlbaranProveedorService();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entradas de Mercancía'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
            Tab(icon: Icon(Icons.check_circle), text: 'Procesados'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _mostrarBusqueda,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _crearNuevoAlbaran,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlbaranesList('pendiente'),
          _buildAlbaranesList('procesado'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevoAlbaran,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Albarán'),
      ),
    );
  }

  Widget _buildAlbaranesList(String filtroEstado) {
    return StreamBuilder<List<AlbaranProveedor>>(
      stream: _albaranService.getAlbaranes(widget.empresaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final albaranes = snapshot.data ?? [];
        final filteredAlbaranes = albaranes.where((a) => a.estado == filtroEstado).toList();
        final searchedAlbaranes = _aplicarBusqueda(filteredAlbaranes);

        if (searchedAlbaranes.isEmpty) {
          return _buildEmptyState(filtroEstado);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchedAlbaranes.length,
            itemBuilder: (context, index) {
              final albaran = searchedAlbaranes[index];
              return _buildAlbaranCard(albaran);
            },
          ),
        );
      },
    );
  }

  List<AlbaranProveedor> _aplicarBusqueda(List<AlbaranProveedor> albaranes) {
    if (_searchQuery.isEmpty) return albaranes;
    
    return albaranes.where((albaran) {
      return albaran.numeroAlbaran.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             albaran.proveedorNombre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filtroEstado) {
    String mensaje;
    IconData icono;
    
    switch (filtroEstado) {
      case 'pendiente':
        mensaje = _searchQuery.isEmpty 
          ? 'No hay albaranes pendientes' 
          : 'No se encontraron albaranes pendientes';
        icono = Icons.pending_actions;
        break;
      case 'procesado':
        mensaje = _searchQuery.isEmpty 
          ? 'No hay albaranes procesados' 
          : 'No se encontraron albaranes procesados';
        icono = Icons.check_circle_outline;
        break;
      default:
        mensaje = _searchQuery.isEmpty 
          ? 'No hay albaranes' 
          : 'No se encontraron albaranes';
        icono = Icons.receipt_long;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Búsqueda: "$_searchQuery"',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _crearNuevoAlbaran,
            icon: const Icon(Icons.add),
            label: const Text('Crear Albarán'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbaranCard(AlbaranProveedor albaran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetalles(albaran),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Albarán #${albaran.numeroAlbaran}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: albaran.colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      albaran.estadoTexto,
                      style: TextStyle(
                        color: albaran.colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      albaran.proveedorNombre,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(albaran.fechaAlbaran),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.inventory, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${albaran.totalArticulos} artículos',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${albaran.totalFormateado}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (albaran.esPendiente)
                    ElevatedButton.icon(
                      onPressed: () => _procesarAlbaran(albaran.id!),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Procesar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarBusqueda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Albaranes'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por número o proveedor...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _crearNuevoAlbaran() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearAlbaranScreen(
          empresaId: widget.empresaId,
          empresaNombre: widget.empresaNombre,
        ),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Albarán creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verDetalles(AlbaranProveedor albaran) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleAlbaranScreen(
          empresaId: widget.empresaId,
          albaran: albaran,
        ),
      ),
    );
  }

  Future<void> _procesarAlbaran(String albaranId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Procesar Albarán'),
        content: const Text(
          '¿Confirmas que quieres procesar este albarán?\n\n'
          'Esto actualizará el stock de los artículos incluidos.',
        ),
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

    if (confirmar != true) return;

    try {
      await _albaranService.procesarAlbaran(widget.empresaId, albaranId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Albarán procesado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar albarán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}