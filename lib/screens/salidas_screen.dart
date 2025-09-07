// lib/screens/salidas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/articulo.dart';
import '../../providers/inventory_provider.dart';
import '../../services/salidas_service.dart';
import 'albaran_editor_screen.dart';

class SalidasScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const SalidasScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _SalidasScreenState createState() => _SalidasScreenState();
}

class _SalidasScreenState extends State<SalidasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final SalidasService _salidasService = SalidasService();

  List<Map<String, dynamic>> _carritoSalidas = [];
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.initializeService(widget.empresaId);
      provider.loadArticulos(widget.empresaId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cantidadController.dispose();
    _motivoController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scannerController = MobileScannerController();
    });
  }

  void _stopScanning() {
    _scannerController?.dispose();
    setState(() {
      _isScanning = false;
      _scannerController = null;
    });
  }

  void _onQRCodeScanned(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      _stopScanning();
      _buscarPorCodigoBarras(code);
    }
  }

  void _buscarPorCodigoBarras(String codigo) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    provider.searchArticulos(codigo, widget.empresaId);
  }

  void _agregarAlCarrito(Articulo articulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${articulo.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock disponible: ${articulo.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad a dar de baja',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _confirmarAgregarAlCarrito(articulo);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _confirmarAgregarAlCarrito(Articulo articulo) {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    final motivo = _motivoController.text.trim();

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una cantidad válida')),
      );
      return;
    }

    if (cantidad > articulo.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay suficiente stock')),
      );
      return;
    }

    setState(() {
      _carritoSalidas.add({
        'articulo': articulo,
        'cantidad': cantidad,
        'motivo': motivo.isEmpty ? 'Salida de inventario' : motivo,
      });
    });

    _cantidadController.clear();
    _motivoController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${articulo.nombre} agregado al carrito')),
    );
  }

  void _eliminarDelCarrito(int index) {
    setState(() {
      _carritoSalidas.removeAt(index);
    });
  }

  void _procesarSalidas() {
    if (_carritoSalidas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    // Preparar mapas de artículos
    final Map<String, int> articulosMap = {};
    final Map<String, String> nombresMap = {};
    for (var item in _carritoSalidas) {
      final articulo = item['articulo'] as Articulo;
      final cantidad = item['cantidad'] as int;
      articulosMap[articulo.id!] = cantidad;
      nombresMap[articulo.id!] = articulo.nombre;
    }

    // Abrir editor de albarán
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbaranEditorScreen(
          empresaNombre: widget.empresaNombre,
          articulos: articulosMap,
          nombresArticulos: nombresMap,
        ),
      ),
    ).then((_) {
      // Limpiar carrito después de generar albarán
      setState(() {
        _carritoSalidas.clear();
      });
      // Recargar artículos
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.loadArticulos(widget.empresaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salidas de Inventario'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (_carritoSalidas.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: _mostrarCarrito,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${_carritoSalidas.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y escaneo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por código, descripción...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final provider =
                          Provider.of<InventoryProvider>(context, listen: false);
                      provider.searchArticulos(value, widget.empresaId);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear código de barras',
                ),
              ],
            ),
          ),

          // Lista de artículos o scanner
          Expanded(
            child: _isScanning ? _buildScanner() : _buildArticulosList(),
          ),
        ],
      ),
      floatingActionButton: _carritoSalidas.isNotEmpty
          ? FloatingActionButton(
              onPressed: _procesarSalidas,
              backgroundColor: Colors.red.shade600,
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildScanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onQRCodeScanned,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _stopScanning,
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticulosList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.error != null)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                ElevatedButton(
                  onPressed: () => provider.loadArticulos(widget.empresaId),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        if (provider.articulos.isEmpty)
          return const Center(child: Text('No se encontraron artículos'));

        return ListView.builder(
          itemCount: provider.articulos.length,
          itemBuilder: (context, index) {
            final articulo = provider.articulos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(articulo.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock: ${articulo.stock}'),
                    if (articulo.codigoBarras != null)
                      Text('Código: ${articulo.codigoBarras}'),
                  ],
                ),
                trailing: articulo.stock > 0
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _agregarAlCarrito(articulo),
                      )
                    : const Icon(Icons.warning, color: Colors.orange),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Carrito de Salidas (${_carritoSalidas.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _carritoSalidas.length,
                  itemBuilder: (context, index) {
                    final item = _carritoSalidas[index];
                    final articulo = item['articulo'] as Articulo;
                    return Card(
                      child: ListTile(
                        title: Text(articulo.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${item['cantidad']}'),
                            Text('Motivo: ${item['motivo']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _eliminarDelCarrito(index);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _procesarSalidas();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generar Albarán'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
