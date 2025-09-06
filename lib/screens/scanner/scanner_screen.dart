import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear código")),
      body: MobileScanner(
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final String? value = barcode.rawValue;
            debugPrint('Código detectado: $value');
            if (value != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Código detectado: $value")),
              );
            }
          }
        },
      ),
    );
  }
}
