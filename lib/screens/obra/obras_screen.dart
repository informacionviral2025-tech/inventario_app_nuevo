// lib/screens/obra/obras_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/obra.dart';
import '../../providers/obra_provider.dart';
import '../../routes.dart';

class ObrasScreen extends StatelessWidget {
  const ObrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obras'),
      ),
      body: Consumer<ObraProvider>(
        builder: (context, obraProvider, _) {
          if (obraProvider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (obraProvider.error != null) {
            return Center(child: Text('Error: ${obraProvider.error}'));
          }
          if (obraProvider.obras.isEmpty) {
            return const Center(child: Text('No hay obras disponibles'));
          }
          return ListView.builder(
            itemCount: obraProvider.obras.length,
            itemBuilder: (context, index) {
              final obra = obraProvider.obras[index];
              return ListTile(
                title: Text(obra.nombre),
                subtitle: Text('Estado: ${obra.estado}'),
                onTap: () {
                  AppRouter.goToObraDetail(context, obra.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}