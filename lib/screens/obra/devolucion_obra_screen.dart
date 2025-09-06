// lib/screens/obra/devolucion_obra_screen.dart
import 'package:flutter/material.dart';
import '../../models/obra.dart';
import '../../services/obra_service.dart';
import '../../services/articulo_service.dart';

class DevolucionObraScreen extends StatelessWidget {
  final String empresaId;
  final Obra obra;

  const DevolucionObraScreen({
    Key? key,
    required this.empresaId,
    required this.obra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devolución - ${obra.nombre}'),
      ),
      body: const Center(
        child: Text('Función de devolución próximamente'),
      ),
    );
  }
}