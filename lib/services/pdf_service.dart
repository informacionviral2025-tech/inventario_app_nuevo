// lib/services/pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Configuración editable para el albarán
  pw.TextStyle tituloStyle = const pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
  pw.TextStyle headerStyle = const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
  PdfColor headerColor = PdfColors.grey300;
  PdfColor backgroundColor = PdfColors.white;

  /// Permite actualizar estilos desde la app
  void actualizarEstilos({
    pw.TextStyle? titulo,
    pw.TextStyle? header,
    PdfColor? headerBgColor,
    PdfColor? bgColor,
  }) {
    if (titulo != null) tituloStyle = titulo;
    if (header != null) headerStyle = header;
    if (headerBgColor != null) headerColor = headerBgColor;
    if (bgColor != null) backgroundColor = bgColor;
  }

  /// Generar PDF de albarán
  Future<Uint8List> generarAlbaranPdf({
    required String empresaNombre,
    required String albaranId,
    required DateTime fecha,
    required Map<String, dynamic> articulos,
    required Map<String, String> nombresArticulos,
    String? logoUrl, // Opcional: logo de empresa
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            color: backgroundColor,
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoUrl != null)
                  pw.Image(
                    pw.MemoryImage(
                      // Aquí podrías cargar bytes de la imagen
                      Uint8List(0),
                    ),
                    height: 60,
                  ),
                pw.Text('Albarán de Salida', style: tituloStyle),
                pw.SizedBox(height: 8),
                pw.Text('Empresa: $empresaNombre'),
                pw.Text('Albarán ID: $albaranId'),
                pw.Text('Fecha: ${fecha.toLocal().toString().split(' ')[0]}'),
                pw.SizedBox(height: 16),
                pw.Text('Artículos:', style: headerStyle),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Artículo', 'Cantidad'],
                  data: articulos.entries.map((e) {
                    final nombre = nombresArticulos[e.key] ?? e.key;
                    return [nombre, e.value.toString()];
                  }).toList(),
                  headerStyle: headerStyle,
                  headerDecoration: pw.BoxDecoration(color: headerColor),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.Spacer(),
                pw.Text('Firma: ______________________'),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Mostrar PDF en pantalla y permitir imprimir
  Future<void> mostrarPdf(BuildContext context, Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}
