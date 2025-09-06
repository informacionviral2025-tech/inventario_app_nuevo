// lib/screens/albaranes/crear_albaran_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/albaran_proveedor.dart';
import '../../models/articulo.dart';
import '../../services/albaran_proveedor_service.dart';

class CrearAlbaranScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final AlbaranProveedor? albaran;

  const CrearAlbaranScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    this.albaran,
  }) : super(key: key);

  @override
  State<CrearAlbaranScreen> createState() => _CrearAlbaranScreenState();
}

class _CrearAlbaranScreenState extends State<CrearAlbaranScreen> {
  final _formKey = GlobalKey<FormState>();
  final _albaranService = AlbaranProveedorService();
  
  final _numeroController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String? _proveedorId;
  String? _proveedorNombre;
  DateTime _fechaAlbaran = DateTime.now();
  double _iva = 21.0;
  List<LineaAlbaran> _lineas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.albaran != null) {
      _cargarAlbaran();
    } else {
      _generarNumeroAlbaran();
    }
  }

  void _cargarAlbaran() {
    final albaran = widget.albaran!;
    _numeroController.text = albaran.numeroAlbaran;
    _observacionesController.text = albaran.observaciones ?? '';
    _proveedorId = albaran.proveedorId;
    _proveedorNombre = albaran.proveedorNombre;
    _fechaAlbaran = albaran.fechaAlbaran;
    _iva = albaran.iva;
    _lineas = List.from(albaran.lineas);
  }

  void _generarNumeroAlbaran() {
    final ahora = DateTime.now();
    _numeroController.text = 'ALB${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}-${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albaran == null ? 'Nuevo Albarán' : 'Editar Albarán'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _guardarAlbaran,
            child: Text(
              widget.albaran == null ? 'CREAR' : 'GUARDAR',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInformacionGeneral(),
              const SizedBox(height: 16),
              _buildProveedorSelector(),
              const SizedBox(height: 16),
              _buildArticulosSection(),
              const SizedBox(height: 16),
              _buildResumen(),
              const SizedBox(height: 80), // Espacio para el FAB
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _guardarAlbaran,
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.save),
              label: Text(widget.albaran == null ? 'Crear' : 'Actualizar'),
            ),
    );
  }

  Widget _buildInformacionGeneral() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Número de Albarán *',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
                helperText: 'Número único del albarán',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El número de albarán es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha del Albarán',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _fechaAlbaran.toString().substring(0, 10),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
                helperText: 'Información adicional (opcional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedorSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proveedor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_proveedorId == null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _seleccionarProveedor,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Seleccionar Proveedor'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _proveedorNombre ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() {
                        _proveedorId = null;
                        _proveedorNombre = null;
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Artículos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _agregarArticulo,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lineas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inventory, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No hay artículos agregados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._lineas.asMap().entries.map((entry) {
                final index = entry.key;
                final linea = entry.value;
                return _buildLineaItem(linea, index);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineaItem(LineaAlbaran linea, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  linea.articuloNombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editarLinea(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _eliminarLinea(index),
              ),
            ],
          ),
          if (linea.articuloCodigo.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Código: ${linea.articuloCodigo}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Cantidad: ${linea.cantidad}'),
              ),
              Expanded(
                child: Text('Precio: \$${linea.precioUnitario.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: Text(
                  'Total: \$${linea.totalLinea.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    final subtotal = _lineas.fold(0.0, (sum, linea) => sum + linea.totalLinea);
    final importeIva = subtotal * _iva / 100;
    final total = subtotal + importeIva;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _iva.toString(),
                    decoration: const InputDecoration(
                      labelText: 'IVA (%)',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final iva = double.tryParse(value ?? '');
                      if (iva == null || iva < 0) {
                        return 'IVA inválido';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _iva = double.tryParse(value) ?? 21.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_lineas.length} líneas',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTotalRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
            _buildTotalRow('IVA ($_iva%):', '\$${importeIva.toStringAsFixed(2)}'),
            const Divider(thickness: 2),
            _buildTotalRow(
              'Total:',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAlbaran,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() => _fechaAlbaran = fecha);
    }
  }

  Future<void> _seleccionarProveedor() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ProveedorSelectorDialog(empresaId: widget.empresaId),
    );
    
    if (result != null) {
      setState(() {
        _proveedorId = result['id'];
        _proveedorNombre = result['nombre'];
      });
    }
  }

  Future<void> _agregarArticulo() async {
    final linea = await showDialog<LineaAlbaran>(
      context: context,
      builder: (context) => _ArticuloSelectorDialog(empresaId: widget.empresaId),
    );
    
    if (linea != null) {
      setState(() => _lineas.add(linea));
    }
  }

  void _editarLinea(int index) async {
    final lineaActual = _lineas[index];
    final lineaEditada = await showDialog<LineaAlbaran>(
      context: context,
      builder: (context) => _EditarLineaDialog(linea: lineaActual),
    );
    
    if (lineaEditada != null) {
      setState(() => _lineas[index] = lineaEditada);
    }
  }

  void _eliminarLinea(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Artículo'),
        content: Text('¿Eliminar ${_lineas[index].articuloNombre} del albarán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _lineas.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarAlbaran() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_proveedorId == null) {
      _mostrarError('Selecciona un proveedor');
      return;
    }
    
    if (_lineas.isEmpty) {
      _mostrarError('Agrega al menos un artículo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subtotal = _lineas.fold(0.0, (sum, linea) => sum + linea.totalLinea);
      final total = subtotal + (subtotal * _iva / 100);

      final albaran = AlbaranProveedor(
        id: widget.albaran?.id ?? '',
        numeroAlbaran: _numeroController.text.trim(),
        proveedorId: _proveedorId!,
        proveedorNombre: _proveedorNombre!,
        fechaAlbaran: _fechaAlbaran,
        lineas: _lineas,
        subtotal: subtotal,
        iva: _iva,
        total: total,
        observaciones: _observacionesController.text.trim().isEmpty 
            ? null 
            : _observacionesController.text.trim(),
        estado: widget.albaran?.estado ?? 'pendiente',
        fechaRegistro: widget.albaran?.fechaRegistro ?? DateTime.now(),
        fechaProcesado: widget.albaran?.fechaProcesado,
      );

      if (widget.albaran == null) {
        await _albaranService.crearAlbaran(widget.empresaId, albaran);
      } else {
        await _albaranService.actualizarAlbaran(widget.empresaId, albaran);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error al guardar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Dialog para seleccionar proveedor
class _ProveedorSelectorDialog extends StatelessWidget {
  final String empresaId;
  
  const _ProveedorSelectorDialog({required this.empresaId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Proveedor'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('empresas')
              .doc(empresaId)
              .collection('proveedores')
              .where('activo', isEqualTo: true)
              .orderBy('nombre')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final proveedores = snapshot.data!.docs;

            if (proveedores.isEmpty) {
              return const Center(
                child: Text('No hay proveedores disponibles'),
              );
            }

            return ListView.builder(
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                final doc = proveedores[index];
                final data = doc.data() as Map<String, dynamic>;
                
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(data['email'] ?? ''),
                  onTap: () => Navigator.pop(context, {
                    'id': doc.id,
                    'nombre': data['nombre'] ?? 'Sin nombre',
                  }),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Dialog para seleccionar artículo
class _ArticuloSelectorDialog extends StatelessWidget {
  final String empresaId;
  
  const _ArticuloSelectorDialog({required this.empresaId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Artículo'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('empresas')
              .doc(empresaId)
              .collection('articulos')
              .where('activo', isEqualTo: true)
              .orderBy('nombre')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final articulos = snapshot.data!.docs;

            if (articulos.isEmpty) {
              return const Center(
                child: Text('No hay artículos disponibles'),
              );
            }

            return ListView.builder(
              itemCount: articulos.length,
              itemBuilder: (context, index) {
                final doc = articulos[index];
                final articulo = Articulo.fromFirestore(doc);
                
                return ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(articulo.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (articulo.codigo.isNotEmpty)
                        Text('Código: ${articulo.codigo}'),
                      Text('Stock: ${articulo.stock} - Precio: ${articulo.precioFormateado}'),
                    ],
                  ),
                  onTap: () => _mostrarDialogoCantidad(context, articulo),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogoCantidad(BuildContext context, Articulo articulo) {
    final cantidadController = TextEditingController(text: '1');
    final precioController = TextEditingController(text: articulo.precio.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${articulo.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: precioController,
              decoration: const InputDecoration(
                labelText: 'Precio Unitario *',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              final precio = double.tryParse(precioController.text) ?? 0.0;
              
              if (cantidad > 0 && precio > 0) {
                final linea = LineaAlbaran(
                  articuloId: articulo.firebaseId!,
                  articuloCodigo: articulo.codigo,
                  articuloNombre: articulo.nombre,
                  cantidad: cantidad,
                  precioUnitario: precio,
                  totalLinea: cantidad * precio,
                );
                Navigator.pop(context, linea);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cantidad y precio deben ser mayores a 0'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

// Dialog para editar línea existente
class _EditarLineaDialog extends StatelessWidget {
  final LineaAlbaran linea;
  
  const _EditarLineaDialog({required this.linea});

  @override
  Widget build(BuildContext context) {
    final cantidadController = TextEditingController(text: linea.cantidad.toString());
    final precioController = TextEditingController(text: linea.precioUnitario.toString());

    return AlertDialog(
      title: Text('Editar ${linea.articuloNombre}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: cantidadController,
            decoration: const InputDecoration(
              labelText: 'Cantidad *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: precioController,
            decoration: const InputDecoration(
              labelText: 'Precio Unitario *',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            final precio = double.tryParse(precioController.text) ?? 0.0;
            
            if (cantidad > 0 && precio > 0) {
              final lineaEditada = LineaAlbaran(
                articuloId: linea.articuloId,
                articuloCodigo: linea.articuloCodigo,
                articuloNombre: linea.articuloNombre,
                cantidad: cantidad,
                precioUnitario: precio,
                totalLinea: cantidad * precio,
              );
              Navigator.pop(context, lineaEditada);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cantidad y precio deben ser mayores a 0'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}