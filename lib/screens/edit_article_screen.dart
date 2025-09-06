import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditArticleScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final Map<String, dynamic> articulo;

  const EditArticleScreen({
    super.key,
    required this.empresaId,
    required this.empresaNombre,
    required this.articulo,
  });

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  // Controladores de texto
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioCompraController;
  late TextEditingController _precioVentaController;
  late TextEditingController _stockMinimoController;
  late TextEditingController _ubicacionController;

  late String _categoria;
  late String _unidadMedida;
  bool _isLoading = false;

  final List<String> _categorias = [
    'General',
    'Herramientas',
    'Materiales',
    'Electricidad',
    'Fontanería',
    'Construcción',
    'Seguridad',
    'Limpieza',
    'Oficina',
  ];

  final List<String> _unidadesMedida = [
    'Unidad',
    'Metro',
    'Kilogramo',
    'Litro',
    'Caja',
    'Paquete',
    'Rollo',
    'Saco',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _codigoController = TextEditingController(text: widget.articulo['codigo'] ?? '');
    _nombreController = TextEditingController(text: widget.articulo['nombre'] ?? '');
    _descripcionController = TextEditingController(text: widget.articulo['descripcion'] ?? '');
    _precioCompraController = TextEditingController(
      text: (widget.articulo['precioCompra'] ?? 0.0).toString(),
    );
    _precioVentaController = TextEditingController(
      text: (widget.articulo['precioVenta'] ?? 0.0).toString(),
    );
    _stockMinimoController = TextEditingController(
      text: (widget.articulo['stockMinimo'] ?? 0).toString(),
    );
    _ubicacionController = TextEditingController(text: widget.articulo['ubicacion'] ?? '');
    
    _categoria = widget.articulo['categoria'] ?? 'General';
    _unidadMedida = widget.articulo['unidadMedida'] ?? 'Unidad';
  }

  Future<void> _actualizarArticulo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar si el código ya existe en otro artículo
      if (_codigoController.text != widget.articulo['codigo']) {
        final codigoSnapshot = await dbRef
            .child('empresas')
            .child(widget.empresaId)
            .child('articulos')
            .orderByChild('codigo')
            .equalTo(_codigoController.text)
            .get();

        if (codigoSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('El código "${_codigoController.text}" ya existe'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Actualizar el artículo
      final articuloData = {
        'codigo': _codigoController.text,
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'categoria': _categoria,
        'unidadMedida': _unidadMedida,
        'precioCompra': double.tryParse(_precioCompraController.text) ?? 0.0,
        'precioVenta': double.tryParse(_precioVentaController.text) ?? 0.0,
        'stockMinimo': int.tryParse(_stockMinimoController.text) ?? 0,
        'ubicacion': _ubicacionController.text,
        'fechaModificacion': DateTime.now().toIso8601String(),
        // Mantener datos existentes
        'stockActual': widget.articulo['stockActual'] ?? 0,
        'fechaCreacion': widget.articulo['fechaCreacion'],
        'activo': widget.articulo['activo'] ?? true,
      };

      await dbRef
          .child('empresas')
          .child(widget.empresaId)
          .child('articulos')
          .child(widget.articulo['id'])
          .update(articuloData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Artículo actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Retornar los datos actualizados
      Navigator.pop(context, {
        'id': widget.articulo['id'],
        ...articuloData,
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar artículo: $e'),
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
        title: Text('Editar Artículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _codigoController,
                      decoration: InputDecoration(
                        labelText: 'Código del Artículo *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El código es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Artículo *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clasificación',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categorias.map((String categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _categoria = newValue;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _unidadMedida,
                      decoration: InputDecoration(
                        labelText: 'Unidad de Medida',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _unidadesMedida.map((String unidad) {
                        return DropdownMenuItem<String>(
                          value: unidad,
                          child: Text(unidad),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _unidadMedida = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precios y Stock',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precioCompraController,
                            decoration: InputDecoration(
                              labelText: 'Precio de Compra',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.shopping_cart),
                              suffixText: '€',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _precioVentaController,
                            decoration: InputDecoration(
                              labelText: 'Precio de Venta',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.sell),
                              suffixText: '€',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _stockMinimoController,
                      decoration: InputDecoration(
                        labelText: 'Stock Mínimo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                        helperText: 'Cantidad mínima antes de reposición',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _ubicacionController,
                      decoration: InputDecoration(
                        labelText: 'Ubicación en Almacén',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        helperText: 'Ej: Estante A-2, Pasillo 3',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Información del stock actual (solo lectura)
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Stock Actual',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stock disponible: ${widget.articulo['stockActual'] ?? 0} ${widget.articulo['unidadMedida'] ?? 'unidades'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Para modificar el stock, utiliza las funciones de Entrada/Salida',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _actualizarArticulo,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Actualizando...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update),
                        SizedBox(width: 8),
                        Text('Actualizar Artículo'),
                      ],
                    ),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockMinimoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}