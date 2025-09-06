import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../services/barcode_service.dart';

class BarcodeManagementScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const BarcodeManagementScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  State<BarcodeManagementScreen> createState() => _BarcodeManagementScreenState();
}

class _BarcodeManagementScreenState extends State<BarcodeManagementScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final BarcodeService _barcodeService = BarcodeService();
  
  late TabController _tabController;
  List<Map<String, dynamic>> _codigosBarras = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCodigosBarras();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCodigosBarras() async {
    setState(() => _isLoading = true);
    try {
      final codigos = await _firebaseService.getTodosLosCodigosBarras(widget.empresaId);
      setState(() {
        _codigosBarras = codigos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error cargando códigos de barras: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredCodigosBarras {
    if (_searchQuery.isEmpty) return _codigosBarras;
    
    return _codigosBarras.where((item) {
      final articulo = item['articulo'] as Map<String, dynamic>;
      final barcodeInfo = item['codigo_barras'] as BarcodeInfo;
      
      return articulo['codigo'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             articulo['nombre'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             barcodeInfo.data.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Códigos de Barras'),
            Text(
              widget.empresaNombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Todos'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Escanear'),
            Tab(icon: Icon(Icons.print), text: 'Imprimir'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCodigosBarras,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCodigosBarrasTab(),
          _buildEscanearTab(),
          _buildImprimirTab(),
        ],
      ),
    );
  }

  Widget _buildCodigosBarrasTab() {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar artículo o código',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Lista de códigos de barras
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCodigosBarras.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No se encontraron códigos de barras'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCodigosBarras.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCodigosBarras[index];
                        final articulo = item['articulo'] as Map<String, dynamic>;
                        final barcodeInfo = item['codigo_barras'] as BarcodeInfo;
                        
                        return _buildBarcodeCard(articulo, barcodeInfo);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildBarcodeCard(Map<String, dynamic> articulo, BarcodeInfo barcodeInfo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.qr_code, color: Colors.blue),
        title: Text(
          articulo['nombre'] ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${articulo['codigo']}'),
            Text('Stock: ${articulo['stock_actual'] ?? 0}'),
            if (barcodeInfo.lote != null && barcodeInfo.lote!.isNotEmpty)
              Text('Lote: ${barcodeInfo.lote}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mostrar código de barras
                _barcodeService.buildBarcodeWidget(
                  barcodeInfo.data,
                  type: barcodeInfo.type,
                  width: 250,
                  height: 80,
                  showText: true,
                ),
                
                const SizedBox(height: 16),
                
                // Información detallada
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Código de barras:', barcodeInfo.data),
                      _buildInfoRow('Tipo:', barcodeInfo.type),
                      _buildInfoRow('Precio compra:', '\$${articulo['precio_compra']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildInfoRow('Precio venta:', '\$${articulo['precio_venta']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildInfoRow('Categoría:', articulo['categoria'] ?? 'Sin categoría'),
                      if (articulo['proveedor'] != null && articulo['proveedor'].toString().isNotEmpty)
                        _buildInfoRow('Proveedor:', articulo['proveedor']),
                      _buildInfoRow('Generado:', _formatDateTime(barcodeInfo.createdAt)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(barcodeInfo.data),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showBarcodeDialog(articulo, barcodeInfo),
                      icon: const Icon(Icons.fullscreen, size: 18),
                      label: const Text('Ver grande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _regenerateBarcode(articulo),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            width: 120,
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

  Widget _buildEscanearTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Escanear Código de Barras',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Funcionalidad de escáner por implementar'),
          const SizedBox(height: 24),
          
          // Campo para ingresar código manualmente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'O ingresa el código manualmente:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Código de barras',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Implementar búsqueda manual
                        _showSnackBar('Funcionalidad de búsqueda por implementar');
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _buscarPorCodigoBarras(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprimirTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.print, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Imprimir Códigos de Barras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Selecciona los artículos para imprimir sus códigos'),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _imprimirTodos(),
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir Todos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _imprimirSeleccionados(),
                    icon: const Icon(Icons.check_box),
                    label: const Text('Selección Multiple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Vista previa de impresión
        Expanded(
          child: _filteredCodigosBarras.isEmpty
              ? const Center(
                  child: Text('No hay códigos para imprimir'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _filteredCodigosBarras.length,
                  itemBuilder: (context, index) {
                    final item = _filteredCodigosBarras[index];
                    final articulo = item['articulo'] as Map<String, dynamic>;
                    final barcodeInfo = item['codigo_barras'] as BarcodeInfo;
                    
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              articulo['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _barcodeService.buildBarcodeWidget(
                                barcodeInfo.data,
                                type: barcodeInfo.type,
                                width: 150,
                                height: 60,
                                showText: true,
                                textStyle: const TextStyle(fontSize: 8),
                              ),
                            ),
                            Text('Precio: \$${articulo['precio_venta']?.toStringAsFixed(2) ?? '0.00'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Código copiado al portapapeles');
  }

  void _showBarcodeDialog(Map<String, dynamic> articulo, BarcodeInfo barcodeInfo) {
    showDialog(
      context: context,
      builder: (context) => BarcodeDisplayDialog(
        barcodeInfo: barcodeInfo,
        articleName: articulo['nombre'],
      ),
    );
  }

  Future<void> _regenerateBarcode(Map<String, dynamic> articulo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerar Código de Barras'),
        content: Text(
          '¿Estás seguro de que quieres generar un nuevo código de barras para "${articulo['nombre']}"?\n\nEl código anterior quedará en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Regenerar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.addStockConCodigoBarras(
          empresaId: widget.empresaId,
          articuloId: articulo['id'],
          cantidad: 0, // No añadimos stock, solo regeneramos código
          motivo: 'Regeneración de código de barras',
          generarNuevoCodigoBarras: true,
        );
        
        _showSnackBar('Código de barras regenerado exitosamente');
        _loadCodigosBarras(); // Recargar la lista
      } catch (e) {
        _showSnackBar('Error regenerando código: $e', isError: true);
      }
    }
  }

  Future<void> _buscarPorCodigoBarras(String codigo) async {
    try {
      final articulo = await _firebaseService.buscarArticuloPorCodigoBarras(
        widget.empresaId,
        codigo,
      );

      if (articulo != null) {
        _showSnackBar('Artículo encontrado: ${articulo['nombre']}');
        
        // Mostrar detalles del artículo
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Artículo Encontrado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${articulo['nombre']}'),
                Text('Código: ${articulo['codigo']}'),
                Text('Stock: ${articulo['stock_actual']}'),
                Text('Precio: \$${articulo['precio_venta']?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showSnackBar('No se encontró ningún artículo con ese código', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error buscando artículo: $e', isError: true);
    }
  }

  void _imprimirTodos() {
    _showSnackBar('Función de impresión no implementada');
    // Aquí implementarías la lógica para imprimir todos los códigos
  }

  void _imprimirSeleccionados() {
    _showSnackBar('Función de selección múltiple no implementada');
    // Aquí implementarías la lógica para seleccionar y imprimir códigos específicos
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}