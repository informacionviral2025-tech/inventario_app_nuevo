// lib/screens/albaranes/crear_albaran_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/albaran_proveedor.dart';
import '../../models/proveedor.dart';
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
  List<Map<String, dynamic>> _articulos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.albaran != null) {
      _numeroController.text = widget.albaran!.numeroAlbaran;
      _observacionesController.text = widget.albaran!.observaciones ?? '';
      _proveedorId = widget.albaran!.proveedorId;
      _proveedorNombre = widget.albaran!.proveedorNombre;
      _fechaAlbaran = widget.albaran!.fechaAlbaran;
      _iva = widget.albaran!.iva;
      _articulos = widget.albaran!.lineas.map((linea) => {
        'id': linea.articuloId,
        'nombre': linea.articuloNombre,
        'codigo': linea.articuloCodigo,
        'cantidad': linea.cantidad,
        'precio': linea.precioUnitario,
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albaran == null ? 'Nuevo Albarán' : 'Editar Albarán'),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _guardarAlbaran,
        icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.save),
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
            const Text('Información General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Número de Albarán *',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Fecha: ${_fechaAlbaran.toString().substring(0, 10)}'),
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
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
            const Text('Proveedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_proveedorId == null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _seleccionarProveedor,
                  icon: const Icon(Icons.add),
                  label: const Text('Seleccionar Proveedor'),
                ),
              )
            else
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(_proveedorNombre ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _proveedorId = null;
                    _proveedorNombre = null;
                  }),
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
                const Text('Artículos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _agregarArticulo,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_articulos.isEmpty)
              const Center(child: Text('No hay artículos agregados'))
            else
              ..._articulos.map((articulo) => _buildArticuloItem(articulo)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildArticuloItem(Map<String, dynamic> articulo) {
    return ListTile(
      title: Text(articulo['nombre']),
      subtitle: Text('${articulo['cantidad']} × \$${articulo['precio']}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => setState(() => _articulos.remove(articulo)),
      ),
    );
  }

  Widget _buildResumen() {
    final subtotal = _articulos.fold(0.0, (sum, item) => sum + (item['cantidad'] * item['precio']));
    final total = subtotal + (subtotal * _iva / 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _iva = double.tryParse(value) ?? 21.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('IVA ($_iva%):'),
                Text('\$${(subtotal * _iva / 100).toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAlbaran,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaAlbaran = fecha);
  }

  Future<void> _seleccionarProveedor() async {
    final proveedor = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ProveedorSelectorDialog(empresaId: widget.empresaId),
    );
    
    if (proveedor != null) {
      setState(() {
        _proveedorId = proveedor['id'];
        _proveedorNombre = proveedor['nombre'];
      });
    }
  }

  Future<void> _agregarArticulo() async {
    final articulo = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ArticuloSelectorDialog(empresaId: widget.empresaId),
    );
    
    if (articulo != null) {
      setState(() => _articulos.add(articulo));
    }
  }

  Future<void> _guardarAlbaran() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proveedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un proveedor')));
      return;
    }
    if (_articulos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un artículo')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subtotal = _articulos.fold(0.0, (sum, item) => sum + (item['cantidad'] * item['precio']));
      final total = subtotal + (subtotal * _iva / 100);

      final lineas = _articulos.map((item) => LineaAlbaran(
        articuloId: item['id'],
        articuloCodigo: item['codigo'] ?? '',
        articuloNombre: item['nombre'],
        cantidad: item['cantidad'],
        precioUnitario: item['precio'],
        subtotal: item['cantidad'] * item['precio'],
      )).toList();

      final albaran = AlbaranProveedor(
        id: widget.albaran?.id,
        numeroAlbaran: _numeroController.text,
        proveedorId: _proveedorId!,
        proveedorNombre: _proveedorNombre!,
        empresaId: widget.empresaId,
        fechaAlbaran: _fechaAlbaran,
        fechaRecepcion: _fechaAlbaran,
        fechaRegistro: widget.albaran?.fechaRegistro ?? DateTime.now(),
        fechaProcesado: widget.albaran?.fechaProcesado,
        estado: widget.albaran?.estado ?? 'pendiente',
        lineas: lineas,
        subtotal: subtotal,
        iva: _iva,
        total: total,
        observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      );

      if (widget.albaran == null) {
        await _albaranService.crearAlbaran(widget.empresaId, albaran);
      } else {
        final albaranActualizado = albaran.copyWith(id: widget.albaran!.id);
        await _albaranService.actualizarAlbaran(widget.empresaId, albaranActualizado);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ProveedorSelectorDialog extends StatelessWidget {
  final String empresaId;
  const _ProveedorSelectorDialog({Key? key, required this.empresaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Proveedor'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('empresas')
              .doc(empresaId)
              .collection('proveedores')
              .orderBy('nombre')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final proveedores = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'nombre': data['nombre'] ?? 'Sin nombre',
                'email': data['email'] ?? '',
              };
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: proveedores.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(proveedores[index]['nombre']),
                subtitle: Text(proveedores[index]['email']),
                onTap: () => Navigator.pop(context, proveedores[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArticuloSelectorDialog extends StatelessWidget {
  final String empresaId;
  const _ArticuloSelectorDialog({Key? key, required this.empresaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cantidadController = TextEditingController();
    final precioController = TextEditingController();

    return AlertDialog(
      title: const Text('Seleccionar Artículo'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('empresas')
                    .doc(empresaId)
                    .collection('articulos')
                    .orderBy('nombre')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final articulos = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'nombre': data['nombre'] ?? 'Sin nombre',
                      'codigo': data['codigo'] ?? '',
                      'precio': data['precio'] ?? 0.0,
                      'stock': data['stock'] ?? 0,
                    };
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: articulos.length,
                    itemBuilder: (context, index) {
                      final articulo = articulos[index];
                      return ListTile(
                        title: Text(articulo['nombre']),
                        subtitle: Text('Stock: ${articulo['stock']} - Precio: \$${articulo['precio']}'),
                        onTap: () {
                          cantidadController.text = '1';
                          precioController.text = articulo['precio'].toString();
                          
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Agregar ${articulo['nombre']}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: cantidadController,
                                    decoration: const InputDecoration(labelText: 'Cantidad'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextFormField(
                                    controller: precioController,
                                    decoration: const InputDecoration(labelText: 'Precio Unitario'),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                      Navigator.pop(context, {
                                        'id': articulo['id'],
                                        'nombre': articulo['nombre'],
                                        'codigo': articulo['codigo'],
                                        'cantidad': cantidad,
                                        'precio': precio,
                                      });
                                    }
                                  },
                                  child: const Text('Agregar'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}