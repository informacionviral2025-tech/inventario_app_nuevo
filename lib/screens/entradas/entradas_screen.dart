// lib/screens/entradas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/articulo.dart';
import '../../providers/unified_inventory_provider.dart';
import '../../services/entradas_service.dart';
import '../../widgets/etiqueta_editable_widget.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EntradasScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const EntradasScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _EntradasScreenState createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final EntradasService _entradasService = EntradasService();

  List<Map<String, dynamic>> _carritoEntradas = [];

  // Configuración de etiquetas
  double etiquetaAncho = 300;
  double etiquetaAlto = 150;
  Color etiquetaFondo = Colors.white;
  Color etiquetaTexto = Colors.black;
  Color etiquetaBarras = Colors.black;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
      provider.setEmpresa(widget.empresaId, widget.empresaNombre);
      provider.loadArticulos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cantidadController.dispose();
    super.dispose();
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
                labelText: 'Cantidad a agregar',
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
            onPressed: () {
              final cantidad = int.tryParse(_cantidadController.text) ?? 0;
              if (cantidad <= 0) return;
              setState(() {
                _carritoEntradas.add({
                  'articulo': articulo,
                  'cantidad': cantidad,
                });
              });
              _cantidadController.clear();
              Navigator.pop(context);
              _editarEtiqueta(articulo, cantidad);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _editarEtiqueta(Articulo articulo, int cantidad) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Configurar Etiqueta'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < cantidad; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: EtiquetaEditableWidget(
                      codigoArticulo: articulo.codigoBarras ?? articulo.id!,
                      nombreArticulo: articulo.nombre,
                      empresa: widget.empresaNombre,
                      ancho: etiquetaAncho,
                      alto: etiquetaAlto,
                      colorFondo: etiquetaFondo,
                      colorTexto: etiquetaTexto,
                      colorBarras: etiquetaBarras,
                    ),
                  ),
                const SizedBox(height: 16),
                _sliderConfigDialog('Ancho', etiquetaAncho, 100, 400, (v) => setStateDialog(() => etiquetaAncho = v)),
                _sliderConfigDialog('Alto', etiquetaAlto, 100, 400, (v) => setStateDialog(() => etiquetaAlto = v)),
                _colorPickerDialog('Fondo', etiquetaFondo, (v) => setStateDialog(() => etiquetaFondo = v)),
                _colorPickerDialog('Texto', etiquetaTexto, (v) => setStateDialog(() => etiquetaTexto = v)),
                _colorPickerDialog('Barras', etiquetaBarras, (v) => setStateDialog(() => etiquetaBarras = v)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la funcionalidad de imprimir
                Navigator.pop(context);
              },
              child: const Text('Imprimir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderConfigDialog(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _colorPickerDialog(String label, Color color, Function(Color) onColorChanged) {
    return Row(
      children: [
        Text('$label: '),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            Color? picked = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Seleccionar color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: color,
                    onColorChanged: (c) => Navigator.pop(context, c),
                  ),
                ),
              ),
            );
            if (picked != null) onColorChanged(picked);
          },
          child: Container(width: 24, height: 24, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entradas de Inventario'),
        backgroundColor: Colors.green.shade600,
        actions: [
          if (_carritoEntradas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _mostrarCarrito,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar artículo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
                provider.setSearchQuery(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<UnifiedInventoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.error != null) return Center(child: Text('Error: ${provider.error}'));
                if (provider.articulos.isEmpty) return const Center(child: Text('No se encontraron artículos'));
                return ListView.builder(
                  itemCount: provider.articulos.length,
                  itemBuilder: (context, index) {
                    final articulo = provider.articulos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(articulo.nombre),
                        subtitle: Text('Stock: ${articulo.stock}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () => _agregarAlCarrito(articulo),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
              Text('Carrito de Entradas (${_carritoEntradas.length})', style: Theme.of(context).textTheme.headlineSmall),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _carritoEntradas.length,
                  itemBuilder: (context, index) {
                    final item = _carritoEntradas[index];
                    final articulo = item['articulo'] as Articulo;
                    return Card(
                      child: ListTile(
                        title: Text(articulo.nombre),
                        subtitle: Text('Cantidad: ${item['cantidad']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _carritoEntradas.removeAt(index));
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
