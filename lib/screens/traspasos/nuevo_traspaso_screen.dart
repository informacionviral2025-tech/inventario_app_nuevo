import 'package:flutter/material.dart';

class NuevoTraspasoScreen extends StatelessWidget {
  const NuevoTraspasoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Traspaso"),
      ),
      body: const Center(
        child: Text(
          "Pantalla de creación de traspasos (pendiente de implementar)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
