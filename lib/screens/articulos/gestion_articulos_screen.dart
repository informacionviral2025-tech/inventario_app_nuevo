import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/articulo.dart';
import '../../services/articulo_service.dart';
import '../../services/proveedor_service.dart';
import 'articulo_form_dialog.dart';
import 'ajustar_stock_dialog.dart';
import '../obra/crear_albaran_screen.dart';

class GestionArticulosScreen extends StatefulWidget {
  final String empresaId;

  const GestionArticulosScreen({Key? key, required this.empresaId})
      : super(key: key);

  @override
  State<GestionArticulosScreen> createState() => _GestionArticulosScreenState();
}

class _GestionArticulosScreenState extends State<GestionArticulosScreen> {
  late final ArticuloService _articuloService;
  late final ProveedorService _proveedorService;

  @override
  void initState() {
    super.initState();
    _articuloService = ArticuloService(widget.empresaId);
    _proveedorService = ProveedorService(widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _agregarArticulo(context),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _escanearCodigoBarras,
          ),
        ],
      ),
      body: StreamBuilder<List<Articulo>>(
        stream: _articuloService.getArticulosActivos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final articulos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: articulos.length,
            itemBuilder: (context, index) {
              return _buildArticuloCard(articulos[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregarArticulo(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Artículo'),
      ),
    );
  }

  Widget _buildArticuloCard(Articulo articulo) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: articulo.stockBajo ? Colors.red : Colors.green,
          child: Text(articulo.stock.toString()),
        ),
        title: Text(articulo.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${articulo.sku ?? articulo.codigoBarras}'),
            Text('Stock: ${articulo.stock} ${articulo.unidadMedida}'),
            Text('Precio: \$${articulo.precio.toStringAsFixed(2)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleArticuloAction(context, articulo, value),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'stock', child: Text('Ajustar Stock')),
            const PopupMenuItem(value: 'albaran', child: Text('Albarán')),
          ],
        ),
      ),
    );
  }

  void _handleArticuloAction(BuildContext context, Articulo articulo, String action) {
    switch (action) {
      case 'edit':
        _editarArticulo(context, articulo);
        break;
      case 'stock':
        _ajustarStock(context, articulo);
        break;
      case 'albaran':
        _crearAlbaran(context, articulo);
        break;
    }
  }

  void _agregarArticulo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ArticuloFormDialog(
        empresaId: widget.empresaId,
        onSave: () => setState(() {}),
      ),
    );
  }

  void _editarArticulo(BuildContext context, Articulo articulo) {
    showDialog(
      context: context,
      builder: (_) => ArticuloFormDialog(
        empresaId: widget.empresaId,
        articulo: articulo,
        onSave: () => setState(() {}),
      ),
    );
  }

  void _ajustarStock(BuildContext context, Articulo articulo) {
    showDialog(
      context: context,
      builder: (_) => AjustarStockDialog(
        articulo: articulo,
        onSave: () => setState(() {}),
      ),
    );
  }

  void _crearAlbaran(BuildContext context, Articulo articulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearAlbaranScreen(
          empresaId: widget.empresaId,
          articulo: articulo,
        ),
      ),
    );
  }

  void _escanearCodigoBarras() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de escaneo próximamente')),
    );
  }
}