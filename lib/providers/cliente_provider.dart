// lib/providers/cliente_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';

class ClienteProvider with ChangeNotifier {
  List<Cliente> _clientes = [];
  bool _cargando = false;
  String? _error;
  String? _empresaId;

  List<Cliente> get clientes => _clientes;
  bool get cargando => _cargando;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setEmpresaId(String empresaId) {
    _empresaId = empresaId;
  }

  Stream<List<Cliente>> getClientesStream(String empresaId) {
    return _firestore
        .collection('clientes')
        .where('empresaId', isEqualTo: empresaId)
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Cliente.fromFirestore(doc)).toList());
  }

  Future<void> cargarClientes({bool? activos}) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('clientes')
          .where('empresaId', isEqualTo: _empresaId);

      if (activos != null) {
        query = query.where('activo', isEqualTo: activos);
      }

      query = query.orderBy('nombre');

      final snapshot = await query.get();

      _clientes = snapshot.docs.map((doc) => Cliente.fromFirestore(doc)).toList();
      
    } catch (e) {
      _error = 'Error al cargar clientes: $e';
      if (kDebugMode) {
        print('Error cargando clientes: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Cliente?> obtenerCliente(String id) async {
    try {
      final doc = await _firestore.collection('clientes').doc(id).get();
      
      if (doc.exists) {
        return Cliente.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error = 'Error obteniendo cliente: $e';
      if (kDebugMode) {
        print('Error obteniendo cliente: $e');
      }
      return null;
    }
  }

  Future<bool> crearCliente(Cliente cliente) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return false;
    }

    try {
      final clienteConEmpresa = cliente.copyWith(empresaId: _empresaId!);
      final docRef = _firestore.collection('clientes').doc();
      final nuevoCliente = clienteConEmpresa.copyWith(firebaseId: docRef.id);
      
      await docRef.set(nuevoCliente.toFirestore());
      
      _clientes.add(nuevoCliente);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Error creando cliente: $e';
      if (kDebugMode) {
        print('Error creando cliente: $e');
      }
      return false;
    }
  }

  Future<bool> actualizarCliente(Cliente cliente) async {
    try {
      if (cliente.firebaseId == null) {
        throw Exception('El cliente no tiene ID de Firebase');
      }

      await _firestore.collection('clientes').doc(cliente.firebaseId!).update(cliente.toFirestore());
      
      final index = _clientes.indexWhere((c) => c.firebaseId == cliente.firebaseId);
      if (index != -1) {
        _clientes[index] = cliente;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando cliente: $e';
      if (kDebugMode) {
        print('Error actualizando cliente: $e');
      }
      return false;
    }
  }

  Future<bool> eliminarCliente(String id) async {
    try {
      await _firestore.collection('clientes').doc(id).update({'activo': false});
      
      _clientes.removeWhere((cliente) => cliente.firebaseId == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Error eliminando cliente: $e';
      if (kDebugMode) {
        print('Error eliminando cliente: $e');
      }
      return false;
    }
  }

  List<Cliente> buscarClientes(String query) {
    if (query.isEmpty) return _clientes;
    
    final queryLower = query.toLowerCase();
    return _clientes.where((cliente) =>
      cliente.nombre.toLowerCase().contains(queryLower) ||
      (cliente.razonSocial?.toLowerCase().contains(queryLower) ?? false) ||
      (cliente.nif?.toLowerCase().contains(queryLower) ?? false) ||
      (cliente.email?.toLowerCase().contains(queryLower) ?? false) ||
      (cliente.ciudad?.toLowerCase().contains(queryLower) ?? false)
    ).toList();
  }

  List<Cliente> filtrarPorCiudad(String ciudad) {
    return _clientes.where((cliente) => cliente.ciudad == ciudad).toList();
  }

  List<Cliente> filtrarPorLimiteCredito(double limiteMinimo) {
    return _clientes.where((cliente) => cliente.limiteCredito >= limiteMinimo).toList();
  }

  List<Cliente> get clientesActivos => _clientes.where((c) => c.activo).toList();
  List<Cliente> get clientesInactivos => _clientes.where((c) => !c.activo).toList();

  List<Cliente> get clientesConCreditoExcedido {
    return _clientes.where((cliente) => cliente.activo).toList();
  }

  Map<String, dynamic> get estadisticas {
    final total = _clientes.length;
    final activos = _clientes.where((c) => c.activo).length;
    final inactivos = total - activos;

    return {
      'total': total,
      'activos': activos,
      'inactivos': inactivos,
    };
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void forzarRecarga() {
    _clientes = [];
    notifyListeners();
  }

  Cliente? obtenerPorNif(String nif) {
    try {
      return _clientes.firstWhere((cliente) => cliente.nif == nif);
    } catch (e) {
      return null;
    }
  }

  Cliente? obtenerPorEmail(String email) {
    try {
      return _clientes.firstWhere((cliente) => cliente.email == email);
    } catch (e) {
      return null;
    }
  }

  List<Cliente> obtenerPorRangoCredito(double min, double max) {
    return _clientes.where((cliente) => 
      cliente.limiteCredito >= min && cliente.limiteCredito <= max
    ).toList();
  }

  Future<bool> actualizarLimiteCredito(String clienteId, double nuevoLimite) async {
    try {
      final cliente = await obtenerCliente(clienteId);
      if (cliente == null) return false;

      final clienteActualizado = cliente.copyWith(limiteCredito: nuevoLimite);
      return await actualizarCliente(clienteActualizado);
    } catch (e) {
      _error = 'Error actualizando límite de crédito: $e';
      return false;
    }
  }

  Future<bool> actualizarDiasPago(String clienteId, int nuevosDias) async {
    try {
      final cliente = await obtenerCliente(clienteId);
      if (cliente == null) return false;

      final clienteActualizado = cliente.copyWith(diasPago: nuevosDias);
      return await actualizarCliente(clienteActualizado);
    } catch (e) {
      _error = 'Error actualizando días de pago: $e';
      return false;
    }
  }
}