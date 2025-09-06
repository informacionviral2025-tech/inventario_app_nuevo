import 'package:flutter/material.dart';

class CreateArticleDialog extends StatelessWidget {
  final String empresaId;
  final String empresaNombre;

  const CreateArticleDialog({
    super.key, 
    required this.empresaId,
    required this.empresaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear artículo - ${empresaNombre}'),
      content: const SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Aquí irá el formulario para crear artículos'),
            SizedBox(height: 16),
            Text(
              'Funcionalidad próximamente...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Aquí irá la lógica para crear el artículo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidad de creación próximamente'),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}