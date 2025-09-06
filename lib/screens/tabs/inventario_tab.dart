import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../articles_list_screen.dart';
import '../add_article_screen.dart';
import '../../models/albaran_traspasos.dart';
import '../albaranes/albaran_traspaso_list_screen.dart';
import '../albaranes/lista_albaranes_screen.dart';
import '../entradas/entradas_screen.dart';

class InventarioTab extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const InventarioTab({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _InventarioTabState createState() => _InventarioTabState();
}

class _InventarioTabState extends State<InventarioTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String? empresaId;
  String? empresaNombre;
  String _searchQuery = '';
  String _filtroStock = 'todos';
  String _sortBy = 'nombre';
  bool _sortAsc = true;
  bool _showCompactView = false;

  void _mostrarMenuAlbaranes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gestión de Albaranes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long, color: Colors.purple.shade700),
              ),
              title: const Text('Albaranes de Proveedor'),
              subtitle: const Text('Entrada de mercancía con albarán'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaAlbaranesScreen(
                      empresaId: widget.empresaId,
                      empresaNombre: widget.empresaNombre,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.swap_horiz, color: Colors.orange.shade700),
              ),
              title: const Text('Albaranes de Traspaso'),
              subtitle: const Text('Movimientos internos entre almacenes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbaranTraspasoListScreen(
                      empresaId: widget.empresaId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    empresaId = widget.empresaId;
    empresaNombre = widget.empresaNombre;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickActions(),
          _buildSearchAndFilters(),
          Expanded(child: _buildInventarioList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNuevoArticulo,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Artículo'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Inventario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.empresaNombre,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _showCompactView = !_showCompactView);
                  },
                  icon: Icon(
                    _showCompactView ? Icons.view_list : Icons.view_module,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final articulos = snapshot.data!.docs;
        final totalArticulos = articulos.length;
        final articulosConStock = articulos.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['stock'] ?? 0) > 0;
        }).length;
        final articulosSinStock = totalArticulos - articulosConStock;
        final articulosStockBajo = articulos.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = data['stock'] ?? 0;
          final stockMinimo = data['stockMinimo'] ?? 0;
          return stock <= stockMinimo && stockMinimo > 0 && stock > 0;
        }).length;

        return Row(
          children: [
            _buildStatCard('Total', totalArticulos.toString(), Icons.inventory, Colors.white),
            const SizedBox(width: 8),
            _buildStatCard('Con Stock', articulosConStock.toString(), Icons.check_circle, Colors.green.shade200),
            const SizedBox(width: 8),
            _buildStatCard('Sin Stock', articulosSinStock.toString(), Icons.error, Colors.red.shade200),
            const SizedBox(width: 8),
            _buildStatCard('Stock Bajo', articulosStockBajo.toString(), Icons.warning, Colors.orange.shade200),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Albaranes',
                  'Gestión de albaranes',
                  Icons.receipt_long,
                  Colors.purple.shade600,
                  () => _mostrarMenuAlbaranes(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Entradas',
                  'Recibir mercancía',
                  Icons.input,
                  Colors.green.shade600,
                  () => _navegarAEntradas(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Salidas',
                  'Registrar salidas',
                  Icons.output,
                  Colors.red.shade600,
                  () => _navegarASalidas(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Albaranes',
                  'Traspasos internos',
                  Icons.receipt_long,
                  Colors.purple.shade600,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlbaranTraspasoListScreen(
                          empresaId: widget.empresaId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar artículos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroStock,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'con_stock', child: Text('Con stock')),
                    DropdownMenuItem(value: 'sin_stock', child: Text('Sin stock')),
                    DropdownMenuItem(value: 'stock_bajo', child: Text('Stock bajo')),
                  ],
                  onChanged: (value) {
                    setState(() => _filtroStock = value!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Ordenar por',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'nombre', child: Text('Nombre')),
                    DropdownMenuItem(value: 'stock', child: Text('Stock')),
                    DropdownMenuItem(value: 'precio', child: Text('Precio')),
                    DropdownMenuItem(value: 'fecha', child: Text('Fecha')),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() => _sortAsc = !_sortAsc);
                },
                icon: Icon(
                  _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blue.shade700,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay artículos en inventario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer artículo para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _mostrarDialogoNuevoArticulo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Artículo'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron artículos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros filtros de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getArticulosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar inventario',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final articulos = _filtrarYOrdenarArticulos(snapshot.data!.docs);

        if (articulos.isEmpty) {
          return _buildNoResultsState();
        }

        return _showCompactView
            ? _buildCompactList(articulos)
            : _buildDetailedList(articulos);
      },
    );
  }

  Widget _buildDetailedList(List<QueryDocumentSnapshot> articulos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articulos.length,
      itemBuilder: (context, index) {
        final articulo = articulos[index];
        final data = articulo.data() as Map<String, dynamic>;
        return _buildArticuloCard(articulo.id, data);
      },
    );
  }

  Widget _buildCompactList(List<QueryDocumentSnapshot> articulos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: articulos.length,
      itemBuilder: (context, index) {
        final articulo = articulos[index];
        final data = articulo.data() as Map<String, dynamic>;
        return _buildCompactArticuloTile(articulo.id, data);
      },
    );
  }

  Widget _buildCompactArticuloTile(String articuloId, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final stock = data['stock'] ?? 0;
    final precio = data['precio'] ?? 0.0;
    final stockMinimo = data['stockMinimo'] ?? 0;

    final bool stockBajo = stock <= stockMinimo && stockMinimo > 0;
    final bool sinStock = stock <= 0;

    Color stockColor = sinStock
        ? Colors.red
        : stockBajo
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.inventory_2,
            color: Colors.blue.shade700,
            size: 18,
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: stockColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Stock: $stock',
                style: TextStyle(
                  color: stockColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${precio.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _entradaRapida(articuloId, data),
              icon: const Icon(Icons.add, size: 16),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                minimumSize: const Size(28, 28),
              ),
            ),
            IconButton(
              onPressed: stock > 0 ? () => _salidaRapida(articuloId, data) : null,
              icon: const Icon(Icons.remove, size: 16),
              style: IconButton.styleFrom(
                backgroundColor: stock > 0 ? Colors.red.shade50 : Colors.grey.shade100,
                minimumSize: const Size(28, 28),
              ),
            ),
          ],
        ),
        onTap: () => _verDetalleArticulo(articuloId, data),
      ),
    );
  }

  Widget _buildArticuloCard(String articuloId, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final stock = data['stock'] ?? 0;
    final precio = data['precio'] ?? 0.0;
    final stockMinimo = data['stockMinimo'] ?? 0;

    final bool stockBajo = stock <= stockMinimo && stockMinimo > 0;
    final bool sinStock = stock <= 0;

    Color stockColor;
    IconData stockIcon;

    if (sinStock) {
      stockColor = Colors.red;
      stockIcon = Icons.warning;
    } else if (stockBajo) {
      stockColor = Colors.orange;
      stockIcon = Icons.warning_amber;
    } else {
      stockColor = Colors.green;
      stockIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _verDetalleArticulo(articuloId, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (data['descripcion'] != null && data['descripcion'].toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            data['descripcion'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _onMenuSelected(value, articuloId, data),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'ver',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 12),
                            Text('Ver detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'entrada',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.green, size: 18),
                            SizedBox(width: 12),
                            Text('Entrada rápida'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'salida',
                        child: Row(
                          children: [
                            Icon(Icons.remove, color: Colors.red, size: 18),
                            SizedBox(width: 12),
                            Text('Salida rápida'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 12),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: stockColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(stockIcon, color: stockColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: $stock',
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _entradaRapida(articuloId, data),
                        icon: Icon(Icons.add, color: Colors.green.shade600, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          minimumSize: const Size(32, 32),
                        ),
                        tooltip: 'Entrada rápida',
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: stock > 0 ? () => _salidaRapida(articuloId, data) : null,
                        icon: Icon(
                          Icons.remove,
                          color: stock > 0 ? Colors.red.shade600 : Colors.grey.shade400,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: stock > 0 ? Colors.red.shade50 : Colors.grey.shade100,
                          minimumSize: const Size(32, 32),
                        ),
                        tooltip: 'Salida rápida',
                      ),
                    ],
                  ),
                ],
              ),
              if (stockBajo && !sinStock) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Stock bajo (mínimo: $stockMinimo)',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // MÉTODOS AUXILIARES

  Stream<QuerySnapshot> _getArticulosStream() {
    return _firestore
        .collection('empresas')
        .doc(widget.empresaId)
        .collection('articulos')
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filtrarYOrdenarArticulos(List<QueryDocumentSnapshot> articulos) {
    var filtered = articulos.where((articulo) {
      final data = articulo.data() as Map<String, dynamic>;
      final nombre = (data['nombre'] ?? '').toString().toLowerCase();
      final descripcion = (data['descripcion'] ?? '').toString().toLowerCase();
      final stock = data['stock'] ?? 0;
      final stockMinimo = data['stockMinimo'] ?? 0;

      if (_searchQuery.isNotEmpty) {
        if (!nombre.contains(_searchQuery) && !descripcion.contains(_searchQuery)) {
          return false;
        }
      }

      switch (_filtroStock) {
        case 'con_stock':
          return stock > 0;
        case 'sin_stock':
          return stock <= 0;
        case 'stock_bajo':
          return stock <= stockMinimo && stockMinimo > 0;
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      int comparison = 0;

      switch (_sortBy) {
        case 'nombre':
          comparison = (dataA['nombre'] ?? '').toString().compareTo((dataB['nombre'] ?? '').toString());
          break;
        case 'stock':
          comparison = (dataA['stock'] ?? 0).compareTo(dataB['stock'] ?? 0);
          break;
        case 'precio':
          comparison = (dataA['precio'] ?? 0.0).compareTo(dataB['precio'] ?? 0.0);
          break;
        case 'fecha':
          final fechaA = dataA['fechaCreacion'] as Timestamp?;
          final fechaB = dataB['fechaCreacion'] as Timestamp?;
          if (fechaA != null && fechaB != null) {
            comparison = fechaA.compareTo(fechaB);
          }
          break;
      }

      return _sortAsc ? comparison : -comparison;
    });

    return filtered;
  }

  void _navegarAEntradas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntradasScreen(
          empresaId: widget.empresaId,
          empresaNombre: widget.empresaNombre,
        ),
      ),
    );
  }

  void _navegarASalidas() {
    Navigator.pushNamed(
      context,
      '/salidas_inventario',
      arguments: {
        'empresaId': widget.empresaId,
        'empresaNombre': widget.empresaNombre,
      },
    );
  }

  void _onMenuSelected(String action, String articuloId, Map<String, dynamic> data) {
    switch (action) {
      case 'ver':
        _verDetalleArticulo(articuloId, data);
        break;
      case 'editar':
        _editarArticulo(articuloId, data);
        break;
      case 'entrada':
        _entradaRapida(articuloId, data);
        break;
      case 'salida':
        _salidaRapida(articuloId, data);
        break;
      case 'eliminar':
        _confirmarEliminarArticulo(articuloId, data);
        break;
    }
  }

  void _verDetalleArticulo(String articuloId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetalleRow('Descripción:', data['descripcion'] ?? 'N/A'),
              _buildDetalleRow('Stock actual:', (data['stock'] ?? 0).toString()),
              _buildDetalleRow('Stock mínimo:', (data['stockMinimo'] ?? 0).toString()),
              _buildDetalleRow('Precio:', '\$${data['precio'] ?? 0}'),
              if (data['fechaCreacion'] != null)
                _buildDetalleRow(
                    'Fecha creación:', (data['fechaCreacion'] as Timestamp).toDate().toString().split(' ')[0]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editarArticulo(articuloId, data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _entradaRapida(String articuloId, Map<String, dynamic> data) {
    final cantidadController = TextEditingController();
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Expanded(child: Text('Entrada: ${data['nombre']}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Stock actual: ${data['stock'] ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Cantidad a agregar *',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.add, color: Colors.green.shade600),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
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
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              if (cantidad > 0) {
                Navigator.pop(context);
                _procesarEntradaRapida(articuloId, data, cantidad, observacionesController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _salidaRapida(String articuloId, Map<String, dynamic> data) {
    final cantidadController = TextEditingController();
    final observacionesController = TextEditingController();
    final stockActual = data['stock'] ?? 0;

    if (stockActual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay stock disponible para salida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.remove_circle, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Expanded(child: Text('Salida: ${data['nombre']}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Stock disponible: $stockActual',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Cantidad a retirar *',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.remove, color: Colors.red.shade600),
                helperText: 'Máximo: $stockActual',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
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
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              if (cantidad > 0 && cantidad <= stockActual) {
                Navigator.pop(context);
                _procesarSalidaRapida(articuloId, data, cantidad, observacionesController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cantidad inválida'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarEntradaRapida(String articuloId, Map<String, dynamic> data, int cantidad, String observaciones) async {
    try {
      final batch = _firestore.batch();

      final nuevoStock = (data['stock'] ?? 0) + cantidad;
      final articuloRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articuloId);

      batch.update(articuloRef, {
        'stock': nuevoStock,
        'ultimaModificacion': FieldValue.serverTimestamp(),
      });

      final movimientoRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('movimientos')
          .doc();

      batch.set(movimientoRef, {
        'tipoMovimiento': 'entrada',
        'tipo': 'ajuste_positivo',
        'articuloId': articuloId,
        'articuloNombre': data['nombre'],
        'cantidad': cantidad,
        'precio': data['precio'] ?? 0,
        'stockAnterior': data['stock'] ?? 0,
        'stockNuevo': nuevoStock,
        'fecha': FieldValue.serverTimestamp(),
        'observaciones': observaciones.isNotEmpty ? observaciones : 'Entrada rápida desde inventario',
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrada registrada: +$cantidad ${data['nombre']}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () => _verDetalleArticulo(articuloId, data),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _procesarSalidaRapida(String articuloId, Map<String, dynamic> data, int cantidad, String observaciones) async {
    try {
      final batch = _firestore.batch();

      final nuevoStock = (data['stock'] ?? 0) - cantidad;
      final articuloRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articuloId);

      batch.update(articuloRef, {
        'stock': nuevoStock,
        'ultimaModificacion': FieldValue.serverTimestamp(),
      });

      final movimientoRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('movimientos')
          .doc();

      batch.set(movimientoRef, {
        'tipoMovimiento': 'salida',
        'tipo': 'ajuste_negativo',
        'articuloId': articuloId,
        'articuloNombre': data['nombre'],
        'cantidad': cantidad,
        'precio': data['precio'] ?? 0,
        'stockAnterior': data['stock'] ?? 0,
        'stockNuevo': nuevoStock,
        'fecha': FieldValue.serverTimestamp(),
        'observaciones': observaciones.isNotEmpty ? observaciones : 'Salida rápida desde inventario',
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salida registrada: -$cantidad ${data['nombre']}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () => _verDetalleArticulo(articuloId, data),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _editarArticulo(String articuloId, Map<String, dynamic> data) {
    final nombreController = TextEditingController(text: data['nombre'] ?? '');
    final descripcionController = TextEditingController(text: data['descripcion'] ?? '');
    final stockMinimoController = TextEditingController(text: (data['stockMinimo'] ?? 0).toString());
    final precioController = TextEditingController(text: (data['precio'] ?? 0.0).toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Editar Artículo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockMinimoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Stock mínimo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: precioController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nombreController.text.trim().isNotEmpty) {
                        Navigator.pop(context);
                        _actualizarArticulo(
                          articuloId,
                          nombreController.text.trim(),
                          descripcionController.text.trim(),
                          int.tryParse(stockMinimoController.text) ?? 0,
                          double.tryParse(precioController.text) ?? 0.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarArticulo(
    String articuloId,
    String nombre,
    String descripcion,
    int stockMinimo,
    double precio,
  ) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articuloId)
          .update({
        'nombre': nombre,
        'descripcion': descripcion,
        'stockMinimo': stockMinimo,
        'precio': precio,
        'ultimaModificacion': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artículo "$nombre" actualizado'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _confirmarEliminarArticulo(String articuloId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Artículo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de eliminar "${data['nombre']}"?'),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _eliminarArticulo(articuloId, data);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarArticulo(String articuloId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articuloId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artículo "${data['nombre']}" eliminado'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _mostrarDialogoNuevoArticulo() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final stockController = TextEditingController();
    final stockMinimoController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_box, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Nuevo Artículo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Stock inicial',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add_circle_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: stockMinimoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Stock mínimo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nombreController.text.trim().isNotEmpty) {
                        Navigator.pop(context);
                        _crearArticulo(
                          nombreController.text.trim(),
                          descripcionController.text.trim(),
                          int.tryParse(stockController.text) ?? 0,
                          int.tryParse(stockMinimoController.text) ?? 0,
                          double.tryParse(precioController.text) ?? 0.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearArticulo(
    String nombre,
    String descripcion,
    int stock,
    int stockMinimo,
    double precio,
  ) async {
    try {
      final articuloData = {
        'nombre': nombre,
        'descripcion': descripcion,
        'stock': stock,
        'stockMinimo': stockMinimo,
        'precio': precio,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'ultimaModificacion': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .add(articuloData);

      if (stock > 0) {
        await _firestore
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('movimientos')
            .add({
          'tipoMovimiento': 'entrada',
          'tipo': 'stock_inicial',
          'articuloId': docRef.id,
          'articuloNombre': nombre,
          'cantidad': stock,
          'precio': precio,
          'stockAnterior': 0,
          'stockNuevo': stock,
          'fecha': FieldValue.serverTimestamp(),
          'observaciones': 'Stock inicial al crear artículo',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artículo "$nombre" creado exitosamente'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear artículo: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_empty, color: Colors.orange.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Próximamente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '$feature estará disponible en futuras versiones.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}