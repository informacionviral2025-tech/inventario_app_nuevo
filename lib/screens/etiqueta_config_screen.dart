// lib/screens/etiqueta_config_screen.dart
import 'package:flutter/material.dart';
import '../widgets/etiqueta_editable_widget.dart';

class ConfigurarEtiquetaScreen extends StatefulWidget {
  final String codigoArticulo;
  final String nombreArticulo;
  final String empresa;

  const ConfigurarEtiquetaScreen({
    Key? key,
    required this.codigoArticulo,
    required this.nombreArticulo,
    required this.empresa,
  }) : super(key: key);

  @override
  _ConfigurarEtiquetaScreenState createState() =>
      _ConfigurarEtiquetaScreenState();
}

class _ConfigurarEtiquetaScreenState extends State<ConfigurarEtiquetaScreen> {
  double ancho = 300;
  double alto = 150;
  Color colorFondo = Colors.white;
  Color colorTexto = Colors.black;
  Color colorBarras = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Etiqueta'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: EtiquetaEditableWidget(
                  codigoArticulo: widget.codigoArticulo,
                  nombreArticulo: widget.nombreArticulo,
                  empresa: widget.empresa,
                  ancho: ancho,
                  alto: alto,
                  colorFondo: colorFondo,
                  colorTexto: colorTexto,
                  colorBarras: colorBarras,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sliderConfig('Ancho', ancho, 100, 400, (v) {
              setState(() => ancho = v);
            }),
            _sliderConfig('Alto', alto, 100, 400, (v) {
              setState(() => alto = v);
            }),
            _colorPicker('Fondo', colorFondo, (v) => setState(() => colorFondo = v)),
            _colorPicker('Texto', colorTexto, (v) => setState(() => colorTexto = v)),
            _colorPicker('Barras', colorBarras, (v) => setState(() => colorBarras = v)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí se puede imprimir o guardar configuración
                Navigator.pop(context);
              },
              child: const Text('Guardar / Imprimir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderConfig(
      String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _colorPicker(String label, Color color, Function(Color) onColorChanged) {
    return Row(
      children: [
        Text('$label: '),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            Color? picked = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Seleccionar color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: color,
                    onColorChanged: (c) => Navigator.pop(context, c),
                  ),
                ),
              ),
            );
            if (picked != null) onColorChanged(picked);
          },
          child: Container(
            width: 24,
            height: 24,
            color: color,
          ),
        ),
      ],
    );
  }
}
