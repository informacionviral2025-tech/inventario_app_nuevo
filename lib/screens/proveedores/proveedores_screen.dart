// lib/screens/proveedores/proveedores_screen.dart
import 'package:flutter/material.dart';
import '../../services/proveedor_service.dart';
import '../../models/proveedor.dart';
import 'gestion_proveedores_screen.dart';

class ProveedoresScreen extends StatefulWidget {
  final String empresaId;

  const ProveedoresScreen({
    super.key, 
    required this.empresaId,
  });

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  late final ProveedorService _proveedorService;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _proveedorService = ProveedorService(widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _mostrarBusqueda,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GestionProveedoresScreen(
                    empresaId: widget.empresaId,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEstadisticas(),
          Expanded(
            child: _buildListaProveedores(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GestionProveedoresScreen(
                empresaId: widget.empresaId,
              ),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _mostrarBusqueda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Proveedores'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre, email, teléfono...',
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

  Widget _buildEstadisticas() {
    return FutureBuilder<Map<String, int>>(
      future: _proveedorService.obtenerEstadisticas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 80);
        }

        final stats = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total',
                '${stats['total']}',
                Icons.business,
                Colors.blue,
              ),
              _buildStatCard(
                'Activos',
                '${stats['activos']}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Inactivos',
                '${stats['inactivos']}',
                Icons.block,
                Colors.red,
              ),
            ],
          ),
        );
      },
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

  Widget _buildListaProveedores() {
    return StreamBuilder<List<Proveedor>>(
      stream: _proveedorService.getProveedoresActivos(),
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
                  Icons.business,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay proveedores activos',
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
                        builder: (context) => GestionProveedoresScreen(
                          empresaId: widget.empresaId,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Proveedor'),
                ),
              ],
            ),
          );
        }

        final proveedores = snapshot.data!;
        final proveedoresFiltrados = _searchQuery.isEmpty 
          ? proveedores 
          : proveedores.where((proveedor) {
              return proveedor.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     (proveedor.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                     (proveedor.telefono?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
            }).toList();
        
        if (proveedoresFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron proveedores',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Búsqueda: "$_searchQuery"',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: proveedoresFiltrados.length,
          itemBuilder: (context, index) {
            final proveedor = proveedoresFiltrados[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.business,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: Text(
                  proveedor.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (proveedor.email != null)
                      Text(
                        proveedor.email!,
                        style: TextStyle(color: Colors.blue.shade600),
                      ),
                    if (proveedor.telefono != null)
                      Text('Tel: ${proveedor.telefono}'),
                    if (proveedor.contacto != null)
                      Text('Contacto: ${proveedor.contacto}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _mostrarDetalleProveedor(proveedor);
                },
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalleProveedor(Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(proveedor.nombre),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (proveedor.rfc != null) ...[
                const Text('RFC:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(proveedor.rfc!),
                const SizedBox(height: 8),
              ],
              if (proveedor.email != null) ...[
                const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(proveedor.email!),
                const SizedBox(height: 8),
              ],
              if (proveedor.telefono != null) ...[
                const Text('Teléfono:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(proveedor.telefono!),
                const SizedBox(height: 8),
              ],
              if (proveedor.direccion != null) ...[
                const Text('Dirección:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(proveedor.direccion!),
                const SizedBox(height: 8),
              ],
              if (proveedor.contacto != null) ...[
                const Text('Contacto:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(proveedor.contacto!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GestionProveedoresScreen(
                    empresaId: widget.empresaId,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
            child: const Text('Gestionar'),
          ),
        ],
      ),
    );
  }
}