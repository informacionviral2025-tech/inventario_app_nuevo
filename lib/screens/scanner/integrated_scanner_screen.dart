// lib/screens/scanner/integrated_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_inventory_provider.dart';
import '../../models/articulo.dart';
import '../../services/articulo_service.dart';

class IntegratedScannerScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final ScannerMode mode; // entrada, salida, busqueda

  const IntegratedScannerScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    this.mode = ScannerMode.busqueda,
  }) : super(key: key);

  @override
  State<IntegratedScannerScreen> createState() => _IntegratedScannerScreenState();
}

enum ScannerMode { entrada, salida, busqueda }

class _IntegratedScannerScreenState extends State<IntegratedScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  final TextEditingController _cantidadController = TextEditingController();
  Articulo? _articuloEncontrado;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _procesarCodigo(String codigo) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      final articulo = await provider.getArticuloByCodigo(codigo);
      
      if (articulo != null) {
        setState(() {
          _articuloEncontrado = articulo;
        });
        
        // Mostrar información del artículo
        _mostrarArticuloEncontrado(articulo);
      } else {
        _mostrarArticuloNoEncontrado(codigo);
      }
    } catch (e) {
      _mostrarError('Error al buscar artículo: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _mostrarArticuloEncontrado(Articulo articulo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Artículo Encontrado',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildArticuloInfo(articulo),
                      const SizedBox(height: 20),
                      _buildAcciones(articulo),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticuloInfo(Articulo articulo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: articulo.tieneStock ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    articulo.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Código:', articulo.codigo),
            _buildInfoRow('Stock:', '${articulo.stock}'),
            if (articulo.stockMinimo != null)
              _buildInfoRow('Stock Mínimo:', '${articulo.stockMinimo}'),
            _buildInfoRow('Precio:', '€${articulo.precio.toStringAsFixed(2)}'),
            if (articulo.categoria != null)
              _buildInfoRow('Categoría:', articulo.categoria!),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: articulo.tieneStock 
                    ? (articulo.necesitaReabastecimiento ? Colors.orange : Colors.green)
                    : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                articulo.tieneStock 
                    ? (articulo.necesitaReabastecimiento ? 'Stock Bajo' : 'En Stock')
                    : 'Sin Stock',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAcciones(Articulo articulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.mode == ScannerMode.entrada) ...[
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCantidad(articulo, 'entrada'),
            icon: const Icon(Icons.add_circle),
            label: const Text('Agregar Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.mode == ScannerMode.salida && articulo.tieneStock) ...[
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoCantidad(articulo, 'salida'),
            icon: const Icon(Icons.remove_circle),
            label: const Text('Retirar Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton.icon(
          onPressed: () => _verDetalles(articulo),
          icon: const Icon(Icons.info),
          label: const Text('Ver Detalles'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text('Cerrar'),
        ),
      ],
    );
  }

  void _mostrarDialogoCantidad(Articulo articulo, String tipo) {
    _cantidadController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tipo == 'entrada' ? 'Agregar' : 'Retirar'} Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Artículo: ${articulo.nombre}'),
            Text('Stock actual: ${articulo.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _procesarMovimiento(articulo, tipo),
            child: Text(tipo == 'entrada' ? 'Agregar' : 'Retirar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarMovimiento(Articulo articulo, String tipo) async {
    final cantidad = int.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      _mostrarError('Cantidad inválida');
      return;
    }

    if (tipo == 'salida' && articulo.stock < cantidad) {
      _mostrarError('Stock insuficiente');
      return;
    }

    try {
      final inventoryProvider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      
      if (tipo == 'entrada') {
        await inventoryProvider.incrementarStock(articulo.firebaseId!, cantidad);
        _mostrarExito('Se agregaron $cantidad unidades al stock');
      } else {
        await inventoryProvider.decrementarStock(articulo.firebaseId!, cantidad);
        _mostrarExito('Se retiraron $cantidad unidades del stock');
      }
      
      Navigator.pop(context); // Cerrar diálogo
      Navigator.pop(context); // Cerrar bottom sheet
      
    } catch (e) {
      _mostrarError('Error al procesar movimiento: $e');
    }
  }

  void _verDetalles(Articulo articulo) {
    Navigator.pop(context); // Cerrar bottom sheet
    // Navegar a pantalla de detalles del artículo
    Navigator.pushNamed(
      context,
      '/editar-articulo',
      arguments: {
        'empresaId': widget.empresaId,
        'articuloId': articulo.firebaseId,
      },
    );
  }

  void _mostrarArticuloNoEncontrado(String codigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Artículo No Encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('No se encontró ningún artículo con el código: $codigo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarCrearArticulo(codigo);
            },
            child: const Text('Crear Artículo'),
          ),
        ],
      ),
    );
  }

  void _mostrarCrearArticulo(String codigo) {
    // Navegar a pantalla de crear artículo con el código pre-rellenado
    Navigator.pushNamed(
      context,
      '/agregar-articulo',
      arguments: {
        'empresaId': widget.empresaId,
        'codigoPredefinido': codigo,
      },
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: _getAppBarColor(),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off, color: Colors.grey),
            onPressed: () {
              // TODO: Implementar toggle de flash cuando esté disponible en la versión actual
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () {
              // TODO: Implementar cambio de cámara cuando esté disponible en la versión actual
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _procesarCodigo(code);
                }
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Procesando código...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          // Overlay con instrucciones
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getInstructions(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case ScannerMode.entrada:
        return 'Escáner - Entradas';
      case ScannerMode.salida:
        return 'Escáner - Salidas';
      case ScannerMode.busqueda:
        return 'Escáner - Búsqueda';
    }
  }

  Color _getAppBarColor() {
    switch (widget.mode) {
      case ScannerMode.entrada:
        return Colors.green;
      case ScannerMode.salida:
        return Colors.red;
      case ScannerMode.busqueda:
        return Colors.blue;
    }
  }

  String _getInstructions() {
    switch (widget.mode) {
      case ScannerMode.entrada:
        return 'Escanea el código de barras para agregar stock al inventario';
      case ScannerMode.salida:
        return 'Escanea el código de barras para retirar stock del inventario';
      case ScannerMode.busqueda:
        return 'Escanea el código de barras para buscar información del artículo';
    }
  }
}
