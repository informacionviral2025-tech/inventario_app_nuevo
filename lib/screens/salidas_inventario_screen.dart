import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SalidasInventarioScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const SalidasInventarioScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _SalidasInventarioScreenState createState() => _SalidasInventarioScreenState();
}

class _SalidasInventarioScreenState extends State<SalidasInventarioScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  
  // Controllers para búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Estado de carga
  bool _isLoading = false;

  // Filtros
  String _selectedPeriodo = 'todo';
  String _selectedTipoSalida = 'todas';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salidas de Inventario'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.add_shopping_cart),
              text: 'Nueva Salida',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Historial',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNuevaSalidaTab(),
          _buildHistorialTab(),
        ],
      ),
    );
  }

  Widget _buildNuevaSalidaTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTipoSalidaSelector(),
            const SizedBox(height: 16),
            _buildClienteSelector(),
            const SizedBox(height: 16),
            _buildArticulosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.red.shade700, Colors.red.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.remove_shopping_cart,
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
                    'Registrar Salida',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ventas, devoluciones y ajustes negativos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoSalidaSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Tipo de Salida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildTipoChip('venta', 'Venta', Icons.point_of_sale, Colors.green),
                _buildTipoChip('devolucion_proveedor', 'Dev. Proveedor', Icons.undo, Colors.orange),
                _buildTipoChip('ajuste_negativo', 'Ajuste -', Icons.remove_circle, Colors.red),
                _buildTipoChip('consumo_interno', 'Consumo', Icons.home_work, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedTipoSalida == value;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTipoSalida = selected ? value : 'venta';
        });
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: color,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildClienteSelector() {
    // Solo mostrar selector de cliente para ventas
    if (_selectedTipoSalida != 'venta') {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('empresas')
                  .doc(widget.empresaId)
                  .collection('clientes')
                  .where('activo', isEqualTo: true)
                  .orderBy('nombre')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final clientes = snapshot.data!.docs;
                
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Seleccionar cliente',
                  ),
                  items: clientes.map((cliente) {
                    final data = cliente.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: cliente.id,
                      child: Text(data['nombre'] ?? 'Sin nombre'),
                    );
                  }).toList(),
                  onChanged: (clienteId) {
                    // Guardar cliente seleccionado
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _mostrarDialogoNuevoCliente(),
              icon: const Icon(Icons.add),
              label: const Text('Crear nuevo cliente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Artículos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _mostrarDialogoSeleccionarArticulo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de artículos seleccionados
            _buildArticulosSeleccionados(),
          ],
        ),
      ),
    );
  }

  Widget _buildArticulosSeleccionados() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Artículo', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 48),
              ],
            ),
          ),
          // Aquí irían los artículos seleccionados
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'No hay artículos seleccionados',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildFiltrosHistorial(),
          Expanded(
            child: _buildListaHistorial(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosHistorial() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Buscador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por artículo, cliente o referencia...',
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
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
            const SizedBox(height: 12),
            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriodo,
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'hoy', child: Text('Hoy')),
                      DropdownMenuItem(value: 'semana', child: Text('Esta semana')),
                      DropdownMenuItem(value: 'mes', child: Text('Este mes')),
                      DropdownMenuItem(value: 'todo', child: Text('Todo el tiempo')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPeriodo = value!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTipoSalida,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todas', child: Text('Todas')),
                      DropdownMenuItem(value: 'venta', child: Text('Ventas')),
                      DropdownMenuItem(value: 'devolucion_proveedor', child: Text('Devoluciones')),
                      DropdownMenuItem(value: 'ajuste_negativo', child: Text('Ajustes -')),
                      DropdownMenuItem(value: 'consumo_interno', child: Text('Consumos')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedTipoSalida = value!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaHistorial() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getMovimientosSalida(),
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
                  'Error al cargar historial',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                ),
              ],
            ),
          );
        }

        final movimientos = snapshot.data?.docs ?? [];
        
        if (movimientos.isEmpty) {
          return _buildEmptyHistorial();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final movimiento = movimientos[index];
            final data = movimiento.data() as Map<String, dynamic>;
            return _buildMovimientoCard(movimiento.id, data);
          },
        );
      },
    );
  }

  Widget _buildEmptyHistorial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay salidas registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Las salidas aparecerán aquí cuando se registren',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(String movimientoId, Map<String, dynamic> data) {
    final tipo = data['tipo'] ?? '';
    final fecha = (data['fecha'] as Timestamp?)?.toDate();
    final cantidad = data['cantidad'] ?? 0;
    final articulo = data['articuloNombre'] ?? 'Artículo desconocido';
    final cliente = data['clienteNombre'] ?? '';
    
    Color tipoColor;
    IconData tipoIcon;
    String tipoLabel;
    
    switch (tipo) {
      case 'venta':
        tipoColor = Colors.green;
        tipoIcon = Icons.point_of_sale;
        tipoLabel = 'Venta';
        break;
      case 'devolucion_proveedor':
        tipoColor = Colors.orange;
        tipoIcon = Icons.undo;
        tipoLabel = 'Dev. Proveedor';
        break;
      case 'ajuste_negativo':
        tipoColor = Colors.red;
        tipoIcon = Icons.remove_circle;
        tipoLabel = 'Ajuste -';
        break;
      case 'consumo_interno':
        tipoColor = Colors.blue;
        tipoIcon = Icons.home_work;
        tipoLabel = 'Consumo';
        break;
      default:
        tipoColor = Colors.grey;
        tipoIcon = Icons.help_outline;
        tipoLabel = 'Desconocido';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tipoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(tipoIcon, color: tipoColor),
        ),
        title: Text(
          articulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tipoColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tipoLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cantidad: ${cantidad.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (cliente.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Cliente: $cliente'),
            ],
            if (fecha != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(fecha),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'ver':
                _verDetalleMovimiento(movimientoId, data);
                break;
              case 'eliminar':
                _confirmarEliminarMovimiento(movimientoId, data);
                break;
            }
          },
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
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODOS AUXILIARES

  Stream<QuerySnapshot> _getMovimientosSalida() {
    Query query = _firestore
        .collection('empresas')
        .doc(widget.empresaId)
        .collection('movimientos')
        .where('tipoMovimiento', isEqualTo: 'salida');

    // Filtrar por tipo de salida
    if (_selectedTipoSalida != 'todas') {
      query = query.where('tipo', isEqualTo: _selectedTipoSalida);
    }

    // Filtrar por período
    if (_selectedPeriodo != 'todo') {
      final now = DateTime.now();
      DateTime? startDate;
      
      switch (_selectedPeriodo) {
        case 'hoy':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'semana':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'mes':
          startDate = DateTime(now.year, now.month, 1);
          break;
      }
      
      if (startDate != null) {
        query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
    }

    return query.orderBy('fecha', descending: true).snapshots();
  }

  void _mostrarDialogoSeleccionarArticulo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Seleccionar Artículo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar artículo...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Implementar búsqueda de artículos
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('empresas')
                      .doc(widget.empresaId)
                      .collection('articulos')
                      .where('stock', isGreaterThan: 0)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final articulos = snapshot.data!.docs;
                    
                    return ListView.builder(
                      itemCount: articulos.length,
                      itemBuilder: (context, index) {
                        final articulo = articulos[index];
                        final data = articulo.data() as Map<String, dynamic>;
                        
                        return ListTile(
                          title: Text(data['nombre'] ?? 'Sin nombre'),
                          subtitle: Text('Stock: ${data['stock']} | Precio: \$${data['precio']}'),
                          onTap: () {
                            Navigator.pop(context);
                            _mostrarDialogoCantidad(articulo.id, data);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoCantidad(String articuloId, Map<String, dynamic> articuloData) {
    final cantidadController = TextEditingController();
    final precioController = TextEditingController(
      text: (articuloData['precio'] ?? 0).toString(),
    );
    final stockDisponible = articuloData['stock'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${articuloData['nombre']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock disponible: $stockDisponible'),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Cantidad a retirar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.remove),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: precioController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio unitario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
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
            onPressed: () {
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              if (cantidad > 0 && cantidad <= stockDisponible) {
                Navigator.pop(context);
                _procesarSalida(articuloId, articuloData, cantidad, 
                    double.tryParse(precioController.text) ?? 0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cantidad inválida'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevoCliente() {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Nuevo Cliente'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
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
              if (nombreController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _crearCliente(
                  nombreController.text.trim(),
                  emailController.text.trim(),
                  telefonoController.text.trim(),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _crearCliente(String nombre, String email, String telefono) async {
    try {
      final clienteData = {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'activo': true,
        'totalCompras': 0,
        'ultimaCompra': null,
      };

      await _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('clientes')
          .add(clienteData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cliente "$nombre" creado exitosamente'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear cliente: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _procesarSalida(
    String articuloId, 
    Map<String, dynamic> articuloData, 
    int cantidad, 
    double precio
  ) async {
    setState(() => _isLoading = true);

    try {
      final batch = _firestore.batch();

      // 1. Actualizar stock del artículo
      final nuevoStock = (articuloData['stock'] ?? 0) - cantidad;
      final articuloRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(articuloId);

      batch.update(articuloRef, {
        'stock': nuevoStock,
        'ultimaModificacion': FieldValue.serverTimestamp(),
      });

      // 2. Crear registro de movimiento
      final movimientoRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('movimientos')
          .doc();

      final movimientoData = {
        'tipoMovimiento': 'salida',
        'tipo': _selectedTipoSalida,
        'articuloId': articuloId,
        'articuloNombre': articuloData['nombre'],
        'cantidad': cantidad,
        'precio': precio,
        'total': cantidad * precio,
        'stockAnterior': articuloData['stock'],
        'stockNuevo': nuevoStock,
        'fecha': FieldValue.serverTimestamp(),
        'observaciones': 'Salida registrada desde app',
      };

      // Agregar información del cliente si es una venta
      if (_selectedTipoSalida == 'venta') {
        // Aquí se agregarían los datos del cliente seleccionado
        // movimientoData['clienteId'] = clienteId;
        // movimientoData['clienteNombre'] = clienteNombre;
      }

      batch.set(movimientoRef, movimientoData);

      // 3. Ejecutar transacción
      await batch.commit();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Salida registrada: $cantidad unidades de ${articuloData['nombre']}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Cambiar a tab de historial
        _tabController.animateTo(1);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al registrar salida: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _verDetalleMovimiento(String movimientoId, Map<String, dynamic> data) {
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
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalle de Movimiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetalleRow('Artículo:', data['articuloNombre'] ?? 'N/A'),
              _buildDetalleRow('Tipo:', _getTipoLabel(data['tipo'] ?? '')),
              _buildDetalleRow('Cantidad:', data['cantidad']?.toString() ?? '0'),
              _buildDetalleRow('Precio unitario:', '€${data['precio'] ?? 0}'),
              _buildDetalleRow('Total:', '€${data['total'] ?? 0}'),
              if (data['clienteNombre'] != null)
                _buildDetalleRow('Cliente:', data['clienteNombre']),
              _buildDetalleRow('Stock anterior:', data['stockAnterior']?.toString() ?? '0'),
              _buildDetalleRow('Stock nuevo:', data['stockNuevo']?.toString() ?? '0'),
              if (data['fecha'] != null)
                _buildDetalleRow('Fecha:', 
                  DateFormat('dd/MM/yyyy HH:mm').format((data['fecha'] as Timestamp).toDate())),
              if (data['observaciones'] != null)
                _buildDetalleRow('Observaciones:', data['observaciones']),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'venta':
        return 'Venta';
      case 'devolucion_proveedor':
        return 'Devolución a Proveedor';
      case 'ajuste_negativo':
        return 'Ajuste Negativo';
      case 'consumo_interno':
        return 'Consumo Interno';
      default:
        return 'Desconocido';
    }
  }

  void _confirmarEliminarMovimiento(String movimientoId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Movimiento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar este movimiento de ${data['articuloNombre']}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El stock del artículo se restaurará automáticamente.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
              _eliminarMovimiento(movimientoId, data);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarMovimiento(String movimientoId, Map<String, dynamic> data) async {
    setState(() => _isLoading = true);

    try {
      final batch = _firestore.batch();

      // 1. Restaurar stock del artículo
      final articuloRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(data['articuloId']);

      // Obtener stock actual
      final articuloDoc = await articuloRef.get();
      if (articuloDoc.exists) {
        final stockActual = articuloDoc.data()?['stock'] ?? 0;
        final cantidadARestaurar = data['cantidad'] ?? 0;
        final nuevoStock = stockActual + cantidadARestaurar;

        batch.update(articuloRef, {
          'stock': nuevoStock,
          'ultimaModificacion': FieldValue.serverTimestamp(),
        });
      }

      // 2. Eliminar el movimiento
      final movimientoRef = _firestore
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('movimientos')
          .doc(movimientoId);

      batch.delete(movimientoRef);

      // 3. Ejecutar transacción
      await batch.commit();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Movimiento eliminado y stock restaurado'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar movimiento: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}