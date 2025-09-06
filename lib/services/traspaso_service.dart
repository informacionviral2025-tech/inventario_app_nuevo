// lib/service/traspaso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TraspasoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crear un traspaso completo con albarán
  Future<String> crearTraspaso({
    required String origenId,
    required String destinoId,
    required String tipoOrigen, // "empresa" o "obra"
    required String tipoDestino, // "empresa" o "obra"
    required Map<String, int> articulos, // { "articuloId": cantidad }
    required String usuario, // quien realiza el traspaso
  }) async {
    // Validaciones iniciales
    if (articulos.isEmpty) {
      throw Exception('Debe incluir al menos un artículo en el traspaso');
    }

    if (origenId == destinoId && tipoOrigen == tipoDestino) {
      throw Exception('El origen y destino no pueden ser el mismo');
    }

    final batch = _db.batch();
    String traspasoId = '';
    String albaranId = '';

    try {
      // 📹 1. Obtener información de origen y destino
      final origenInfo = await _obtenerInfoEntidad(origenId, tipoOrigen);
      final destinoInfo = await _obtenerInfoEntidad(destinoId, tipoDestino);

      // 📹 2. Validar stock en origen
      await _validarStockDisponible(origenId, tipoOrigen, articulos);

      // 📹 3. Generar número de albarán secuencial
      final numeroAlbaran = await _generarNumeroAlbaran();

      // 📹 4. Crear referencias para traspaso y albarán
      final traspasoRef = _db.collection("traspasos").doc();
      final albaranRef = _db.collection("albaranes").doc();
      
      traspasoId = traspasoRef.id;
      albaranId = albaranRef.id;

      // 📹 5. Actualizar stock en origen (resta)
      if (tipoOrigen == "empresa") {
        final origenRef = _db.collection("empresas").doc(origenId);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(origenRef, {
            "stock_general.$articuloId": FieldValue.increment(-cantidad),
          });
        }
      } else {
        final origenRef = _db.collection("obras").doc(origenId);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(origenRef, {
            "stock.$articuloId.cantidad": FieldValue.increment(-cantidad),
            "stock.$articuloId.ultimaActualizacion": FieldValue.serverTimestamp(),
          });
        }
      }

      // 📹 6. Actualizar stock en destino (suma)
      if (tipoDestino == "empresa") {
        final destinoRef = _db.collection("empresas").doc(destinoId);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(destinoRef, {
            "stock_general.$articuloId": FieldValue.increment(cantidad),
          });
        }
      } else {
        final destinoRef = _db.collection("obras").doc(destinoId);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(destinoRef, {
            "stock.$articuloId.cantidad": FieldValue.increment(cantidad),
            "stock.$articuloId.ultimaActualizacion": FieldValue.serverTimestamp(),
          });
        }
      }

      // 📹 7. Crear el traspaso con referencia al albarán
      batch.set(traspasoRef, {
        "origenId": origenId,
        "destinoId": destinoId,
        "tipoOrigen": tipoOrigen,
        "tipoDestino": tipoDestino,
        "articulos": articulos,
        "usuario": usuario,
        "fecha": FieldValue.serverTimestamp(),
        "albaranId": albaranId, // 👈 Relación con el albarán
        "estado": "completado",
      });

      // 📹 8. Crear el albarán con toda la información
      batch.set(albaranRef, {
        "numero": numeroAlbaran,
        "fecha": FieldValue.serverTimestamp(),
        "origen": {
          "id": origenId,
          "tipo": tipoOrigen,
          "nombre": origenInfo['nombre'] ?? 'Sin nombre',
        },
        "destino": {
          "id": destinoId,
          "tipo": tipoDestino,
          "nombre": destinoInfo['nombre'] ?? 'Sin nombre',
        },
        "articulos": articulos,
        "usuario": usuario,
        "estado": "pendiente", // pendiente -> confirmado -> devuelto
        "traspasoId": traspasoId, // 👈 Relación con el traspaso
      });

      // 📹 9. Registrar el movimiento en historial (opcional)
      final movimientoRef = _db.collection("movimientos_stock").doc();
      batch.set(movimientoRef, {
        "tipo": "traspaso",
        "traspasoId": traspasoId,
        "albaranId": albaranId,
        "origenId": origenId,
        "destinoId": destinoId,
        "articulos": articulos,
        "usuario": usuario,
        "fecha": FieldValue.serverTimestamp(),
      });

      // 📹 10. Ejecutar todas las operaciones
      await batch.commit();

      print('✅ Traspaso creado exitosamente: $traspasoId');
      return traspasoId;

    } catch (e) {
      print('❌ Error al crear traspaso: $e');
      rethrow;
    }
  }

  /// Confirmar recepción de un albarán
  Future<void> confirmarRecepcion(String albaranId) async {
    try {
      await _db.collection("albaranes").doc(albaranId).update({
        "estado": "confirmado",
        "fechaConfirmacion": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al confirmar recepción: $e');
    }
  }

  /// Devolver un traspaso (reversa las operaciones de stock)
  Future<void> devolverTraspaso(String traspasoId) async {
    final batch = _db.batch();

    try {
      // Obtener el traspaso original
      final traspasoDoc = await _db.collection("traspasos").doc(traspasoId).get();
      if (!traspasoDoc.exists) {
        throw Exception('Traspaso no encontrado');
      }

      final traspaso = traspasoDoc.data()!;
      final articulos = Map<String, int>.from(traspaso['articulos'] ?? {});
      
      // Reversar las operaciones de stock
      if (traspaso['tipoOrigen'] == "empresa") {
        final origenRef = _db.collection("empresas").doc(traspaso['origenId']);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(origenRef, {
            "stock_general.$articuloId": FieldValue.increment(cantidad),
          });
        }
      } else {
        final origenRef = _db.collection("obras").doc(traspaso['origenId']);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(origenRef, {
            "stock.$articuloId.cantidad": FieldValue.increment(cantidad),
          });
        }
      }

      if (traspaso['tipoDestino'] == "empresa") {
        final destinoRef = _db.collection("empresas").doc(traspaso['destinoId']);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(destinoRef, {
            "stock_general.$articuloId": FieldValue.increment(-cantidad),
          });
        }
      } else {
        final destinoRef = _db.collection("obras").doc(traspaso['destinoId']);
        for (final entry in articulos.entries) {
          final articuloId = entry.key;
          final cantidad = entry.value;
          batch.update(destinoRef, {
            "stock.$articuloId.cantidad": FieldValue.increment(-cantidad),
          });
        }
      }

      // Marcar traspaso como devuelto
      batch.update(_db.collection("traspasos").doc(traspasoId), {
        "estado": "devuelto",
        "fechaDevolucion": FieldValue.serverTimestamp(),
      });

      // Marcar albarán como devuelto
      if (traspaso['albaranId'] != null) {
        batch.update(_db.collection("albaranes").doc(traspaso['albaranId']), {
          "estado": "devuelto",
          "fechaDevolucion": FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al devolver traspaso: $e');
    }
  }

  /// Obtener traspasos por entidad
  Stream<List<Map<String, dynamic>>> obtenerTraspasosPorEntidad({
    required String entidadId,
    required String tipoEntidad,
    String? estado,
  }) {
    Query query = _db.collection("traspasos")
        .where('origenId', isEqualTo: entidadId)
        .orderBy('fecha', descending: true);

    if (estado != null) {
      query = query.where('estado', isEqualTo: estado);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Obtener albaranes
  Stream<List<Map<String, dynamic>>> obtenerAlbaranes({String? estado}) {
    Query query = _db.collection("albaranes").orderBy('fecha', descending: true);
    
    if (estado != null) {
      query = query.where('estado', isEqualTo: estado);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Obtener historial de traspasos (tanto origen como destino)
  Stream<List<Map<String, dynamic>>> obtenerHistorialTraspasos({
    required String entidadId,
    required String tipoEntidad,
  }) {
    // Combinar traspasos donde la entidad sea origen O destino
    return _db.collection("traspasos")
        .where('origenId', isEqualTo: entidadId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .asyncMap((origenSnapshot) async {
          
      // Obtener también los traspasos donde es destino
      final destinoSnapshot = await _db.collection("traspasos")
          .where('destinoId', isEqualTo: entidadId)
          .orderBy('fecha', descending: true)
          .get();

      final List<Map<String, dynamic>> todos = [];
      
      // Agregar traspasos como origen
      for (final doc in origenSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['rol'] = 'origen';
        todos.add(data);
      }
      
      // Agregar traspasos como destino
      for (final doc in destinoSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['rol'] = 'destino';
        todos.add(data);
      }

      // Ordenar por fecha
      todos.sort((a, b) {
        final fechaA = a['fecha'] as Timestamp?;
        final fechaB = b['fecha'] as Timestamp?;
        if (fechaA == null || fechaB == null) return 0;
        return fechaB.compareTo(fechaA);
      });

      return todos;
    });
  }

  // ================== MÉTODOS PRIVADOS ==================

  /// Obtener información de una entidad (empresa u obra)
  Future<Map<String, dynamic>> _obtenerInfoEntidad(String id, String tipo) async {
    final doc = await _db.collection(tipo == "empresa" ? "empresas" : "obras").doc(id).get();
    
    if (!doc.exists) {
      throw Exception('${tipo.capitalize()} con ID $id no encontrada');
    }
    
    return doc.data() ?? {};
  }

  /// Validar que hay stock suficiente en el origen
  Future<void> _validarStockDisponible(
    String origenId, 
    String tipoOrigen, 
    Map<String, int> articulos
  ) async {
    final origenDoc = await _db.collection(tipoOrigen == "empresa" ? "empresas" : "obras")
        .doc(origenId)
        .get();
    
    if (!origenDoc.exists) {
      throw Exception('Origen no encontrado');
    }

    final data = origenDoc.data() ?? {};
    Map<String, dynamic> stockOrigen = {};
    
    if (tipoOrigen == "empresa") {
      stockOrigen = data['stock_general'] as Map<String, dynamic>? ?? {};
    } else {
      final stockObra = data['stock'] as Map<String, dynamic>? ?? {};
      // Convertir formato de obra a formato simple para validación
      for (final entry in stockObra.entries) {
        final stockInfo = entry.value as Map<String, dynamic>? ?? {};
        stockOrigen[entry.key] = stockInfo['cantidad'] ?? 0;
      }
    }
    
    for (final entry in articulos.entries) {
      final articuloId = entry.key;
      final cantidadSolicitada = entry.value;
      final stockDisponible = stockOrigen[articuloId] as int? ?? 0;
      
      if (stockDisponible < cantidadSolicitada) {
        throw Exception(
          'Stock insuficiente para artículo $articuloId. '
          'Disponible: $stockDisponible, Solicitado: $cantidadSolicitada'
        );
      }
    }
  }

  /// Generar número de albarán secuencial
  Future<String> _generarNumeroAlbaran() async {
    final counterRef = _db.collection('counters').doc('albaranes');
    
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      
      int nextNumber;
      if (!snapshot.exists) {
        nextNumber = 1;
        transaction.set(counterRef, {'lastNumber': 1});
      } else {
        final currentNumber = snapshot.data()?['lastNumber'] ?? 0;
        nextNumber = currentNumber + 1;
        transaction.update(counterRef, {'lastNumber': nextNumber});
      }
      
      final year = DateTime.now().year;
      return 'ALB-$year-${nextNumber.toString().padLeft(6, '0')}';
    });
  }

  /// Obtener stock disponible de una entidad
  Future<Map<String, int>> obtenerStockDisponible(String entidadId, String tipoEntidad) async {
    try {
      final doc = await _db.collection(tipoEntidad == "empresa" ? "empresas" : "obras")
          .doc(entidadId)
          .get();
      
      if (!doc.exists) return {};
      
      final data = doc.data() ?? {};
      final Map<String, int> stock = {};
      
      if (tipoEntidad == "empresa") {
        final stockGeneral = data['stock_general'] as Map<String, dynamic>? ?? {};
        for (final entry in stockGeneral.entries) {
          stock[entry.key] = entry.value as int? ?? 0;
        }
      } else {
        final stockObra = data['stock'] as Map<String, dynamic>? ?? {};
        for (final entry in stockObra.entries) {
          final stockInfo = entry.value as Map<String, dynamic>? ?? {};
          stock[entry.key] = stockInfo['cantidad'] as int? ?? 0;
        }
      }
      
      return stock;
    } catch (e) {
      print('Error al obtener stock: $e');
      return {};
    }
  }
}

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}