import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empresa.dart';

class EmpresaProvider with ChangeNotifier {
  List<Empresa> _empresas = [];
  bool _cargando = false;
  String? _error;
  Empresa? _empresaSeleccionada;

  List<Empresa> get empresas => _empresas;
  bool get cargando => _cargando;
  String? get error => _error;
  Empresa? get empresaSeleccionada => _empresaSeleccionada;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cargarEmpresas() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('empresas')
          .where('activa', isEqualTo: true)
          .orderBy('nombre')
          .get();

      _empresas = snapshot.docs.map((doc) => Empresa.fromFirestore(doc)).toList();
    } catch (e) {
      _error = 'Error al cargar empresas: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Empresa?> obtenerEmpresa(String id) async {
    try {
      final doc = await _firestore.collection('empresas').doc(id).get();
      return doc.exists ? Empresa.fromFirestore(doc) : null;
    } catch (e) {
      _error = 'Error obteniendo empresa: $e';
      return null;
    }
  }

  void seleccionarEmpresa(Empresa empresa) {
    _empresaSeleccionada = empresa;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _empresaSeleccionada = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}