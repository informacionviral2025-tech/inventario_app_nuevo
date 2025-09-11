// lib/screens/clientes/clientes_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesScreen extends StatefulWidget {
  final String empresaId;

  const ClientesScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _mostrarBusqueda,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(child: _buildListaClientes()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCliente(context),
        backgroundColor: Colors.pink.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Activos'),
            selected: true,
            onSelected: (selected) {
              // TODO: Implementar filtro de activos
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListaClientes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('clientes')
          .orderBy('nombre')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final clientes = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombre = data['nombre']?.toString().toLowerCase() ?? '';
          return nombre.contains(_searchQuery);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clientes.length,
          itemBuilder: (context, index) {
            final doc = clientes[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildClienteCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildClienteCard(String clienteId, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final email = data['email'] ?? '';
    final telefono = data['telefono'] ?? '';
    final direccion = data['direccion'] ?? '';
    final activo = data['activo'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: Text(
            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C',
            style: TextStyle(
              color: Colors.pink.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty) Text('📧 $email'),
            if (telefono.isNotEmpty) Text('📞 $telefono'),
            if (direccion.isNotEmpty) Text('📍 $direccion'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!activo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactivo',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _onMenuAction(value, clienteId, data),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'view', child: Text('Ver detalles')),
                const PopupMenuItem(value: 'toggle', child: Text('Activar/Desactivar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
        onTap: () => _verDetallesCliente(clienteId, data),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay clientes registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer cliente',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _mostrarFormularioCliente(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarBusqueda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Clientes'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nombre, email o teléfono...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
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

  void _mostrarFormularioCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ClienteFormDialog(
        empresaId: widget.empresaId,
        onClienteSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _onMenuAction(String action, String clienteId, Map<String, dynamic> data) {
    switch (action) {
      case 'edit':
        _editarCliente(clienteId, data);
        break;
      case 'view':
        _verDetallesCliente(clienteId, data);
        break;
      case 'toggle':
        _toggleActivo(clienteId, data);
        break;
      case 'delete':
        _eliminarCliente(clienteId);
        break;
    }
  }

  void _editarCliente(String clienteId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _ClienteFormDialog(
        empresaId: widget.empresaId,
        clienteId: clienteId,
        clienteData: data,
        onClienteSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _verDetallesCliente(String clienteId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['nombre'] ?? 'Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', data['email'] ?? 'No especificado'),
            _buildDetailRow('Teléfono', data['telefono'] ?? 'No especificado'),
            _buildDetailRow('Dirección', data['direccion'] ?? 'No especificada'),
            _buildDetailRow('Estado', data['activo'] == true ? 'Activo' : 'Inactivo'),
            _buildDetailRow('Fecha registro', _formatDate(data['fechaCreacion'])),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'No especificada';
    if (timestamp is Timestamp) {
      return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
    }
    return 'No especificada';
  }

  void _toggleActivo(String clienteId, Map<String, dynamic> data) {
    final nuevoEstado = !(data['activo'] ?? true);
    FirebaseFirestore.instance
        .collection('empresas')
        .doc(widget.empresaId)
        .collection('clientes')
        .doc(clienteId)
        .update({'activo': nuevoEstado})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado ? 'Cliente activado' : 'Cliente desactivado'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _eliminarCliente(String clienteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: const Text('¿Estás seguro de que quieres eliminar este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('empresas')
                  .doc(widget.empresaId)
                  .collection('clientes')
                  .doc(clienteId)
                  .delete()
                  .then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cliente eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ClienteFormDialog extends StatefulWidget {
  final String empresaId;
  final String? clienteId;
  final Map<String, dynamic>? clienteData;
  final VoidCallback onClienteSaved;

  const _ClienteFormDialog({
    required this.empresaId,
    this.clienteId,
    this.clienteData,
    required this.onClienteSaved,
  });

  @override
  State<_ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<_ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _activo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.clienteData != null) {
      _nombreController.text = widget.clienteData!['nombre'] ?? '';
      _emailController.text = widget.clienteData!['email'] ?? '';
      _telefonoController.text = widget.clienteData!['telefono'] ?? '';
      _direccionController.text = widget.clienteData!['direccion'] ?? '';
      _activo = widget.clienteData!['activo'] ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.clienteId != null ? 'Editar Cliente' : 'Nuevo Cliente'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                subtitle: const Text('Cliente activo en el sistema'),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarCliente,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.clienteId != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final clienteData = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'activo': _activo,
        'fechaCreacion': widget.clienteId != null 
            ? widget.clienteData!['fechaCreacion']
            : Timestamp.now(),
        'fechaActualizacion': Timestamp.now(),
      };

      if (widget.clienteId != null) {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('clientes')
            .doc(widget.clienteId)
            .update(clienteData);
      } else {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('clientes')
            .add(clienteData);
      }

      widget.onClienteSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.clienteId != null 
              ? 'Cliente actualizado' 
              : 'Cliente creado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
