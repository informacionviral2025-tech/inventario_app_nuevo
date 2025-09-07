// lib/screens/salidas_inventario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/articulo.dart';
import '../providers/inventory_provider.dart';
import '../services/salidas_service.dart';

class SalidasInventarioScreen extends StatefulWidget {
  final String empresaId;

  const SalidasInventarioScreen({
    Key? key,
    required this.empresaId,
  }) : super(key: key);

  @override
  _SalidasInventarioScreenState createState() => _SalidasInventarioScreenState();
}

class _SalidasInventarioScreenState extends State<SalidasInventarioScreen> {
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

  // --- Métodos de escaneo y carrito de salidas ---
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

  // Métodos de agregar, eliminar y procesar salidas
  void _agregarAlCarrito(Articulo articulo) { /* ...igual que tu código original... */ }
  void _confirmarAgregarAlCarrito(Articulo articulo) { /* ...igual */ }
  void _eliminarDelCarrito(int index) { /* ...igual */ }
  void _procesarSalidas() { /* ...igual */ }
  Future<void> _ejecutarSalidas() { /* ...igual */ }

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
          // Barra de búsqueda y scanner
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar artículo...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final provider = Provider.of<InventoryProvider>(context, listen: false);
                      provider.searchArticulos(value, widget.empresaId);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear código',
                ),
              ],
            ),
          ),

          // Scanner o lista de artículos
          Expanded(
            child: _isScanning
                ? _buildScanner()
                : _buildArticulosList(),
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

  Widget _buildScanner() { /* ...igual que tu código original... */ }
  Widget _buildArticulosList() { /* ...igual que tu código original... */ }
  void _mostrarCarrito() { /* ...igual que tu código original... */ }
}
