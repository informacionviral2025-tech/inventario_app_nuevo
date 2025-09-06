import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditSupplierScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final Map<String, dynamic> supplier;

  const EditSupplierScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    required this.supplier,
  }) : super(key: key);

  @override
  _EditSupplierScreenState createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cifController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactoController = TextEditingController();
  final _diasPagoController = TextEditingController();
  final _descuentoController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String _codigo = '';
  bool _activo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSupplierData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cifController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _codigoPostalController.dispose();
    _provinciaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _contactoController.dispose();
    _diasPagoController.dispose();
    _descuentoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _loadSupplierData() {
    final supplier = widget.supplier;
    
    _codigo = supplier['codigo'] ?? '';
    _nombreController.text = supplier['nombre'] ?? '';
    _cifController.text = supplier['cif'] ?? '';
    _direccionController.text = supplier['direccion'] ?? '';
    _ciudadController.text = supplier['ciudad'] ?? '';
    _codigoPostalController.text = supplier['codigoPostal'] ?? '';
    _provinciaController.text = supplier['provincia'] ?? '';
    _telefonoController.text = supplier['telefono'] ?? '';
    _emailController.text = supplier['email'] ?? '';
    _contactoController.text = supplier['contacto'] ?? '';
    _diasPagoController.text = (supplier['diasPago'] ?? 30).toString();
    _descuentoController.text = (supplier['descuento'] ?? 0.0).toString();
    _observacionesController.text = supplier['observaciones'] ?? '';
    _activo = supplier['activo'] ?? true;
  }

  void _updateSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final databaseRef = FirebaseDatabase.instance
          .ref('empresas/${widget.empresaId}/proveedores/${widget.supplier['id']}');

      final updatedData = {
        'codigo': _codigo,
        'nombre': _nombreController.text.trim(),
        'cif': _cifController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'codigoPostal': _codigoPostalController.text.trim(),
        'provincia': _provinciaController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'contacto': _contactoController.text.trim(),
        'diasPago': int.tryParse(_diasPagoController.text) ?? 30,
        'descuento': double.tryParse(_descuentoController.text) ?? 0.0,
        'observaciones': _observacionesController.text.trim(),
        'activo': _activo,
        'fechaModificacion': DateTime.now().toIso8601String(),
      };

      await databaseRef.update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proveedor actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Proveedor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _updateSupplier,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Información básica
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Código (solo lectura)
                    TextFormField(
                      initialValue: _codigo,
                      decoration: InputDecoration(
                        labelText: 'Código',
                        prefixIcon: Icon(Icons.qr_code),
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    SizedBox(height: 16),
                    
                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // CIF/NIF
                    TextFormField(
                      controller: _cifController,
                      decoration: InputDecoration(
                        labelText: 'CIF/NIF *',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El CIF/NIF es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Estado activo
                    SwitchListTile(
                      title: Text('Proveedor activo'),
                      value: _activo,
                      onChanged: (value) {
                        setState(() {
                          _activo = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Dirección
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _direccionController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ciudadController,
                            decoration: InputDecoration(
                              labelText: 'Ciudad',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _codigoPostalController,
                            decoration: InputDecoration(
                              labelText: 'C.P.',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _provinciaController,
                      decoration: InputDecoration(
                        labelText: 'Provincia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Contacto
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _contactoController,
                      decoration: InputDecoration(
                        labelText: 'Persona de contacto',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Condiciones comerciales
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Condiciones Comerciales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _diasPagoController,
                            decoration: InputDecoration(
                              labelText: 'Días de pago',
                              suffixText: 'días',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _descuentoController,
                            decoration: InputDecoration(
                              labelText: 'Descuento',
                              suffixText: '%',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Botón guardar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}