//lib/services/barcode_service.dart
import 'package:flutter/material.dart';

class BarcodeInfo {
  final String data;
  final String type;
  final DateTime createdAt;
  final String? lote;
  final String? articleCode;
  final String? empresaId;    // AGREGADO - parámetro faltante
  
  BarcodeInfo({
    required this.data,
    required this.type,
    required this.createdAt,
    this.lote,
    this.articleCode,
    this.empresaId,           // AGREGADO
  });

  factory BarcodeInfo.fromMap(Map<String, dynamic> map) {
    return BarcodeInfo(
      data: map['data'] ?? '',
      type: map['type'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lote: map['lote'],
      articleCode: map['articleCode'],
      empresaId: map['empresaId'],    // AGREGADO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'lote': lote,
      'articleCode': articleCode,
      'empresaId': empresaId,         // AGREGADO
    };
  }
}

class BarcodeService {
  
  // MÉTODO CORREGIDO - agregar parámetro empresaId faltante
  BarcodeInfo generateBarcodeData(
    String articleCode, {
    String? lote,
    String? empresaId,            // AGREGADO - parámetro faltante
  }) {
    // Generar código de barras basado en el código del artículo
    String barcodeData = _generateEAN13(articleCode);
    
    return BarcodeInfo(
      data: barcodeData,
      type: 'EAN13',
      createdAt: DateTime.now(),
      lote: lote,
      articleCode: articleCode,
      empresaId: empresaId,       // AGREGADO
    );
  }

  // Sobrecarga del método para compatibilidad con firebase_service.dart
  String generateBarcodeData2(
    String articleCode, {
    String? empresaId,
    String? lote,
  }) {
    return _generateEAN13(articleCode);
  }

  String extractArticleCodeFromBarcode(String barcode) {
    // Extraer código de artículo del código de barras
    // Esta es una implementación simple, ajusta según tu lógica
    if (barcode.length >= 8) {
      return barcode.substring(0, 8);
    }
    return barcode;
  }

  String _generateEAN13(String articleCode) {
    // Generar EAN13 basado en código de artículo
    // Esta es una implementación simplificada
    String base = articleCode.padRight(12, '0').substring(0, 12);
    
    // Calcular dígito de verificación
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(base[i]);
      if (i % 2 == 0) {
        sum += digit;
      } else {
        sum += digit * 3;
      }
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return base + checkDigit.toString();
  }
  
  // Construir widget de código de barras visual
  Widget buildBarcodeWidget(
    String data, {
    String type = 'EAN13',
    double width = 200,
    double height = 60,
    bool showText = true,
    TextStyle? textStyle,
  }) {
    return Container(
      width: width,
      height: height + (showText ? 20 : 0),
      child: Column(
        children: [
          // Representación visual simple del código de barras
          Expanded(
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
              ),
              child: CustomPaint(
                painter: BarcodePainter(data: data),
                size: Size(width, height),
              ),
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 4),
            Text(
              data,
              style: textStyle ?? const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Validar código de barras
  bool validateBarcode(String data, String type) {
    switch (type.toUpperCase()) {
      case 'EAN13':
        return _validateEAN13(data);
      case 'EAN8':
        return _validateEAN8(data);
      case 'UPC-A':
        return _validateUPCA(data);
      default:
        return data.isNotEmpty;
    }
  }

  bool _validateEAN13(String data) {
    if (data.length != 13) return false;
    
    try {
      // Calcular dígito de verificación
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        int digit = int.parse(data[i]);
        if (i % 2 == 0) {
          sum += digit;
        } else {
          sum += digit * 3;
        }
      }
      
      int checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == int.parse(data[12]);
    } catch (e) {
      return false;
    }
  }

  bool _validateEAN8(String data) {
    if (data.length != 8) return false;
    
    try {
      int sum = 0;
      for (int i = 0; i < 7; i++) {
        int digit = int.parse(data[i]);
        if (i % 2 == 0) {
          sum += digit * 3;
        } else {
          sum += digit;
        }
      }
      
      int checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == int.parse(data[7]);
    } catch (e) {
      return false;
    }
  }

  bool _validateUPCA(String data) {
    if (data.length != 12) return false;
    
    try {
      int sum = 0;
      for (int i = 0; i < 11; i++) {
        int digit = int.parse(data[i]);
        if (i % 2 == 0) {
          sum += digit * 3;
        } else {
          sum += digit;
        }
      }
      
      int checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == int.parse(data[11]);
    } catch (e) {
      return false;
    }
  }
}

class BarcodePainter extends CustomPainter {
  final String data;

  BarcodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Dibujar líneas verticales simulando un código de barras
    double barWidth = size.width / (data.length * 2);
    
    for (int i = 0; i < data.length; i++) {
      int digit = int.tryParse(data[i]) ?? 0;
      
      // Alternar entre barras gruesas y finas basado en el dígito
      double currentBarWidth = (digit % 2 == 0) ? barWidth : barWidth * 1.5;
      
      double x = i * (barWidth * 2);
      
      canvas.drawRect(
        Rect.fromLTWH(x, 0, currentBarWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Dialog para mostrar código de barras en grande
class BarcodeDisplayDialog extends StatelessWidget {
  final BarcodeInfo barcodeInfo;
  final String? articleName;

  const BarcodeDisplayDialog({
    Key? key,
    required this.barcodeInfo,
    this.articleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barcodeService = BarcodeService();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              articleName ?? 'Código de Barras',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Código de barras grande
            barcodeService.buildBarcodeWidget(
              barcodeInfo.data,
              type: barcodeInfo.type,
              width: 300,
              height: 120,
              showText: true,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Código:', barcodeInfo.data),
                  _buildInfoRow('Tipo:', barcodeInfo.type),
                  _buildInfoRow(
                    'Creado:', 
                    '${barcodeInfo.createdAt.day}/${barcodeInfo.createdAt.month}/${barcodeInfo.createdAt.year}',
                  ),
                  if (barcodeInfo.lote != null)
                    _buildInfoRow('Lote:', barcodeInfo.lote!),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Copiar al portapapeles
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}