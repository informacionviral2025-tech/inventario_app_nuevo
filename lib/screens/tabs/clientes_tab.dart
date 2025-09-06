// lib/screens/tabs/clientes_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import 'package:intl/intl.dart';

class ClientesTab extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const ClientesTab({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _ClientesTabState createState() => _ClientesTabState();
}

class _ClientesTabState extends State<ClientesTab> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes - ${widget.empresaNombre}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar cliente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            // CORREGIDO: Cambiar StreamBuilder para usar List<Cliente>
            child: StreamBuilder<List<Cliente>>(
              stream: Provider.of<ClienteProvider>(context, listen: false)
                  .getClientesStream(widget.empresaId),
              builder: (context, AsyncSnapshot<List<Cliente>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar clientes'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay clientes'));
                }

                final clientes = snapshot.data!;
                
                // CORREGIDO: Usar acceso seguro para email
                final filteredClientes = clientes.where((cliente) =>
                  cliente.nombre.toLowerCase().contains(_searchQuery) ||
                  (cliente.email?.toLowerCase().contains(_searchQuery) ?? false)
                ).toList();

                return ListView.builder(
                  itemCount: filteredClientes.length,
                  itemBuilder: (context, index) {
                    final cliente = filteredClientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        title: Text(cliente.nombre),
                        subtitle: Text(
                            'Email: ${cliente.email ?? "No especificado"}\nTeléfono: ${cliente.telefono ?? "No especificado"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implementar edición de cliente
                          },
                        ),
                        onTap: () {
                          // Implementar navegación a detalles de cliente
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar formulario para nuevo cliente
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}