// lib/screens/articulos_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddArticleScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const AddArticleScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  // Controladores de texto
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioCompraController = TextEditingController();
  final TextEditingController _precioVentaController = TextEditingController();
  final TextEditingController _stockMinimoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  String _categoria = 'General';
  String _unidadMedida = 'Unidad';
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
    _generarCodigoAutomatico();
  }

  void _generarCodigoAutomatico() {
    // Generar código automático basado en timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final codigo = 'ART${timestamp.substring(timestamp.length - 8)}';
    _codigoController.text = codigo;
  }

  Future<void> _guardarArticulo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar si el código ya existe
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

      // Crear el artículo
      final articuloData = {
        'codigo': _codigoController.text,
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'categoria': _categoria,
        'unidadMedida': _unidadMedida,
        'precioCompra': double.tryParse(_precioCompraController.text) ?? 0.0,
        'precioVenta': double.tryParse(_precioVentaController.text) ?? 0.0,
        'stockMinimo': int.tryParse(_stockMinimoController.text) ?? 0,
        'stockActual': 0, // Inicia con 0, se actualiza con las entradas
        'ubicacion': _ubicacionController.text,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'activo': true,
      };

      await dbRef
          .child('empresas')
          .child(widget.empresaId)
          .child('articulos')
          .push()
          .set(articuloData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Artículo "${_nombreController.text}" creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna true para indicar que se guardó

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar artículo: $e'),
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
        title: Text('Nuevo Artículo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generarCodigoAutomatico,
            tooltip: 'Generar nuevo código',
          ),
        ],
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
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarArticulo,
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
                        Text('Guardando...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text('Guardar Artículo'),
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