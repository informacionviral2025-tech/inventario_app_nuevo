// lib/screens/albaran_editor_screen.dart
// lib/screens/albaran_editor_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AlbaranEditorScreen extends StatefulWidget {
  final String empresaNombre;
  final Map<String, int> articulos; // id -> cantidad
  final Map<String, String> nombresArticulos; // id -> nombre

  const AlbaranEditorScreen({
    Key? key,
    required this.empresaNombre,
    required this.articulos,
    required this.nombresArticulos,
  }) : super(key: key);

  @override
  _AlbaranEditorScreenState createState() => _AlbaranEditorScreenState();
}

class _AlbaranEditorScreenState extends State<AlbaranEditorScreen> {
  Color _headerColor = Colors.red.shade600;
  String _logoPath = '';
  String _titulo = 'Albarán de Salida';
  final pw.Document pdf = pw.Document();

  @override
  void initState() {
    super.initState();
    _generarPdf();
  }

  void _generarPdf() {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (_logoPath.isNotEmpty)
                pw.Center(
                  child: pw.Image(pw.MemoryImage(File(_logoPath).readAsBytesSync()), height: 80),
                ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: double.infinity,
                color: PdfColor.fromInt(_headerColor.value),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  _titulo,
                  style: const pw.TextStyle(
                    color: PdfColor.fromInt(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Empresa: ${widget.empresaNombre}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Artículo', 'Cantidad'],
                data: widget.articulos.entries.map((e) {
                  final nombre = widget.nombresArticulos[e.key] ?? '';
                  return [nombre, e.value.toString()];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Fecha: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }

  void _editarTitulo() async {
    final controller = TextEditingController(text: _titulo);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Título'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Título del Albarán'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Guardar')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _titulo = result;
        pdf.pages.clear();
        _generarPdf();
      });
    }
  }

  void _editarColor() async {
    // Simple selector de colores para encabezado
    final colores = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona color de encabezado'),
        content: Wrap(
          spacing: 10,
          children: colores
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _headerColor = color;
                      pdf.pages.clear();
                      _generarPdf();
                    });
                    Navigator.pop(context);
                  },
                  child: Container(width: 40, height: 40, color: color),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _imprimirPdf() {
    Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Albarán'),
        backgroundColor: _headerColor,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editarTitulo),
          IconButton(icon: const Icon(Icons.color_lens), onPressed: _editarColor),
          IconButton(icon: const Icon(Icons.print), onPressed: _imprimirPdf),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
        allowSharing: true,
        allowPrinting: true,
      ),
    );
  }
}
