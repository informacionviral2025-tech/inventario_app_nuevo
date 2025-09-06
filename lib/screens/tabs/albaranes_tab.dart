import 'package:flutter/material.dart';

class AlbaranesTab extends StatelessWidget {
  final String empresaId;

  const AlbaranesTab({Key? key, required this.empresaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt, size: 80, color: Colors.purple),
          SizedBox(height: 20),
          Text('Gestión de Albaranes', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            icon: Icon(Icons.search),
            label: Text('Ver Albaranes'),
          ),
        ],
      ),
    );
  }
}