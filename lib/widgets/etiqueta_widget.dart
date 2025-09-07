// lib/widgets/etiqueta_widget.dart
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class EtiquetaWidget extends StatelessWidget {
  final String codigoArticulo;
  final String nombreArticulo;
  final String empresa;
  final double ancho;
  final double alto;
  final TextStyle? nombreStyle;
  final TextStyle? empresaStyle;
  final Color colorFondo;
  final Color colorTexto;
  final Color colorBarras;
  final EdgeInsets padding;

  const EtiquetaWidget({
    Key? key,
    required this.codigoArticulo,
    required this.nombreArticulo,
    required this.empresa,
    this.ancho = 300,
    this.alto = 150,
    this.nombreStyle,
    this.empresaStyle,
    this.colorFondo = Colors.white,
    this.colorTexto = Colors.black,
    this.colorBarras = Colors.black,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: alto,
      padding: padding,
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            empresa,
            style: empresaStyle ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorTexto,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            nombreArticulo,
            style: nombreStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorTexto,
                ),
          ),
          const Spacer(),
          Center(
            child: BarcodeWidget(
              barcode: Barcode.code128(), // Código de barras Code128
              data: codigoArticulo,
              width: double.infinity,
              height: 50,
              drawText: true,
              color: colorBarras,
            ),
          ),
        ],
      ),
    );
  }
}
