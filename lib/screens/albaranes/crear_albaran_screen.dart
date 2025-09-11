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
  final List<Map<String, dynamic>> _csvOmitidos = [];

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
                OutlinedButton.icon(
                  onPressed: _importarDesdeCsv,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar CSV'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _abrirEscaner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Escanear'),
                ),
                const SizedBox(width: 8),
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

  Future<void> _abrirEscaner() async {
    await Navigator.pushNamed(
      context,
      '/albaranes/recepcion-scan',
      arguments: {
        'empresaId': widget.empresaId,
        'empresaNombre': widget.empresaNombre,
        'albaranId': widget.albaran?.id,
        'numeroAlbaran': _numeroController.text.isNotEmpty ? _numeroController.text : null,
      },
    );
  }

  Future<void> _importarDesdeCsv() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pegar CSV (codigo,cantidad,precio opcional)'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Ejemplo:\nABC123,5,2.5\nXYZ999,10',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Importar')),
        ],
      ),
    );
    if (ok != true) return;
    final texto = controller.text.trim();
    if (texto.isEmpty) return;

    try {
      final lineas = texto.split('\n');
      final List<String> noEncontrados = [];
      for (final linea in lineas) {
        final cols = linea.split(',');
        if (cols.isEmpty || cols[0].trim().isEmpty) continue;
        final codigo = cols[0].trim();
        final cantidad = cols.length > 1 ? double.tryParse(cols[1].trim()) ?? 0.0 : 0.0;
        final precio = cols.length > 2 ? double.tryParse(cols[2].trim()) ?? 0.0 : 0.0;

        final snap = await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .where('codigo', isEqualTo: codigo)
            .limit(1)
            .get();
        if (snap.docs.isEmpty) {
          noEncontrados.add('$codigo|$cantidad|$precio');
          continue;
        }
        final doc = snap.docs.first;
        final data = doc.data();
        setState(() {
          _articulos.add({
            'id': doc.id,
            'nombre': data['nombre'] ?? codigo,
            'codigo': codigo,
            'cantidad': cantidad > 0 ? cantidad : 1.0,
            'precio': precio > 0 ? precio : (data['precio'] ?? 0.0),
          });
        });
      }

      if (noEncontrados.isNotEmpty) {
        await _resolverCodigosNoEncontrados(noEncontrados);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV importado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importando CSV: $e')),
      );
    }
  }

  Future<void> _resolverCodigosNoEncontrados(List<String> entradas) async {
    // Cada entrada: "codigo|cantidad|precio"
    for (final entrada in entradas) {
      final partes = entrada.split('|');
      final codigo = partes[0];
      final cantidad = partes.length > 1 ? double.tryParse(partes[1]) ?? 1.0 : 1.0;
      final precio = partes.length > 2 ? double.tryParse(partes[2]) ?? 0.0 : 0.0;
      final item = await _resolverCodigoNoEncontrado(codigo: codigo, cantidad: cantidad, precio: precio);
      if (item != null) {
        setState(() {
          _articulos.add(item);
        });
      } else {
        // Registrar omisión
        setState(() {
          _csvOmitidos.add({
            'codigo': codigo,
            'cantidad': cantidad,
            'precio': precio,
            'motivo': 'omitido_en_import_csv',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _resolverCodigoNoEncontrado({
    required String codigo,
    required double cantidad,
    required double precio,
  }) async {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        final nombreCtrl = TextEditingController(text: codigo);
        final precioCtrl = TextEditingController(text: precio > 0 ? precio.toString() : '0');
        return AlertDialog(
          title: Text('Código no encontrado: $codigo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecciona cómo resolver este código:'),
              const SizedBox(height: 12),
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre (para creación rápida)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio (opcional)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Omitir'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                // Seleccionar artículo existente
                final seleccionado = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => _ArticuloSelectorDialog(empresaId: widget.empresaId),
                );
                if (seleccionado != null) {
                  Navigator.pop(context, {
                    'id': seleccionado['id'],
                    'nombre': seleccionado['nombre'],
                    'codigo': codigo,
                    'cantidad': cantidad,
                    'precio': precio > 0 ? precio : (seleccionado['precio'] ?? 0.0),
                  });
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Seleccionar artículo'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Crear artículo rápido
                final nombre = nombreCtrl.text.trim().isEmpty ? codigo : nombreCtrl.text.trim();
                final precioNuevo = double.tryParse(precioCtrl.text.trim()) ?? 0.0;
                try {
                  final doc = await FirebaseFirestore.instance
                      .collection('empresas')
                      .doc(widget.empresaId)
                      .collection('articulos')
                      .add({
                    'nombre': nombre,
                    'codigo': codigo,
                    'descripcion': '',
                    'categoria': '',
                    'precio': precioNuevo,
                    'stock': 0,
                    'activo': true,
                    'fechaCreacion': FieldValue.serverTimestamp(),
                    'fechaActualizacion': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context, {
                    'id': doc.id,
                    'nombre': nombre,
                    'codigo': codigo,
                    'cantidad': cantidad,
                    'precio': precioNuevo,
                  });
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creando artículo: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear rápido'),
            ),
          ],
        );
      },
    );
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

      final metadatos = <String, dynamic>{
        'csvOmitidos': _csvOmitidos,
        'csvImportados': _articulos.length,
      };

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
        metadatos: metadatos,
      );

      if (widget.albaran == null) {
        await _albaranService.crearAlbaran(widget.empresaId, albaran);
      } else {
        // Si ya hay metadatos previos, fusionar
        final metaPrev = widget.albaran!.metadatos;
        final albaranActualizado = albaran.copyWith(
          id: widget.albaran!.id,
          metadatos: {
            ...metaPrev,
            ...metadatos,
          },
        );
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