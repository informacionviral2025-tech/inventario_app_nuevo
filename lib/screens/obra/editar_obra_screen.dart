// lib/screens/obra/editar_obra_screen.dart
import 'package:flutter/material.dart';
import '../../models/obra.dart';

class EditarObraScreen extends StatelessWidget {
  final String empresaId;
  final Obra obra;

  const EditarObraScreen({
    Key? key,
    required this.empresaId,
    required this.obra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Obra - ${obra.nombre}')),
      body: const Center(child: Text('Pantalla de edición de obra')),
    );
  }
}