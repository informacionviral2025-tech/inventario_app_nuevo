// lib/services/firebase_service.dart
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'barcode_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BarcodeService _barcodeService = BarcodeService();
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _articulosRef(String empresaId) =>
      _db.ref('empresas/$empresaId/articulos');

  DatabaseReference get userRef => _db.ref('usuarios');
  DatabaseReference get empresasRef => _db.ref('empresas');

  Future<List<Map<String, dynamic>>> getEmpresas() async {
    try {
      final snapshot = await empresasRef.get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final empresa = Map<String, dynamic>.from(entry.value);
        empresa['id'] = entry.key;
        return empresa;
      }).toList();
    } catch (e) {
      print('Error obteniendo empresas: $e');
      return [];
    }
  }

  Future<String?> createEmpresa(String nombre, String descripcion) async {
    try {
      final ref = empresasRef.push();
      await ref.set({
        'nombre': nombre,
        'descripcion': descripcion,
        'fechaCreacion': DateTime.now().toIso8601String(),
      });
      return ref.key;
    } catch (e) {
      print('Error creando empresa: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getArticulosStream(String empresaId) {
    return _articulosRef(empresaId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final articulo = Map<String, dynamic>.from(entry.value);
        articulo['id'] = entry.key;
        return articulo;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getArticulos(String empresaId) async {
    try {
      final snapshot = await _articulosRef(empresaId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final articulo = Map<String, dynamic>.from(entry.value);
        articulo['id'] = entry.key;
        return articulo;
      }).toList();
    } catch (e) {
      print('Error obteniendo artículos: $e');
      return [];
    }
  }

  Future<String?> addArticulo(
      String empresaId, Map<String, dynamic> articulo) async {
    try {
      final ref = _articulosRef(empresaId).push();
      await ref.set(articulo);
      return ref.key;
    } catch (e) {
      print('Error agregando artículo: $e');
      return null;
    }
  }

  Future<bool> updateArticulo(String empresaId, String articuloId,
      Map<String, dynamic> articulo) async {
    try {
      await _articulosRef(empresaId).child(articuloId).update(articulo);
      return true;
    } catch (e) {
      print('Error actualizando artículo: $e');
      return false;
    }
  }

  Future<bool> deleteArticulo(String empresaId, String articuloId) async {
    try {
      await _articulosRef(empresaId).child(articuloId).remove();
      return true;
    } catch (e) {
      print('Error eliminando artículo: $e');
      return false;
    }
  }

  Future<String?> createArticuloConCodigoBarras({
    required String empresaId,
    required String codigo,
    required String nombre,
    required String categoria,
    required double precioCompra,
    required double precioVenta,
    required int stockMinimo,
    required int stockMaximo,
    String? descripcion,
    String? proveedor,
    String? ubicacion,
    String? lote,
    int cantidadInicial = 0,
  }) async {
    try {
      final existingQuery = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Ya existe un artículo con el código: $codigo');
      }

      final barcodeData = _barcodeService.generateBarcodeData(
        codigo,
        empresaId: empresaId,
        lote: lote,
      );

      final barcodeInfo = BarcodeInfo(
        data: barcodeData.toString(),
        type: 'CODE128',
        articleCode: codigo,
        createdAt: DateTime.now(),
        lote: lote,
        empresaId: empresaId,
      );

      final docRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc();

      final articuloData = {
        'id': docRef.id,
        'codigo': codigo,
        'nombre': nombre,
        'categoria': categoria,
        'precioCompra': precioCompra,
        'precioVenta': precioVenta,
        'stockMinimo': stockMinimo,
        'stockMaximo': stockMaximo,
        'descripcion': descripcion,
        'proveedor': proveedor,
        'ubicacion': ubicacion,
        'stock_actual': cantidadInicial,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'codigo_barras': barcodeInfo.toMap(),
      };

      await docRef.set(articuloData);
      await _registrarMovimiento(
        empresaId: empresaId,
        articuloId: docRef.id,
        tipoMovimiento: 'creacion',
        cantidad: cantidadInicial,
        motivo: 'Creación inicial',
        codigoArticulo: codigo,
        lote: lote,
      );
      return docRef.id;
    } catch (e) {
      print('Error creando artículo con código de barras: $e');
      return null;
    }
  }

  Future<bool> addStockConCodigoBarras({
    required String empresaId,
    required String articuloId,
    required String codigoArticulo,
    required int cantidad,
    String? lote,
    String? motivo = 'Entrada de stock',
    bool generarNuevoCodigoBarras = false,
  }) async {
    try {
      final docRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc(articuloId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('El artículo no existe');
      }

      final data = doc.data() as Map<String, dynamic>;
      final int stockActual = data['stock_actual'] ?? 0;
      final nuevoStock = stockActual + cantidad;

      final updateData = <String, dynamic>{
        'stock_actual': nuevoStock,
        'fecha_actualizacion': FieldValue.serverTimestamp(),
      };

      final barcodeActual = data['codigo_barras'] != null
          ? BarcodeInfo.fromMap(data['codigo_barras'] as Map<String, dynamic>)
          : null;

      if (generarNuevoCodigoBarras ||
          (lote != null && lote != barcodeActual?.lote)) {
        final nuevoBarcodeData = _barcodeService.generateBarcodeData(
          codigoArticulo,
          empresaId: empresaId,
          lote: lote,
        );
        final nuevoBarcodeInfo = BarcodeInfo(
          data: nuevoBarcodeData.toString(),
          type: 'CODE128',
          articleCode: codigoArticulo,
          createdAt: DateTime.now(),
          lote: lote,
          empresaId: empresaId,
        );
        updateData['codigo_barras'] = nuevoBarcodeInfo.toMap();
        await _guardarHistorialCodigoBarras(
            empresaId, articuloId, nuevoBarcodeInfo);
      }

      if (lote != null) updateData['lote'] = lote;

      await docRef.update(updateData);

      await _registrarMovimiento(
        empresaId: empresaId,
        articuloId: articuloId,
        tipoMovimiento: 'entrada',
        cantidad: cantidad,
        motivo: motivo ?? 'Entrada de stock',
        codigoArticulo: codigoArticulo,
        lote: lote,
      );
      return true;
    } catch (e) {
      print('Error añadiendo stock con código de barras: $e');
      return false;
    }
  }

  Future<void> _guardarHistorialCodigoBarras(
      String empresaId, String articuloId, BarcodeInfo barcodeInfo) async {
    try {
      await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc(articuloId)
          .collection('historial_codigos_barras')
          .add(barcodeInfo.toMap());
    } catch (e) {
      print('Error guardando historial de código de barras: $e');
    }
  }

  Future<List<BarcodeInfo>> getHistorialCodigosBarras(
      String empresaId, String articuloId) async {
    try {
      final querySnapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .doc(articuloId)
          .collection('historial_codigos_barras')
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((e) => BarcodeInfo.fromMap(e.data()))
          .toList();
    } catch (e) {
      print('Error obteniendo historial de códigos de barras: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> buscarArticuloPorCodigoBarras(
      String empresaId, String codigoBarras) async {
    try {
      final querySnapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('codigo_barras.data', isEqualTo: codigoBarras)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }

      final codigoArticulo =
          _barcodeService.extractArticleCodeFromBarcode(codigoBarras);
      final queryByCode = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('codigo', isEqualTo: codigoArticulo)
          .limit(1)
          .get();
      if (queryByCode.docs.isNotEmpty) {
        return queryByCode.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error buscando artículo por código de barras: $e');
      return null;
    }
  }

  Future<void> _registrarMovimiento({
    required String empresaId,
    required String articuloId,
    required String tipoMovimiento,
    required int cantidad,
    required String motivo,
    required String codigoArticulo,
    String? lote,
  }) async {
    try {
      await _firestore.collection('empresas').doc(empresaId).collection('movimientos').add({
        'articulo_id': articuloId,
        'codigo_articulo': codigoArticulo,
        'tipo': tipoMovimiento,
        'cantidad': cantidad,
        'motivo': motivo,
        'lote': lote ?? '',
        'fecha': FieldValue.serverTimestamp(),
        'usuario': 'sistema',
      });
    } catch (e) {
      print('Error registrando movimiento: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTodosLosCodigosBarras(
      String empresaId) async {
    try {
      final querySnapshot = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos')
          .where('activo', isEqualTo: true)
          .get();
      final List<Map<String, dynamic>> codigosBarras = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['codigo_barras'] != null) {
          codigosBarras.add({
            'articulo': data,
            'codigo_barras':
                BarcodeInfo.fromMap(data['codigo_barras'] as Map<String, dynamic>),
          });
        }
      }
      return codigosBarras;
    } catch (e) {
      print('Error obteniendo códigos de barras: $e');
      return [];
    }
  }
}