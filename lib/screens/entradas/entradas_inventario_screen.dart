import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/articulo.dart';

class EntradaInventarioScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;

  const EntradaInventarioScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
  }) : super(key: key);

  @override
  _EntradaInventarioScreenState createState() => _EntradaInventarioScreenState();
}

class _EntradaInventarioScreenState extends State<EntradaInventarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  
  String _searchQuery = '';
  Articulo? _articuloSeleccionado;
  String _tipoEntrada = 'Compra'; // Compra, Devolución, Ajuste, Producción
  bool _procesandoEntrada = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Stream<List<Articulo>> _getArticulosStream() {
    return FirebaseFirestore.instance
        .collection('empresas')
        .doc(widget.empresaId)
        .collection('articulos')
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Articulo.fromFirestore(doc))
            .where((articulo) {
              if (_searchQuery.isEmpty) return true;
              final nombre = articulo.nombre.toLowerCase();
              final codigo = articulo.codigo.toLowerCase();
              return nombre.contains(_searchQuery) || codigo.contains(_searchQuery);
            })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrada de Stock',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.empresaNombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Selector de tipo de entrada
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('Tipo:', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _tipoEntrada,
                          dropdownColor: Colors.green.shade700,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          underline: Container(),
                          items: const [
                            DropdownMenuItem(value: 'Compra', child: Text('Compra')),
                            DropdownMenuItem(value: 'Devolución', child: Text('Devolución')),
                            DropdownMenuItem(value: 'Ajuste', child: Text('Ajuste inventario')),
                            DropdownMenuItem(value: 'Producción', child: Text('Producción')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _tipoEntrada = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar artículo por nombre o código...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Artículo seleccionado
          if (_articuloSeleccionado != null) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Artículo seleccionado',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _articuloSeleccionado = null;
                            _cantidadController.clear();
                            _precioController.clear();
                          });
                        },
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _articuloSeleccionado!.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Código: ${_articuloSeleccionado!.codigo}'),
                  Text('Stock actual: ${_articuloSeleccionado!.stock}'),
                  Text('Precio actual: ${_articuloSeleccionado!.precio.toStringAsFixed(2)} €'),
                  
                  const SizedBox(height: 16),
                  
                  // Formulario de entrada
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadController,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio unitario',
                            border: const OutlineInputBorder(),
                            hintText: _articuloSeleccionado!.precio.toStringAsFixed(2),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _observacionesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón de procesar entrada
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _procesandoEntrada ? null : _procesarEntrada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _procesandoEntrada 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_box),
                      label: Text(_procesandoEntrada 
                          ? 'Procesando...' 
                          : 'Registrar Entrada'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Lista de artículos
          Expanded(
            child: StreamBuilder<List<Articulo>>(
              stream: _getArticulosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar artículos',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final articulos = snapshot.data ?? [];

                if (articulos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'No se encontraron artículos'
                              : 'No hay artículos disponibles',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: articulos.length,
                  itemBuilder: (context, index) {
                    final articulo = articulos[index];
                    return _buildArticuloCard(articulo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticuloCard(Articulo articulo) {
    final isSelected = _articuloSeleccionado?.codigo == articulo.codigo;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isSelected ? Colors.green.shade50 : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _articuloSeleccionado = articulo;
            _precioController.text = articulo.precio.toStringAsFixed(2);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de inventario
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.green.shade700 
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: isSelected ? Colors.white : Colors.blue.shade700,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del artículo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.green.shade700 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${articulo.codigo}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Stock: ${articulo.stock} | Precio: ${articulo.precio.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicador de selección
              if (isSelected) ...[
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ] else ...[
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _procesarEntrada() async {
    if (_articuloSeleccionado == null) return;
    
    final cantidadText = _cantidadController.text.trim();
    if (cantidadText.isEmpty) {
      _mostrarError('La cantidad es obligatoria');
      return;
    }
    
    final cantidad = int.tryParse(cantidadText);
    if (cantidad == null || cantidad <= 0) {
      _mostrarError('La cantidad debe ser un número positivo');
      return;
    }

    setState(() {
      _procesandoEntrada = true;
    });

    try {
      // Calcular nuevo stock
      final nuevoStock = _articuloSeleccionado!.stock + cantidad;
      
      // Actualizar precio si se proporcionó uno nuevo
      double nuevoPrecio = _articuloSeleccionado!.precio;
      final precioText = _precioController.text.trim();
      if (precioText.isNotEmpty) {
        final precio = double.tryParse(precioText);
        if (precio != null && precio > 0) {
          nuevoPrecio = precio;
        }
      }

      // Actualizar artículo en Firestore
      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .doc(_articuloSeleccionado!.firebaseId)
          .update({
            'stock': nuevoStock,
            'precio': nuevoPrecio,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          });

      // Registrar movimiento en historial
      await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('movimientos')
          .add({
            'articuloId': _articuloSeleccionado!.firebaseId,
            'articuloCodigo': _articuloSeleccionado!.codigo,
            'articuloNombre': _articuloSeleccionado!.nombre,
            'tipo': 'Entrada',
            'subtipo': _tipoEntrada,
            'cantidad': cantidad,
            'stockAnterior': _articuloSeleccionado!.stock,
            'stockNuevo': nuevoStock,
            'precioAnterior': _articuloSeleccionado!.precio,
            'precioNuevo': nuevoPrecio,
            'observaciones': _observacionesController.text.trim(),
            'fecha': FieldValue.serverTimestamp(),
            'usuario': 'Sistema', // TODO: Implementar gestión de usuarios
          });

      // Mostrar éxito y limpiar formulario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Entrada registrada: +$cantidad unidades'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _articuloSeleccionado = null;
        _cantidadController.clear();
        _precioController.clear();
        _observacionesController.clear();
      });

    } catch (e) {
      _mostrarError('Error al registrar entrada: $e');
    } finally {
      setState(() {
        _procesandoEntrada = false;
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}