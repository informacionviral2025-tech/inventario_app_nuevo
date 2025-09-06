// lib/screens/articulos/articulo_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/articulo.dart';
import '../../providers/articulo_provider.dart';

class ArticuloFormDialog extends StatefulWidget {
  final Articulo? articulo;
  final String empresaId;
  // PARÁMETRO AGREGADO - onSave para resolver el error
  final VoidCallback? onSave;

  const ArticuloFormDialog({
    Key? key, 
    this.articulo, 
    required this.empresaId,
    this.onSave,  // AGREGADO
  }) : super(key: key);

  @override
  _ArticuloFormDialogState createState() => _ArticuloFormDialogState();
}

class _ArticuloFormDialogState extends State<ArticuloFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _stockMaximoController = TextEditingController();
  String _categoria = 'General';
  final List<String> _categorias = ['General', 'Materiales', 'Herramientas', 'Consumibles'];

  @override
  void initState() {
    super.initState();
    if (widget.articulo != null) {
      _nombreController.text = widget.articulo!.nombre;
      _codigoController.text = widget.articulo!.codigo ?? '';
      _descripcionController.text = widget.articulo!.descripcion ?? '';
      _precioController.text = widget.articulo!.precio.toString();
      // CORREGIDO - convertir double? a String correctamente
      _stockMinimoController.text = (widget.articulo!.stockMinimo ?? 0).toString();
      _stockMaximoController.text = (widget.articulo!.stockMaximo ?? 0).toString();
      _categoria = widget.articulo!.categoria ?? 'General';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockMinimoController.dispose();
    _stockMaximoController.dispose();
    super.dispose();
  }

  Future<void> _guardarArticulo() async {
    if (_formKey.currentState!.validate()) {
      final articuloProvider = Provider.of<ArticuloProvider>(context, listen: false);
      
      // CORREGIDO - usar double.parse en lugar de int.parse para stockMinimo y stockMaximo
      final nuevo = Articulo(
        firebaseId: widget.articulo?.firebaseId,
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim().isEmpty ? null : _codigoController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        stock: widget.articulo?.stock ?? 0,
        empresaId: widget.empresaId,
        categoria: _categoria,
        stockMinimo: double.parse(_stockMinimoController.text.trim()), // CORREGIDO: double en lugar de int
        stockMaximo: double.parse(_stockMaximoController.text.trim()),  // CORREGIDO: double en lugar de int
        activo: widget.articulo?.activo ?? true,
        fechaCreacion: widget.articulo?.fechaCreacion ?? DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      try {
        if (widget.articulo == null) {
          // CORREGIDO - usar crearArticulo (que existe en el provider corregido)
          await articuloProvider.crearArticulo(nuevo);
        } else {
          await articuloProvider.actualizarArticulo(nuevo);
        }
        
        // AGREGADO - llamar al callback onSave si existe
        if (widget.onSave != null) {
          widget.onSave!();
        }
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar artículo: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.articulo == null ? 'Nuevo Artículo' : 'Editar Artículo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un precio válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockMinimoController,
                decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El stock mínimo es obligatorio';
                  }
                  if (double.tryParse(value) == null) { // CORREGIDO: double en lugar de int
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockMaximoController,
                decoration: const InputDecoration(labelText: 'Stock Máximo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El stock máximo es obligatorio';
                  }
                  if (double.tryParse(value) == null) { // CORREGIDO: double en lugar de int
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _categoria,
                onChanged: (value) {
                  setState(() {
                    _categoria = value!;
                  });
                },
                items: _categorias.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardarArticulo,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}