// lib/screens/obra/tareas_obra_screen.dart
import 'package:flutter/material.dart';

class TareasObraScreen extends StatelessWidget {
  final String empresaId;
  final String obraId;
  final String obraNombre;

  const TareasObraScreen({
    Key? key,
    required this.empresaId,
    required this.obraId,
    required this.obraNombre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tareas - $obraNombre')),
      body: const Center(child: Text('Pantalla de tareas por obra')),
    );
  }
}