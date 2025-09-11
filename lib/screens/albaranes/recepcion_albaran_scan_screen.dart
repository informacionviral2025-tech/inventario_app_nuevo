import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/albaran_proveedor.dart';
import '../../models/articulo.dart';
import '../../screens/etiqueta_preview.dart';

class RecepcionAlbaranScanScreen extends StatefulWidget {
  final String empresaId;
  final String empresaNombre;
  final String? albaranId;
  final String? numeroAlbaran;

  const RecepcionAlbaranScanScreen({
    Key? key,
    required this.empresaId,
    required this.empresaNombre,
    this.albaranId,
    this.numeroAlbaran,
  }) : super(key: key);

  @override
  State<RecepcionAlbaranScanScreen> createState() => _RecepcionAlbaranScanScreenState();
}

class _RecepcionAlbaranScanScreenState extends State<RecepcionAlbaranScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final Map<String, int> _conteoPorCodigo = {};
  final Map<String, Articulo> _articulosPorCodigo = {};
  bool _procesando = false;
  bool _autoImprimirEtiqueta = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_procesando) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null) continue;
      await _agregarCodigo(code);
    }
  }

  Future<void> _agregarCodigo(String codigo) async {
    setState(() {
      _procesando = true;
    });
    try {
      // Buscar artículo por código
      final query = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('articulos')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _mostrarSnack('Código desconocido: $codigo', isError: true);
      } else {
        final articulo = Articulo.fromFirestore(query.docs.first);
        _articulosPorCodigo[codigo] = articulo;
        _conteoPorCodigo.update(codigo, (v) => v + 1, ifAbsent: () => 1);
        setState(() {});
      }
    } catch (e) {
      _mostrarSnack('Error buscando artículo: $e', isError: true);
    } finally {
      setState(() {
        _procesando = false;
      });
    }
  }

  Future<void> _procesarRecepcion() async {
    if (_conteoPorCodigo.isEmpty) {
      _mostrarSnack('No hay escaneos para procesar');
      return;
    }

    setState(() => _procesando = true);
    try {
      // Construir líneas
      final List<LineaAlbaran> lineas = [];
      _conteoPorCodigo.forEach((codigo, cantidad) {
        final articulo = _articulosPorCodigo[codigo]!;
        lineas.add(LineaAlbaran(
          articuloId: articulo.firebaseId!,
          articuloNombre: articulo.nombre,
          articuloCodigo: articulo.codigo,
          cantidad: cantidad.toDouble(),
          precioUnitario: articulo.precio,
          subtotal: articulo.precio * cantidad,
        ));
      });

      // Si existe albarán, actualizar sus líneas sumando cantidades; si no, crear uno temporal pendiente
      String albaranId = widget.albaranId ?? '';
      if (albaranId.isEmpty) {
        final ahora = DateTime.now();
        final docRef = await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('albaranes_proveedor')
            .add(AlbaranProveedor(
              numeroAlbaran: widget.numeroAlbaran ?? 'ALB-${ahora.millisecondsSinceEpoch}',
              proveedorId: '',
              proveedorNombre: '',
              empresaId: widget.empresaId,
              fechaAlbaran: ahora,
              fechaRecepcion: ahora,
              fechaRegistro: ahora,
              estado: 'pendiente',
              lineas: lineas,
              subtotal: lineas.fold(0.0, (s, l) => s + l.subtotal),
              iva: 0,
              total: lineas.fold(0.0, (s, l) => s + l.subtotal),
              observaciones: 'Generado por escaneo',
            ).toFirestore());
        albaranId = docRef.id;
      } else {
        final albaranRef = FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('albaranes_proveedor')
            .doc(albaranId);
        final snap = await albaranRef.get();
        if (!snap.exists) throw Exception('Albarán no encontrado');
        final existente = AlbaranProveedor.fromFirestore(snap);

        // Combinar líneas
        final Map<String, LineaAlbaran> porArticulo = {
          for (final l in existente.lineas) l.articuloId: l
        };
        for (final l in lineas) {
          if (porArticulo.containsKey(l.articuloId)) {
            final prev = porArticulo[l.articuloId]!;
            porArticulo[l.articuloId] = prev.copyWith(
              cantidad: prev.cantidad + l.cantidad,
              subtotal: (prev.cantidad + l.cantidad) * prev.precioUnitario,
            );
          } else {
            porArticulo[l.articuloId] = l;
          }
        }
        final nuevasLineas = porArticulo.values.toList();
        final subtotal = nuevasLineas.fold(0.0, (s, l) => s + l.subtotal);
        await albaranRef.update({
          'lineas': nuevasLineas.map((e) => e.toMap()).toList(),
          'subtotal': subtotal,
          'total': subtotal + existente.iva,
          'fechaRecepcion': FieldValue.serverTimestamp(),
        });
      }

      // Preguntar si procesar entradas al inventario
      final confirmar = await _confirmarDialogo('¿Procesar entradas al inventario ahora?');
      if (confirmar == true) {
        await _aplicarStock();
      }

      // Opcional imprimir etiquetas por cada artículo escaneado
      if (_autoImprimirEtiqueta) {
        for (final codigo in _conteoPorCodigo.keys) {
          final art = _articulosPorCodigo[codigo]!;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EtiquetaPreviewScreen(
                codigo: art.codigo,
                nombre: art.nombre,
                empresa: widget.empresaNombre,
              ),
            ),
          );
        }
      }

      _mostrarSnack('Recepción registrada');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _mostrarSnack('Error procesando recepción: $e', isError: true);
    } finally {
      setState(() => _procesando = false);
    }
  }

  Future<void> _aplicarStock() async {
    final batch = FirebaseFirestore.instance.batch();
    try {
      _conteoPorCodigo.forEach((codigo, cantidad) {
        final articulo = _articulosPorCodigo[codigo]!;
        final ref = FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('articulos')
            .doc(articulo.firebaseId);
        batch.update(ref, {
          'stock': articulo.stock + cantidad,
          'fechaActualizacion': FieldValue.serverTimestamp(),
        });
      });
      await batch.commit();
      _mostrarSnack('Stock actualizado');
    } catch (e) {
      _mostrarSnack('Error actualizando stock: $e', isError: true);
    }
  }

  Future<bool?> _confirmarDialogo(String mensaje) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(mensaje),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
  }

  void _mostrarSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recepción por escaneo${widget.numeroAlbaran != null ? ' (${widget.numeroAlbaran})' : ''}'),
        actions: [
          Row(
            children: [
              const Text('Imprimir etiquetas'),
              Switch(
                value: _autoImprimirEtiqueta,
                onChanged: (v) => setState(() => _autoImprimirEtiqueta = v),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(controller: _scannerController, onDetect: _onDetect),
                if (_procesando)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escaneos acumulados', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _conteoPorCodigo.isEmpty
                        ? const Center(child: Text('Escanea códigos del albarán...'))
                        : ListView(
                            children: _conteoPorCodigo.entries.map((e) {
                              final art = _articulosPorCodigo[e.key];
                              return ListTile(
                                leading: const Icon(Icons.inventory_2),
                                title: Text(art?.nombre ?? e.key),
                                subtitle: Text('Código: ${e.key}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          final v = (_conteoPorCodigo[e.key] ?? 1) - 1;
                                          if (v <= 0) {
                                            _conteoPorCodigo.remove(e.key);
                                            _articulosPorCodigo.remove(e.key);
                                          } else {
                                            _conteoPorCodigo[e.key] = v;
                                          }
                                        });
                                      },
                                    ),
                                    Text('${e.value}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          _conteoPorCodigo.update(e.key, (v) => v + 1, ifAbsent: () => 1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _procesando ? null : _procesarRecepcion,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Guardar y (opcional) procesar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


