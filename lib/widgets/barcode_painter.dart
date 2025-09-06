// lib/widgets/barcode_painter.dart
import 'package:flutter/material.dart';

class BarcodePainter extends CustomPainter {
  final String code;
  final Color color;
  final double aspectRatio;
  
  BarcodePainter({
    required this.code,
    this.color = Colors.black,
    this.aspectRatio = 3.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Calcular el ancho de cada barra basado en el código
    final barWidth = size.width / (code.length * 2);
    final barHeight = size.height * 0.7;
    
    // Dibujar barras del código de barras
    for (int i = 0; i < code.length; i++) {
      final charCode = code.codeUnitAt(i);
      final barThickness = (charCode % 3 + 1) * barWidth;
      
      final rect = Rect.fromLTWH(
        i * barWidth * 1.5, 
        (size.height - barHeight) / 2, 
        barThickness, 
        barHeight
      );
      
      canvas.drawRect(rect, paint);
    }
    
    // Dibujar el texto del código debajo
    final textStyle = TextStyle(
      color: color,
      fontSize: size.height * 0.2,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan = TextSpan(text: code, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        (size.width - textPainter.width) / 2, 
        size.height * 0.75
      )
    );
  }
  
  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return oldDelegate.code != code || 
           oldDelegate.color != color ||
           oldDelegate.aspectRatio != aspectRatio;
  }
}

// Widget para mostrar el código de barras
class BarcodeWidget extends StatelessWidget {
  final String code;
  final double width;
  final double height;
  final Color color;

  const BarcodeWidget({
    Key? key,
    required this.code,
    this.width = 200,
    this.height = 80,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: BarcodePainter(code: code, color: color),
      ),
    );
  }
}