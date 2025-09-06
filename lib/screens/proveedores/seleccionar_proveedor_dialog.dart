import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProveedorSelectionDialog extends StatefulWidget {
  final String empresaId;

  const ProveedorSelectionDialog({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  _ProveedorSelectionDialogState createState() => _ProveedorSelectionDialogState();
}

class _ProveedorSelectionDialogState extends State<ProveedorSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Seleccionar Proveedor',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proveedores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildProveedoresList(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedoresList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('proveedores')
          .where('activo', isEqualTo: true)
          .orderBy('nombre')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No hay proveedores disponibles'),
          );
        }

        final proveedores = snapshot.data!.docs;
        final filteredProveedores = _searchQuery.isEmpty
            ? proveedores
            : proveedores.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = data['nombre']?.toString().toLowerCase() ?? '';
                final email = data['email']?.toString().toLowerCase() ?? '';
                final rfc = data['rfc']?.toString().toLowerCase() ?? '';
                
                return nombre.contains(_searchQuery) ||
                       email.contains(_searchQuery) ||
                       rfc.contains(_searchQuery);
              }).toList();

        if (filteredProveedores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron proveedores',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Búsqueda: "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredProveedores.length,
          itemBuilder: (context, index) {
            final doc = filteredProveedores[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.business),
              ),
              title: Text(data['nombre'] ?? 'Sin nombre'),
              subtitle: Text(data['email'] ?? ''),
              onTap: () {
                Navigator.pop(context, {
                  'id': doc.id,
                  'nombre': data['nombre'] ?? 'Sin nombre',
                });
              },
            );
          },
        );
      },
    );
  }
}