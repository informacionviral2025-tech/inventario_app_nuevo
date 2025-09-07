import 'package:flutter/material.dart';
import '../../models/articulo.dart';
import '../../services/database_service.dart';
import '../../services/sync_helper.dart';

class EditarArticuloScreen extends StatefulWidget {
  final Articulo articulo;
  final String empresaId;
  final String empresaNombre;

  const EditarArticuloScreen({
    super.key,
    required this.articulo,
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  State<EditarArticuloScreen> createState() => _EditarArticuloScreenState();
}

class _EditarArticuloScreenState extends State<EditarArticuloScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _categoriaController;

  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.articulo.nombre);
    _descripcionController = TextEditingController(text: widget.articulo.descripcion ?? '');
    _precioController = TextEditingController(text: widget.articulo.precio.toString());
    _stockController = TextEditingController(text: widget.articulo.stock.toString());
    _codigoBarrasController = TextEditingController(text: widget.articulo.codigoBarras ?? '');
    _categoriaController = TextEditingController(text: widget.articulo.categoria ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _codigoBarrasController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _updateArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updated = widget.articulo.copyWith(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(_precioController.text),
        stock: int.parse(_stockController.text),
        codigoBarras: _codigoBarrasController.text.trim(),
        categoria: _categoriaController.text.trim(),
        fechaActualizacion: DateTime.now(),
        pendienteSincronizacion: true,
        sincronizado: false,
      );

      await _databaseService.updateArticulo(updated);
      await SyncHelper().syncNow();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artículo actualizado ✅')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Artículo - ${widget.empresaNombre}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioController,
                      decoration: const InputDecoration(labelText: 'Precio *'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || double.tryParse(v) == null ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock *'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codigoBarrasController,
                decoration: const InputDecoration(labelText: 'Código de barras'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateArticle,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}