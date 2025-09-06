import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/albaran_traspasos.dart';
import 'albaran_detail_screen.dart';

class AlbaranTraspasoListScreen extends StatelessWidget {
  final String empresaId;

  const AlbaranTraspasoListScreen({Key? key, required this.empresaId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albaranes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('empresas')
            .doc(empresaId)
            .collection('albaranes')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay albaranes'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final albaran = AlbaranTraspasos.fromMap(
                  docs[index].id, docs[index].data() as Map<String, dynamic>);
              return ListTile(
                title: Text(albaran.numero),
                subtitle: Text(
                    '${albaran.origen['nombre']} → ${albaran.destino['nombre']}'),
                trailing: Chip(
                  label: Text(albaran.estado,
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: _colorEstado(albaran.estado),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbaranDetailScreen(
                        empresaId: empresaId,
                        albaran: albaran,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'confirmado':
        return Colors.green;
      case 'devuelto':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}