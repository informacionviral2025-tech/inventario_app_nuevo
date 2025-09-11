// lib/widgets/auto_barcode_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/unified_inventory_provider.dart';
import '../models/articulo.dart';

class AutoBarcodeWidget extends StatefulWidget {
  final String empresaId;
  final Function(Articulo) onArticuloFound;
  final Function(String) onArticuloNotFound;

  const AutoBarcodeWidget({
    Key? key,
    required this.empresaId,
    required this.onArticuloFound,
    required this.onArticuloNotFound,
  }) : super(key: key);

  @override
  State<AutoBarcodeWidget> createState() => _AutoBarcodeWidgetState();
}

class _AutoBarcodeWidgetState extends State<AutoBarcodeWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing || barcode.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      final articulo = await provider.getArticuloByCodigo(barcode.trim());

      if (articulo != null) {
        widget.onArticuloFound(articulo);
        _barcodeController.clear();
      } else {
        widget.onArticuloNotFound(barcode);
      }
    } catch (e) {
      widget.onArticuloNotFound(barcode);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Escáner de Código de Barras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isProcessing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Código de barras',
                hintText: 'Escriba o escanee el código',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: _barcodeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _barcodeController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _processBarcode,
              enabled: !_isProcessing,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing || _barcodeController.text.trim().isEmpty
                    ? null
                    : () => _processBarcode(_barcodeController.text),
                icon: const Icon(Icons.search),
                label: const Text('Buscar Artículo'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: Puede escribir el código manualmente o usar el escáner integrado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarcodeHistoryWidget extends StatefulWidget {
  final String empresaId;

  const BarcodeHistoryWidget({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  State<BarcodeHistoryWidget> createState() => _BarcodeHistoryWidgetState();
}

class _BarcodeHistoryWidgetState extends State<BarcodeHistoryWidget> {
  final List<String> _barcodeHistory = [];

  void addToHistory(String barcode) {
    if (!_barcodeHistory.contains(barcode)) {
      setState(() {
        _barcodeHistory.insert(0, barcode);
        if (_barcodeHistory.length > 10) {
          _barcodeHistory.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_barcodeHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Códigos Recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _barcodeHistory.clear();
                    });
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._barcodeHistory.map((barcode) => ListTile(
              leading: const Icon(Icons.qr_code, size: 20),
              title: Text(barcode),
              trailing: IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () {
                  // Buscar este código
                  final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
                  provider.getArticuloByCodigo(barcode).then((articulo) {
                    if (articulo != null) {
                      // Mostrar información del artículo
                      _showArticuloInfo(articulo);
                    }
                  });
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showArticuloInfo(Articulo articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(articulo.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${articulo.codigo}'),
            Text('Stock: ${articulo.stock}'),
            if (articulo.precio > 0)
              Text('Precio: €${articulo.precio.toStringAsFixed(2)}'),
            if (articulo.categoria != null)
              Text('Categoría: ${articulo.categoria}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

