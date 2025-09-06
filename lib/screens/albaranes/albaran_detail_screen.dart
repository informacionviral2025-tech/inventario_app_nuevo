import 'package:flutter/material.dart';
import '../../models/albaran_traspasos.dart';

class AlbaranDetailScreen extends StatelessWidget {
  final String empresaId;
  final AlbaranTraspasos albaran;

  const AlbaranDetailScreen({
    Key? key,
    required this.empresaId,
    required this.albaran,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Albarán ${albaran.numero}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _tile('Número', albaran.numero),
            _tile('Fecha', albaran.fecha.toLocal().toString()),
            _tile('Origen',
                '${albaran.origen['tipo']} - ${albaran.origen['nombre']}'),
            _tile('Destino',
                '${albaran.destino['tipo']} - ${albaran.destino['nombre']}'),
            _tile('Usuario', albaran.usuario),
            _tile('Estado', albaran.estado),
            const SizedBox(height: 16),
            const Text('Artículos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...albaran.articulos.entries.map(
              (e) => ListTile(
                title: Text(e.key),
                subtitle: Text('Cantidad: ${e.value}'),
              ),
            ),
            const SizedBox(height: 8),
            _tile('Observaciones', albaran.observaciones),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}