// lib/screens/proveedores/gestion_proveedores_screen.dart
import 'package:flutter/material.dart';
import '../../models/proveedor.dart';
import '../../services/proveedor_service.dart';

class GestionProveedoresScreen extends StatefulWidget {
  final String empresaId;

  const GestionProveedoresScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<GestionProveedoresScreen> createState() => _GestionProveedoresScreenState();
}

class _GestionProveedoresScreenState extends State<GestionProveedoresScreen> {
  late final ProveedorService _proveedorService;
  String _filtroTexto = '';
  bool _soloActivos = true;

  @override
  void initState() {
    super.initState();
    _proveedorService = ProveedorService(widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
        backgroundColor: Colors.blue.shade600,
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
          Expanded(
            child: _buildListaProveedores(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioProveedor(context),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar proveedores...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _filtroTexto = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Solo activos'),
            selected: _soloActivos,
            onSelected: (selected) {
              setState(() => _soloActivos = selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListaProveedores() {
    return StreamBuilder<List<Proveedor>>(
      stream: _soloActivos
          ? _proveedorService.getProveedoresActivos()
          : _proveedorService.getProveedores(),
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
                  'No hay proveedores',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _mostrarFormularioProveedor(context),
                  child: const Text('Agregar el primero'),
                ),
              ],
            ),
          );
        }

        var proveedores = snapshot.data!;

        // Filtrar por texto de búsqueda
        if (_filtroTexto.isNotEmpty) {
          proveedores = proveedores.where((proveedor) {
            return proveedor.nombre.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
                   (proveedor.rfc?.toLowerCase().contains(_filtroTexto.toLowerCase()) ?? false) ||
                   (proveedor.email?.toLowerCase().contains(_filtroTexto.toLowerCase()) ?? false);
          }).toList();
        }

        if (proveedores.isEmpty) {
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
                const Text(
                  'No se encontraron proveedores',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: proveedores.length,
          itemBuilder: (context, index) {
            return _buildProveedorCard(proveedores[index]);
          },
        );
      },
    );
  }

  Widget _buildProveedorCard(Proveedor proveedor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: proveedor.activo ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            Icons.business,
            color: proveedor.activo ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        title: Text(
          proveedor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (proveedor.rfc != null) Text('RFC: ${proveedor.rfc}'),
            if (proveedor.email != null) 
              Text(
                proveedor.email!,
                style: TextStyle(color: Colors.blue.shade600),
              ),
            if (proveedor.telefono != null) Text('Tel: ${proveedor.telefono}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _manejarAccionProveedor(value, proveedor),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: proveedor.activo ? 'desactivar' : 'activar',
              child: ListTile(
                leading: Icon(proveedor.activo ? Icons.block : Icons.check_circle),
                title: Text(proveedor.activo ? 'Desactivar' : 'Activar'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _mostrarBusqueda() {
    // Implementación temporal - puedes crear la clase ProveedorSearchDelegate después
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Búsqueda'),
        content: const Text('Funcionalidad de búsqueda avanzada en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _manejarAccionProveedor(String accion, Proveedor proveedor) async {
    switch (accion) {
      case 'editar':
        _mostrarFormularioProveedor(context, proveedor: proveedor);
        break;
      case 'activar':
      case 'desactivar':
        await _cambiarEstadoProveedor(proveedor);
        break;
      case 'eliminar':
        _confirmarEliminacion(proveedor);
        break;
    }
  }

  Future<void> _cambiarEstadoProveedor(Proveedor proveedor) async {
    try {
      await _proveedorService.cambiarEstadoProveedor(proveedor.id!, !proveedor.activo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Proveedor ${!proveedor.activo ? 'activado' : 'desactivado'} correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarEliminacion(Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar a ${proveedor.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _proveedorService.eliminarProveedor(proveedor.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proveedor eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioProveedor(BuildContext context, {Proveedor? proveedor}) {
    showDialog(
      context: context,
      builder: (context) => _FormularioProveedorDialog(
        proveedorService: _proveedorService,
        proveedor: proveedor,
      ),
    );
  }
}

class _FormularioProveedorDialog extends StatefulWidget {
  final ProveedorService proveedorService;
  final Proveedor? proveedor;

  const _FormularioProveedorDialog({
    required this.proveedorService,
    this.proveedor,
  });

  @override
  State<_FormularioProveedorDialog> createState() => _FormularioProveedorDialogState();
}

class _FormularioProveedorDialogState extends State<_FormularioProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _rfcController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _direccionController;
  late final TextEditingController _contactoController;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    final proveedor = widget.proveedor;
    _nombreController = TextEditingController(text: proveedor?.nombre ?? '');
    _rfcController = TextEditingController(text: proveedor?.rfc ?? '');
    _emailController = TextEditingController(text: proveedor?.email ?? '');
    _telefonoController = TextEditingController(text: proveedor?.telefono ?? '');
    _direccionController = TextEditingController(text: proveedor?.direccion ?? '');
    _contactoController = TextEditingController(text: proveedor?.contacto ?? '');
    _activo = proveedor?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.proveedor == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rfcController,
                  decoration: const InputDecoration(
                    labelText: 'RFC',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 12 || value.length > 13) {
                        return 'El RFC debe tener 12 o 13 caracteres';
                      }
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
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email inválido';
                      }
                    }
                    return null;
                  },
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
                TextFormField(
                  controller: _contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Persona de contacto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Activo'),
                  value: _activo,
                  onChanged: (value) {
                    setState(() => _activo = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardarProveedor,
          child: Text(widget.proveedor == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _guardarProveedor() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Verificar RFC único si se proporciona
      if (_rfcController.text.isNotEmpty) {
        final rfcExiste = await widget.proveedorService.existeProveedorConRFC(
          _rfcController.text,
          excluirId: widget.proveedor?.id,
        );
        
        if (rfcExiste) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe un proveedor con ese RFC'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final proveedor = Proveedor(
        id: widget.proveedor?.id,
        nombre: _nombreController.text.trim(),
        rfc: _rfcController.text.trim().isEmpty ? null : _rfcController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
        contacto: _contactoController.text.trim().isEmpty ? null : _contactoController.text.trim(),
        activo: _activo,
        fechaCreacion: widget.proveedor?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.proveedor == null) {
        await widget.proveedorService.agregarProveedor(proveedor);
      } else {
        await widget.proveedorService.actualizarProveedor(proveedor);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.proveedor == null 
                ? 'Proveedor creado correctamente'
                : 'Proveedor actualizado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}