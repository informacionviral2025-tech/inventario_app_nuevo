import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/articulo.dart';

class EtiquetaGenerator extends StatelessWidget {
  final Articulo articulo;

  const EtiquetaGenerator({super.key, required this.articulo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Etiqueta del Artículo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Empresa: ${articulo.empresa}'),
          Text('Artículo: ${articulo.nombre}'),
          Text('Código: ${articulo.codigo}'),
          const SizedBox(height: 10),
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: articulo.codigo,
            width: 200,
            height: 80,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // No imprimir
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Aquí puedes añadir la función para enviar a la impresora
            Navigator.pop(context);
          },
          child: const Text('Imprimir'),
        ),
      ],
    );
  }
}
