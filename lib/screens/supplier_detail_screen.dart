import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final Map<String, dynamic> supplier;

  const SupplierDetailScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    required this.supplier,
  }) : super(key: key);

  @override
  _SupplierDetailScreenState createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  Map<String, dynamic> _supplier = {};

  @override
  void initState() {
    super.initState();
    _supplier = Map<String, dynamic>.from(widget.supplier);
  }

  void _refreshSupplier() async {
    try {
      final databaseRef = FirebaseDatabase.instance
          .ref('empresas/${widget.empresaId}/proveedores/${_supplier['id']}');
      
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        setState(() {
          _supplier = Map<String, dynamic>.from(snapshot.value as Map);
          _supplier['id'] = widget.supplier['id'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar datos: $e')),
      );
    }
  }

  void _deleteSupplier() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el proveedor "${_supplier['nombre']}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final databaseRef = FirebaseDatabase.instance
            .ref('empresas/${widget.empresaId}/proveedores/${_supplier['id']}');
        
        await databaseRef.remove();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proveedor eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleActiveStatus() async {
    try {
      final newStatus = !(_supplier['activo'] ?? true);
      
      final databaseRef = FirebaseDatabase.instance
          .ref('empresas/${widget.empresaId}/proveedores/${_supplier['id']}');
      
      await databaseRef.update({
        'activo': newStatus,
        'fechaModificacion': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _supplier['activo'] = newStatus;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus 
            ? 'Proveedor activado' 
            : 'Proveedor desactivado'),
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

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _supplier['activo'] ?? true;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_supplier['nombre'] ?? ''),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSupplierScreen(
                    empresaId: widget.empresaId,
                    empresaNombre: widget.empresaNombre,
                    supplier: _supplier,
                  ),
                ),
              );
              
              if (result == true) {
                _refreshSupplier();
              }
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(isActive ? Icons.block : Icons.check_circle),
                    SizedBox(width: 8),
                    Text(isActive ? 'Desactivar' : 'Activar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'toggle_status':
                  _toggleActiveStatus();
                  break;
                case 'delete':
                  _deleteSupplier();
                  break;
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Estado del proveedor
          if (!isActive)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Proveedor inactivo',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Información básica
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Información Básica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  
                  _buildInfoRow('Código:', _supplier['codigo'] ?? ''),
                  _buildInfoRow('Nombre:', _supplier['nombre'] ?? ''),
                  _buildInfoRow('CIF/NIF:', _supplier['cif'] ?? ''),
                  
                  if (_supplier['fechaAlta'] != null)
                    _buildInfoRow('Fecha de alta:', 
                        _formatDate(_supplier['fechaAlta'])),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Dirección
          if (_hasAddressInfo())
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Dirección',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    
                    if (_supplier['direccion']?.isNotEmpty == true)
                      _buildInfoRow('Dirección:', _supplier['direccion']),
                    
                    if (_supplier['ciudad']?.isNotEmpty == true || 
                        _supplier['codigoPostal']?.isNotEmpty == true)
                      _buildInfoRow('Ciudad:', 
                          '${_supplier['ciudad'] ?? ''} ${_supplier['codigoPostal'] ?? ''}'.trim()),
                    
                    if (_supplier['provincia']?.isNotEmpty == true)
                      _buildInfoRow('Provincia:', _supplier['provincia']),
                  ],
                ),
              ),
            ),

          if (_hasAddressInfo()) SizedBox(height: 16),

          // Contacto
          if (_hasContactInfo())
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_phone, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Contacto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    
                    if (_supplier['telefono']?.isNotEmpty == true)
                      _buildContactRow(
                        'Teléfono:',
                        _supplier['telefono'],
                        Icons.phone,
                        () => _makePhoneCall(_supplier['telefono']),
                      ),
                    
                    if (_supplier['email']?.isNotEmpty == true)
                      _buildContactRow(
                        'Email:',
                        _supplier['email'],
                        Icons.email,
                        () => _sendEmail(_supplier['email']),
                      ),
                    
                    if (_supplier['contacto']?.isNotEmpty == true)
                      _buildInfoRow('Contacto:', _supplier['contacto']),
                  ],
                ),
              ),
            ),

          if (_hasContactInfo()) SizedBox(height: 16),

          // Condiciones comerciales
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Condiciones Comerciales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  
                  _buildInfoRow('Días de pago:', 
                      '${_supplier['diasPago'] ?? 30} días'),
                  
                  if ((_supplier['descuento'] ?? 0) > 0)
                    _buildInfoRow('Descuento:', 
                        '${_supplier['descuento']}%'),
                  
                  if (_supplier['observaciones']?.isNotEmpty == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Observaciones:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _supplier['observaciones'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Estadísticas (placeholder para futuras funcionalidades)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Pedidos', '0', Icons.shopping_cart),
                      _buildStatCard('Facturas', '0', Icons.receipt),
                      _buildStatCard('Total €', '0,00', Icons.euro),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Estadísticas disponibles próximamente',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(icon, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  bool _hasAddressInfo() {
    return (_supplier['direccion']?.isNotEmpty == true) ||
           (_supplier['ciudad']?.isNotEmpty == true) ||
           (_supplier['codigoPostal']?.isNotEmpty == true) ||
           (_supplier['provincia']?.isNotEmpty == true);
  }

  bool _hasContactInfo() {
    return (_supplier['telefono']?.isNotEmpty == true) ||
           (_supplier['email']?.isNotEmpty == true) ||
           (_supplier['contacto']?.isNotEmpty == true);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}