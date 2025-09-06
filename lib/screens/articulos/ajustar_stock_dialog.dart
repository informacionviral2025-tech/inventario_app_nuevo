import 'package:flutter/material.dart';
import '../../models/articulo.dart';
import '../../services/articulo_service.dart';

class AjustarStockDialog extends StatefulWidget {
  final Articulo articulo;
  final VoidCallback onSave;

  const AjustarStockDialog({
    super.key,
    required this.articulo,
    required this.onSave,
  });

  @override
  State<AjustarStockDialog> createState() => _AjustarStockDialogState();
}

class _AjustarStockDialogState extends State<AjustarStockDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ArticuloService(widget.articulo.firebaseId!);
    return AlertDialog(
      title: const Text('Ajustar Stock'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Nuevo stock'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final nuevoStock = int.tryParse(_controller.text);
            if (nuevoStock == null) return;
            final actualizado = widget.articulo.copyWith(stock: nuevoStock);
            await service.actualizarArticulo(actualizado);
            widget.onSave();
            Navigator.pop(context);
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}