import 'package:flutter/material.dart';
import '../../models/articulo.dart';

class CrearAlbaranScreen extends StatelessWidget {
  final String empresaId;
  final Articulo articulo;

  const CrearAlbaranScreen({
    super.key,
    required this.empresaId,
    required this.articulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Albarán'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Artículo: ${articulo.nombre}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Aquí irá el formulario para crear un albarán para este artículo.'),
          ],
        ),
      ),
    );
  }
}