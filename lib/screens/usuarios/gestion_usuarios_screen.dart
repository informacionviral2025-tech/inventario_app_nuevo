// lib/screens/usuarios/gestion_usuarios_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GestionUsuariosScreen extends StatefulWidget {
  final String empresaId;

  const GestionUsuariosScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
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
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.purple.shade600,
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
          Expanded(child: _buildListaUsuarios()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioUsuario(context),
        backgroundColor: Colors.purple.shade600,
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
                hintText: 'Buscar usuarios...',
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

  Widget _buildListaUsuarios() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('usuarios')
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

        final usuarios = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombre = data['nombre']?.toString().toLowerCase() ?? '';
          final email = data['email']?.toString().toLowerCase() ?? '';
          return nombre.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final doc = usuarios[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildUsuarioCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildUsuarioCard(String usuarioId, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final email = data['email'] ?? '';
    final rol = data['rol'] ?? 'Usuario';
    final activo = data['activo'] ?? true;
    final ultimoAcceso = data['ultimoAcceso'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Text(
            nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
            style: TextStyle(
              color: Colors.purple.shade700,
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
            Text('📧 $email'),
            Text('👤 $rol'),
            if (ultimoAcceso != null)
              Text('🕒 Último acceso: ${_formatDate(ultimoAcceso)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activo ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: activo ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _onMenuAction(value, usuarioId, data),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'view', child: Text('Ver detalles')),
                const PopupMenuItem(value: 'permissions', child: Text('Permisos')),
                const PopupMenuItem(value: 'toggle', child: Text('Activar/Desactivar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
        onTap: () => _verDetallesUsuario(usuarioId, data),
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
            'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega el primer usuario',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _mostrarFormularioUsuario(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
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
        title: const Text('Buscar Usuarios'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nombre o email...',
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

  void _mostrarFormularioUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _UsuarioFormDialog(
        empresaId: widget.empresaId,
        onUsuarioSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _onMenuAction(String action, String usuarioId, Map<String, dynamic> data) {
    switch (action) {
      case 'edit':
        _editarUsuario(usuarioId, data);
        break;
      case 'view':
        _verDetallesUsuario(usuarioId, data);
        break;
      case 'permissions':
        _gestionarPermisos(usuarioId, data);
        break;
      case 'toggle':
        _toggleActivo(usuarioId, data);
        break;
      case 'delete':
        _eliminarUsuario(usuarioId);
        break;
    }
  }

  void _editarUsuario(String usuarioId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _UsuarioFormDialog(
        empresaId: widget.empresaId,
        usuarioId: usuarioId,
        usuarioData: data,
        onUsuarioSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _verDetallesUsuario(String usuarioId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['nombre'] ?? 'Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', data['email'] ?? 'No especificado'),
            _buildDetailRow('Rol', data['rol'] ?? 'Usuario'),
            _buildDetailRow('Estado', data['activo'] == true ? 'Activo' : 'Inactivo'),
            _buildDetailRow('Fecha registro', _formatDate(data['fechaCreacion'])),
            _buildDetailRow('Último acceso', _formatDate(data['ultimoAcceso'])),
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
            width: 100,
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

  void _gestionarPermisos(String usuarioId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar Permisos'),
        content: const Text('Esta funcionalidad permitirá gestionar los permisos específicos del usuario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _toggleActivo(String usuarioId, Map<String, dynamic> data) {
    final nuevoEstado = !(data['activo'] ?? true);
    FirebaseFirestore.instance
        .collection('empresas')
        .doc(widget.empresaId)
        .collection('usuarios')
        .doc(usuarioId)
        .update({'activo': nuevoEstado})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado ? 'Usuario activado' : 'Usuario desactivado'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _eliminarUsuario(String usuarioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: const Text('¿Estás seguro de que quieres eliminar este usuario?'),
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
                  .collection('usuarios')
                  .doc(usuarioId)
                  .delete()
                  .then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario eliminado'),
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

class _UsuarioFormDialog extends StatefulWidget {
  final String empresaId;
  final String? usuarioId;
  final Map<String, dynamic>? usuarioData;
  final VoidCallback onUsuarioSaved;

  const _UsuarioFormDialog({
    required this.empresaId,
    this.usuarioId,
    this.usuarioData,
    required this.onUsuarioSaved,
  });

  @override
  State<_UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<_UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rol = 'Usuario';
  bool _activo = true;
  bool _isLoading = false;

  final List<String> _roles = ['Administrador', 'Jefe de Almacén', 'Operario', 'Usuario'];

  @override
  void initState() {
    super.initState();
    if (widget.usuarioData != null) {
      _nombreController.text = widget.usuarioData!['nombre'] ?? '';
      _emailController.text = widget.usuarioData!['email'] ?? '';
      _rol = widget.usuarioData!['rol'] ?? 'Usuario';
      _activo = widget.usuarioData!['activo'] ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.usuarioId != null ? 'Editar Usuario' : 'Nuevo Usuario'),
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
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.usuarioId == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (widget.usuarioId == null && (value == null || value.trim().isEmpty)) {
                      return 'La contraseña es requerida';
                    }
                    if (value != null && value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((rol) {
                  return DropdownMenuItem(
                    value: rol,
                    child: Text(rol),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _rol = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                subtitle: const Text('Usuario activo en el sistema'),
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
          onPressed: _isLoading ? null : _guardarUsuario,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.usuarioId != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final usuarioData = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'rol': _rol,
        'activo': _activo,
        'fechaCreacion': widget.usuarioId != null 
            ? widget.usuarioData!['fechaCreacion']
            : Timestamp.now(),
        'fechaActualizacion': Timestamp.now(),
      };

      if (widget.usuarioId != null) {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('usuarios')
            .doc(widget.usuarioId)
            .update(usuarioData);
      } else {
        // Crear usuario en Firebase Auth
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Guardar datos adicionales en Firestore
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('usuarios')
            .doc(credential.user!.uid)
            .set(usuarioData);
      }

      widget.onUsuarioSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.usuarioId != null 
              ? 'Usuario actualizado' 
              : 'Usuario creado'),
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
