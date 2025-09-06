import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proveedor.dart';
import '../services/proveedor_service.dart';

class AddSupplierScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final Proveedor? proveedorExistente;

  const AddSupplierScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    this.proveedorExistente,
  }) : super(key: key);

  bool get isEditing => proveedorExistente != null;

  @override
  _AddSupplierScreenState createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProveedorService _proveedorService;
  
  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _rfcController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  late TextEditingController _contactoController;
  late TextEditingController _notasController;

  bool _isLoading = false;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    _proveedorService = ProveedorService(widget.empresaId);
    _initControllers();
    _loadExistingData();
  }

  void _initControllers() {
    _nombreController = TextEditingController();
    _rfcController = TextEditingController();
    _telefonoController = TextEditingController();
    _emailController = TextEditingController();
    _direccionController = TextEditingController();
    _contactoController = TextEditingController();
    _notasController = TextEditingController();
  }

  void _loadExistingData() {
    if (widget.isEditing && widget.proveedorExistente != null) {
      final proveedor = widget.proveedorExistente!;
      _nombreController.text = proveedor.nombre;
      _rfcController.text = proveedor.rfc ?? '';
      _telefonoController.text = proveedor.telefono ?? '';
      _emailController.text = proveedor.email ?? '';
      _direccionController.text = proveedor.direccion ?? '';
      _contactoController.text = proveedor.contacto ?? '';
      _notasController.text = proveedor.notas ?? '';
      _activo = proveedor.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _contactoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Modificar Proveedor' : 'Agregar Nuevo Proveedor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.empresaNombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Información básica
              _buildSectionCard(
                'Información Básica',
                Icons.info,
                Colors.blue,
                [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre del proveedor *',
                    hint: 'Ej: Construcciones García S.L.',
                    icon: Icons.business,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      if (value.trim().length < 2) {
                        return 'Mínimo 2 caracteres';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),

                  _buildTextField(
                    controller: _rfcController,
                    label: 'RFC/CIF',
                    hint: 'Ej: A12345674 o 12345678Z',
                    icon: Icons.badge,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Validación básica de RFC/CIF español
                        final rfc = value.trim().toUpperCase();
                        if (rfc.length < 8 || rfc.length > 12) {
                          return 'RFC/CIF debe tener entre 8 y 12 caracteres';
                        }
                      }
                      return null;
                    },
                  ),

                  _buildTextField(
                    controller: _contactoController,
                    label: 'Persona de contacto',
                    hint: 'Ej: Juan Pérez',
                    icon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información de contacto
              _buildSectionCard(
                'Información de Contacto',
                Icons.contact_phone,
                Colors.green,
                [
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    hint: 'Ej: +34 600 123 456',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Validación básica de teléfono
                        final phone = value.trim().replaceAll(RegExp(r'[^\d+]'), '');
                        if (phone.length < 9) {
                          return 'Teléfono debe tener al menos 9 dígitos';
                        }
                      }
                      return null;
                    },
                  ),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Ej: contacto@proveedor.com',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Validación básica de email
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Email no válido';
                        }
                      }
                      return null;
                    },
                  ),

                  _buildTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                    hint: 'Ej: Calle Mayor 123, Madrid',
                    icon: Icons.location_on,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notas adicionales
              _buildSectionCard(
                'Información Adicional',
                Icons.notes,
                Colors.orange,
                [
                  _buildTextField(
                    controller: _notasController,
                    label: 'Notas',
                    hint: 'Condiciones especiales, horarios, etc.',
                    icon: Icons.note_alt,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  // Switch para estado activo
                  SwitchListTile(
                    title: const Text('Proveedor activo'),
                    subtitle: Text(_activo 
                        ? 'Este proveedor está disponible para selección' 
                        : 'Este proveedor no aparecerá en las listas'),
                    value: _activo,
                    onChanged: (value) {
                      setState(() {
                        _activo = value;
                      });
                    },
                    activeColor: Colors.blue.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _guardarProveedor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(widget.isEditing ? Icons.save : Icons.add),
                  label: Text(
                    _isLoading 
                        ? (widget.isEditing ? 'Actualizando...' : 'Guardando...')
                        : (widget.isEditing ? 'Actualizar Proveedor' : 'Guardar Proveedor'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String titulo, IconData icono, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
      ),
    );
  }

  Future<void> _guardarProveedor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final proveedor = Proveedor(
        id: widget.isEditing ? widget.proveedorExistente!.id : '',
        nombre: _nombreController.text.trim(),
        rfc: _rfcController.text.trim().isEmpty ? null : _rfcController.text.trim().toUpperCase(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim().toLowerCase(),
        direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
        contacto: _contactoController.text.trim().isEmpty ? null : _contactoController.text.trim(),
        notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
        fechaCreacion: widget.isEditing ? widget.proveedorExistente!.fechaCreacion : DateTime.now(),
        activo: _activo,
      );

      if (widget.isEditing) {
        await _proveedorService.actualizarProveedor(proveedor);
      } else {
        await _proveedorService.agregarProveedor(proveedor);
      }

      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing 
                ? '✅ Proveedor actualizado exitosamente'
                : '✅ Proveedor agregado exitosamente',
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}