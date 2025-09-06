// lib/screens/obra/obra_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/obra.dart';
import '../../services/obra_service.dart';

class ObraFormScreen extends StatefulWidget {
  final String empresaId;
  final Obra? obra;

  const ObraFormScreen({
    Key? key,
    required this.empresaId,
    this.obra,
  }) : super(key: key);

  @override
  State<ObraFormScreen> createState() => _ObraFormScreenState();
}

class _ObraFormScreenState extends State<ObraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ObraService _obraService;
  
  final _nombreController = TextEditingController();
  final _codigoObraController = TextEditingController(); // AÑADIDO
  final _clienteController = TextEditingController();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _responsableController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _presupuestoController = TextEditingController();
  
  String _estadoSeleccionado = 'activa';
  DateTime? _fechaInicio;
  DateTime? _fechaFinPrevista;
  bool _isLoading = false;

  final List<String> _estadosDisponibles = ['activa', 'pausada', 'finalizada'];

  @override
  void initState() {
    super.initState();
    _obraService = ObraService(widget.empresaId);
    _inicializarFormulario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoObraController.dispose(); // AÑADIDO
    _clienteController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    _responsableController.dispose();
    _telefonoController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }

  void _inicializarFormulario() {
    if (widget.obra != null) {
      final obra = widget.obra!;
      _nombreController.text = obra.nombre;
      _codigoObraController.text = obra.codigoObra ?? ''; // AÑADIDO
      _clienteController.text = obra.cliente ?? '';
      _direccionController.text = obra.direccion ?? '';
      _descripcionController.text = obra.descripcion ?? '';
      _responsableController.text = obra.responsable ?? '';
      _telefonoController.text = obra.telefono ?? '';
      _presupuestoController.text = obra.presupuesto?.toStringAsFixed(2) ?? '';
      _estadoSeleccionado = obra.estado;
      _fechaInicio = obra.fechaInicio;
      _fechaFinPrevista = obra.fechaFinPrevista;
    } else {
      _fechaInicio = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.obra != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Obra' : 'Nueva Obra'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _mostrarMenuAcciones,
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                'Información Básica',
                Icons.info,
                [
                  _buildTextField(
                    controller: _codigoObraController, // AÑADIDO
                    label: 'Código de la obra',
                    icon: Icons.code,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre de la obra',
                    icon: Icons.work,
                    required: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _clienteController,
                    label: 'Cliente',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                'Contacto y Gestión',
                Icons.contact_phone,
                [
                  _buildTextField(
                    controller: _responsableController,
                    label: 'Responsable',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _presupuestoController,
                    label: 'Presupuesto (€)',
                    icon: Icons.euro,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Introduce un número válido';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                'Planificación',
                Icons.calendar_today,
                [
                  _buildEstadoSelector(),
                  const SizedBox(height: 16),
                  _buildFechaSelector(
                    label: 'Fecha de inicio',
                    fecha: _fechaInicio,
                    onChanged: (fecha) => setState(() => _fechaInicio = fecha),
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildFechaSelector(
                    label: 'Fecha fin prevista (opcional)',
                    fecha: _fechaFinPrevista,
                    onChanged: (fecha) => setState(() => _fechaFinPrevista = fecha),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarObra,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(isEditing ? 'Guardar Cambios' : 'Crear Obra'),
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildEstadoSelector() {
    return DropdownButtonFormField<String>(
      value: _estadoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Estado de la obra',
        prefixIcon: const Icon(Icons.flag),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _estadosDisponibles.map((estado) {
        return DropdownMenuItem(
          value: estado,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEstadoColor(estado),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(estado.toUpperCase()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _estadoSeleccionado = value);
        }
      },
    );
  }

  Widget _buildFechaSelector({
    required String label,
    required DateTime? fecha,
    required Function(DateTime?) onChanged,
    bool required = false,
  }) {
    return InkWell(
      onTap: () => _seleccionarFecha(fecha, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
          errorText: required && fecha == null ? 'La fecha es obligatoria' : null,
        ),
        child: Text(
          fecha != null ? _formatearFecha(fecha) : 'Seleccionar fecha',
          style: TextStyle(
            color: fecha != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.green;
      case 'pausada':
        return Colors.orange;
      case 'finalizada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> _seleccionarFecha(DateTime? fechaActual, Function(DateTime?) onChanged) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaActual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es'),
    );
    
    if (fecha != null) {
      onChanged(fecha);
    }
  }

  Future<void> _guardarObra() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null) {
      _mostrarMensaje('La fecha de inicio es obligatoria', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final obra = Obra(
        id: widget.obra?.id ?? '',
        firebaseId: widget.obra?.firebaseId,
        codigoObra: _codigoObraController.text.trim().isEmpty ? null : _codigoObraController.text.trim(), // AÑADIDO
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
        empresaId: widget.empresaId,
        fechaCreacion: widget.obra?.fechaCreacion ?? DateTime.now(),
        estado: _estadoSeleccionado,
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        responsable: _responsableController.text.trim().isEmpty ? null : _responsableController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        presupuesto: _presupuestoController.text.trim().isEmpty ? null : double.tryParse(_presupuestoController.text.trim()),
        cliente: _clienteController.text.trim().isEmpty ? null : _clienteController.text.trim(),
        fechaInicio: _fechaInicio,
        fechaFinPrevista: _fechaFinPrevista,
        stock: widget.obra?.stock ?? {},
      );

      if (widget.obra != null) {
        await _obraService.actualizarObra(obra);
        _mostrarMensaje('Obra actualizada correctamente', isError: false);
      } else {
        await _obraService.crearObra(obra);
        _mostrarMensaje('Obra creada correctamente', isError: false);
      }

      Navigator.pop(context, true);

    } catch (e) {
      _mostrarMensaje('Error al guardar: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarMenuAcciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar obra'),
              onTap: () {
                Navigator.pop(context);
                _duplicarObra();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade600),
              title: Text(
                'Eliminar obra',
                style: TextStyle(color: Colors.red.shade600),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _duplicarObra() async {
    if (widget.obra == null) return;

    setState(() => _isLoading = true);

    try {
      final nuevaObra = widget.obra!.copyWith(
        id: '',
        firebaseId: null,
        codigoObra: widget.obra!.codigoObra != null ? '${widget.obra!.codigoObra}-Copia' : null, // AÑADIDO
        nombre: '${widget.obra!.nombre} (Copia)',
        fechaCreacion: DateTime.now(),
        fechaInicio: DateTime.now(),
        fechaFinPrevista: widget.obra!.fechaFinPrevista,
        estado: 'activa',
      );
      await _obraService.crearObra(nuevaObra);
      _mostrarMensaje('Obra duplicada correctamente', isError: false);
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensaje('Error al duplicar: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Obra'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${widget.obra?.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _eliminarObra,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarObra() async {
    Navigator.pop(context);
    
    setState(() => _isLoading = true);
    
    try {
      await _obraService.eliminarObra(widget.obra!.firebaseId!);
      _mostrarMensaje('Obra eliminada correctamente', isError: false);
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensaje('Error al eliminar: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
