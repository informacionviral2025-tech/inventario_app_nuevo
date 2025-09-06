// lib/providers/barcode_provider.dart
import 'package:flutter/foundation.dart';
import '../services/barcode_service.dart';

class BarcodeProvider with ChangeNotifier {
  final BarcodeService _barcodeService = BarcodeService();
  String? _error;
  String? _ultimoCodigoEscaneado;

  String? get error => _error;
  String? get ultimoCodigoEscaneado => _ultimoCodigoEscaneado;

  bool validarCodigoBarras(String codigo, String tipo) {
    try {
      return _barcodeService.validateBarcode(codigo, tipo);
    } catch (e) {
      _error = 'Error validando código: $e';
      return false;
    }
  }

  void setCodigoEscaneado(String codigo) {
    _ultimoCodigoEscaneado = codigo;
    notifyListeners();
  }

  void limpiarCodigoEscaneado() {
    _ultimoCodigoEscaneado = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}