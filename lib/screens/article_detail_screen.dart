import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/proveedor.dart';
import '../services/proveedor_service.dart';
import 'add_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final Proveedor proveedor;

  const SupplierDetailScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    required this.proveedor,
  }) : super(key: key);

  @override
  _SupplierDetailScreenState createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late final ProveedorService _proveedorService;

  @override
  void initState() {
    super.initState();
    _proveedorService = ProveedorService(widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detalles del Proveedor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  _editarProveedor();
                  break;
                case 'toggle_status':
                  _toggleEstadoProveedor();
                  break;
                case 'delete':
                  _confirmarEliminar();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      widget.proveedor.activo ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.proveedor.activo ? 'Desactivar' : 'Activar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con información principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Avatar grande
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        widget.proveedor.nombre.isNotEmpty 
                            ? widget.proveedor.nombre.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.proveedor.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (widget.proveedor.rfc != null && widget.proveedor.rfc!.isNotEmpty)
                    Text(
                      'RFC/CIF: ${widget.proveedor.rfc}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.proveedor.activo 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.proveedor.activo ? Icons.check_circle : Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.proveedor.activo ? 'ACTIVO' : 'INACTIVO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Información de contacto
                  _buildInfoCard(
                    'Información de Contacto',
                    Icons.contact_phone,
                    Colors.green,
                    [
                      if (widget.proveedor.contacto != null && widget.proveedor.contacto!.isNotEmpty)
                        _buildInfoRow(
                          'Persona de contacto',
                          widget.proveedor.contacto!,
                          Icons.person,
                          onTap: () => _copyToClipboard(widget.proveedor.contacto!, 'Contacto copiado'),
                        ),
                      if (widget.proveedor.telefono != null && widget.proveedor.telefono!.isNotEmpty)
                        _buildInfoRow(
                          'Teléfono',
                          widget.proveedor.telefono!,
                          Icons.phone,
                          onTap: () => _launchPhone(widget.proveedor.telefono!),
                        ),
                      if (widget.proveedor.email != null && widget.proveedor.email!.isNotEmpty)
                        _buildInfoRow(
                          'Email',
                          widget.proveedor.email!,
                          Icons.email,
                          onTap: () => _launchEmail(widget.proveedor.email!),
                        ),
                      if (widget.proveedor.direccion != null && widget.proveedor.direccion!.isNotEmpty)
                        _buildInfoRow(
                          'Dirección',
                          widget.proveedor.direccion!,
                          Icons.location_on,
                          onTap: () => _copyToClipboard(widget.proveedor.direccion!, 'Dirección copiada'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información adicional
                  if (widget.proveedor.notas != null && widget.proveedor.notas!.isNotEmpty)
                    _buildInfoCard(
                      'Notas',
                      Icons.notes,
                      Colors.orange,
                      [
                        _buildInfoRow(
                          'Observaciones',
                          widget.proveedor.notas!,
                          Icons.note_alt,
                          maxLines: null,
                          onTap: () => _copyToClipboard(widget.proveedor.notas!, 'Notas copiadas'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Información del sistema
                  _buildInfoCard(
                    'Información del Sistema',
                    Icons.info,
                    Colors.purple,
                    [
                      _buildInfoRow(
                        'Fecha de registro',
                        _formatDate(widget.proveedor.fechaRegistro),
                        Icons.calendar_today,
                      ),
                      _buildInfoRow(
                        'ID del proveedor',
                        widget.proveedor.id,
                        Icons.fingerprint,
                        onTap: () => _copyToClipboard(widget.proveedor.id, 'ID copiado'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _editarProveedor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleEstadoProveedor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.proveedor.activo 
                                ? Colors.orange.shade600 
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(widget.proveedor.activo ? Icons.visibility_off : Icons.visibility),
                          label: Text(widget.proveedor.activo ? 'Desactivar' : 'Activar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, IconData icono, Color color, List<Widget> children) {
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

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: maxLines,
                      overflow: maxLines != null ? TextOverflow.ellipsis : null,
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 $message'),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _copyToClipboard(phone, 'Teléfono copiado');
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _copyToClipboard(email, 'Email copiado');
    }
  }

  void _editarProveedor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierScreen(
          empresaId: widget.empresaId,
          empresaNombre: widget.empresaNombre,
          proveedorExistente: widget.proveedor,
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  void _toggleEstadoProveedor() async {
    try {
      final proveedorActualizado = Proveedor(
        id: widget.proveedor.id,
        nombre: widget.proveedor.nombre,
        rfc: widget.proveedor.rfc,
        telefono: widget.proveedor.telefono,
        email: widget.proveedor.email,
        direccion: widget.proveedor.direccion,
        contacto: widget.proveedor.contacto,
        notas: widget.proveedor.notas,
        fechaRegistro: widget.proveedor.fechaRegistro,
        activo: !widget.proveedor.activo,
      );

      await _proveedorService.actualizarProveedor(proveedorActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.proveedor.activo 
                ? '✅ Proveedor desactivado'
                : '✅ Proveedor activado',
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al cambiar estado: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar este proveedor?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.proveedor.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _eliminarProveedor();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarProveedor() async {
    try {
      await _proveedorService.eliminarProveedor(widget.proveedor.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Proveedor eliminado exitosamente'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al eliminar: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}