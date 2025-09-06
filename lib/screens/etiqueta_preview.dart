import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class EtiquetaPreviewScreen extends StatelessWidget {
  final String codigo;
  final String nombre;
  final String empresa;

  EtiquetaPreviewScreen({
    required this.codigo,
    required this.nombre,
    required this.empresa,
  });

  Future<void> _imprimirEtiqueta() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(nombre, style: pw.TextStyle(fontSize: 14)),
              pw.Text(empresa, style: pw.TextStyle(fontSize: 10)),
              pw.BarcodeWidget(
                data: codigo,
                barcode: pw.Barcode.code128(),
                width: 200,
                height: 50,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista previa de etiqueta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nombre, style: TextStyle(fontSize: 18)),
            Text(empresa, style: TextStyle(fontSize: 14)),
            BarcodeWidget(
              data: codigo,
              barcode: Barcode.code128(),
              width: 200,
              height: 80,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imprimirEtiqueta,
              child: Text('Imprimir'),
            ),
          ],
        ),
      ),
    );
  }
}
