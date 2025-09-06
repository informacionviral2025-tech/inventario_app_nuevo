import 'package:flutter/material.dart';

class VehiculosTab extends StatelessWidget {
  final String empresaId;

  const VehiculosTab({Key? key, required this.empresaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text('Gestión de Vehículos', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            icon: Icon(Icons.add),
            label: Text('Añadir Vehículo'),
          ),
        ],
      ),
    );
  }
}