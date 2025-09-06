import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// Removemos la importación de barcode que causa conflicto
// import 'package:barcode/barcode.dart';
import 'package:uuid/uuid.dart';

class AddArticleScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final String? articuloId;
  final Map<String, dynamic>? datosExistentes;

  const AddArticleScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    this.articuloId,
    this.datosExistentes,
  }) : super(key: key);

  bool get isEditing => articuloId != null;

  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _codigoController;
  late TextEditingController _descripcionController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinimoController;
  late TextEditingController _precioController;
  late TextEditingController _ubicacionController;

  // Variables
  String _categoriaSeleccionada = 'General';
  bool _isLoading = false;
  bool _generarCodigoAutomatico = true;

  final List<String> _categorias = [
    'General',
    'Herramientas',
    'Materiales',
    'Equipos',
    'Consumibles',
    'Repuestos',
    'Químicos',
    'Seguridad',
    'Oficina',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadExistingData();
  }

  void _initControllers() {
    _nombreController = TextEditingController();
    _codigoController = TextEditingController();
    _descripcionController = TextEditingController();
    _stockController = TextEditingController(text: '0');
    _stockMinimoController = TextEditingController(text: '5');
    _precioController = TextEditingController(text: '0.00');
    _ubicacionController = TextEditingController();
  }

  void _loadExistingData() {
    if (widget.isEditing && widget.datosExistentes != null) {
      final data = widget.datosExistentes!;
      _nombreController.text = data['nombre'] ?? '';
      _codigoController.text = data['codigo'] ?? '';
      _descripcionController.text = data['descripcion'] ?? '';
      _stockController.text = (data['stock'] ?? 0).toString();
      _stockMinimoController.text = (data['stockMinimo'] ?? 5).toString();
      _precioController.text = (data['precio'] ?? 0.0).toStringAsFixed(2);
      _ubicacionController.text = data['ubicacion'] ?? '';
      _categoriaSeleccionada = data['categoria'] ?? 'General';
      _generarCodigoAutomatico = false;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _precioController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Artículo' : 'Nuevo Artículo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isEditing)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _escanearCodigo,
              tooltip: 'Escanear código',
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
              // Header informativo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Modificar Artículo' : 'Agregar Nuevo Artículo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.empresaNombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Información básica
              _buildSectionCard(
                'Información Básica',
                Icons.info,
                Colors.blue,
                [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre del artículo *',
                    hint: 'Ej: Martillo profesional',
                    icon: Icons.label,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      if (value.trim().length < 2) {
                        return 'Mínimo 2 caracteres';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  // Código con generación automática
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: _codigoController,
                          label: 'Código de barras *',
                          hint: 'Ej: 1234567890123',
                          icon: Icons.qr_code,
                          enabled: !_generarCodigoAutomatico,
                          validator: (value) {
                            if (!_generarCodigoAutomatico && (value == null || value.trim().isEmpty)) {
                              return 'El código es obligatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _generarCodigoAutomatico ? null : _escanearCodigo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 36),
                              ),
                              icon: const Icon(Icons.qr_code_scanner, size: 16),
                              label: const Text('Escanear', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(height: 4),
                            ElevatedButton.icon(
                              onPressed: () => _generarCodigo(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 36),
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('Generar', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Switch para generación automática
                  SwitchListTile(
                    title: const Text('Generar código automáticamente'),
                    subtitle: const Text('Se creará un código único al guardar'),
                    value: _generarCodigoAutomatico,
                    onChanged: widget.isEditing ? null : (value) {
                      setState(() {
                        _generarCodigoAutomatico = value;
                        if (value) {
                          _codigoController.clear();
                        }
                      });
                    },
                    activeColor: Colors.blue.shade700,
                  ),

                  _buildTextField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    hint: 'Descripción detallada del artículo...',
                    icon: Icons.description,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stock y precios
              _buildSectionCard(
                'Stock y Precios',
                Icons.inventory,
                Colors.green,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stockController,
                          label: 'Stock actual *',
                          hint: '0',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El stock es obligatorio';
                            }
                            final stock = int.tryParse(value);
                            if (stock == null || stock < 0) {
                              return 'Ingresa un número válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _stockMinimoController,
                          label: 'Stock mínimo *',
                          hint: '5',
                          icon: Icons.warning,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El stock mínimo es obligatorio';
                            }
                            final stock = int.tryParse(value);
                            if (stock == null || stock < 0) {
                              return 'Ingresa un número válido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(
                    controller: _precioController,
                    label: 'Precio unitario (€) *',
                    hint: '0.00',
                    icon: Icons.euro,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      final precio = double.tryParse(value);
                      if (precio == null || precio < 0) {
                        return 'Ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Categoría y ubicación
              _buildSectionCard(
                'Organización',
                Icons.category,
                Colors.purple,
                [
                  DropdownButtonFormField<String>(
                    value: _categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría *',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSeleccionada = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona una categoría';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _ubicacionController,
                    label: 'Ubicación',
                    hint: 'Ej: Estantería A, Nivel 2',
                    icon: Icons.location_on,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _guardarArticulo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(widget.isEditing ? Icons.save : Icons.add),
                  label: Text(
                    _isLoading 
                        ? (widget.isEditing ? 'Actualizando...' : 'Guardando...')
                        : (widget.isEditing ? 'Actualizar Artículo' : 'Guardar Artículo'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String titulo, IconData icono, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
      ),
    );
  }

  Future<void> _escanearCodigo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Escanear Código'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final codigo = barcodes.first.rawValue;
                    if (codigo != null) {
                      Navigator.pop(context);
                      setState(() {
                        _codigoController.text = codigo;
                        _generarCodigoAutomatico = false;
                      });
                    }
                  }
                },
              ),
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Apunta la cámara hacia el código de barras',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generarCodigo() {
    final codigo = _generarCodigoEAN13();
    setState(() {
      _codigoController.text = codigo;
      _generarCodigoAutomatico = false;
    });
  }

  String _generarCodigoEAN13() {
    // Generar 12 dígitos aleatorios
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    String codigo = random.substring(random.length - 12);
    
    // Calcular dígito de verificación EAN-13
    int suma = 0;
    for (int i = 0; i < codigo.length; i++) {
      int digito = int.parse(codigo[i]);
      if (i % 2 == 0) {
        suma += digito;
      } else {
        suma += digito * 3;
      }
    }
    
    int digitoVerificacion = (10 - (suma % 10)) % 10;
    return codigo + digitoVerificacion.toString();
  }

  Future<void> _guardarArticulo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String codigo = _codigoController.text.trim();
      
      // Generar código automáticamente si está habilitado
      if (_generarCodigoAutomatico && !widget.isEditing) {
        codigo = _generarCodigoEAN13();
      }

      // Validar que el código no exista (solo para artículos nuevos)
      if (!widget.isEditing) {
        final existingArticle = await _firestore
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .where('codigo', isEqualTo: codigo)
            .get();

        if (existingArticle.docs.isNotEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Ya existe un artículo con el código: $codigo'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      final articuloData = {
        'nombre': _nombreController.text.trim(),
        'codigo': codigo,
        'descripcion': _descripcionController.text.trim(),
        'stock': int.parse(_stockController.text.trim()),
        'stockMinimo': int.parse(_stockMinimoController.text.trim()),
        'precio': double.parse(_precioController.text.trim()),
        'categoria': _categoriaSeleccionada,
        'ubicacion': _ubicacionController.text.trim(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      if (widget.isEditing) {
        // Actualizar artículo existente
        await _firestore
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .doc(widget.articuloId)
            .update(articuloData);
      } else {
        // Crear nuevo artículo
        articuloData['fechaCreacion'] = FieldValue.serverTimestamp();
        articuloData['id'] = _uuid.v4();
        
        await _firestore
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .add(articuloData);
      }

      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing 
                ? '✅ Artículo actualizado exitosamente'
                : '✅ Artículo agregado exitosamente',
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Mostrar código generado si es nuevo
      if (!widget.isEditing && _generarCodigoAutomatico) {
        _mostrarCodigoGenerado(codigo);
      } else {
        Navigator.pop(context, true);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _mostrarCodigoGenerado(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Artículo Creado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Se ha generado el siguiente código de barras:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    codigo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Aquí podrías generar un código de barras visual
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '||||| |||| |||||',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade800,
                          fontFamily: 'monospace',
                        ),
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
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codigo));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('📋 Código copiado al portapapeles'),
                  backgroundColor: Colors.blue.shade600,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copiar Código'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}