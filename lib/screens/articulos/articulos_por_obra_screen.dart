// lib/screens/obra/articulos_por_obra_screen.dart
import 'package:flutter/material.dart';

class ArticulosPorObraScreen extends StatelessWidget {
  final String empresaId;
  final String obraId;
  final String obraNombre;

  const ArticulosPorObraScreen({
    Key? key,
    required this.empresaId,
    required this.obraId,
    required this.obraNombre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artículos - $obraNombre')),
      body: const Center(child: Text('Pantalla de artículos por obra')),
    );
  }
}