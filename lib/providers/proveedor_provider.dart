import 'package:flutter/foundation.dart';
import '../models/proveedor.dart';
import '../services/proveedor_service.dart';

class ProveedorProvider with ChangeNotifier {
  List<Proveedor> _proveedores = [];
  bool _cargando = false;
  String? _error;
  String? _empresaId;

  List<Proveedor> get proveedores => _proveedores;
  bool get cargando => _cargando;
  String? get error => _error;

  late ProveedorService _proveedorService;

  void setEmpresaId(String empresaId) {
    _empresaId = empresaId;
    _proveedorService = ProveedorService(empresaId);
  }

  Future<void> cargarProveedores({bool? soloActivos}) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      if (soloActivos == true) {
        _proveedores = await _proveedorService.getProveedoresActivos().first;
      } else {
        _proveedores = await _proveedorService.getProveedores().first;
      }
    } catch (e) {
      _error = 'Error al cargar proveedores: $e';
      if (kDebugMode) {
        print('Error cargando proveedores: $e');
      }
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Proveedor?> obtenerProveedor(String id) async {
    try {
      final proveedorLocal = _proveedores.firstWhere(
        (prov) => prov.id == id,
        orElse: () => null as Proveedor,
      );

      if (proveedorLocal != null) return proveedorLocal;
      return await _proveedorService.obtenerProveedor(id);
    } catch (e) {
      _error = 'Error obteniendo proveedor: $e';
      return null;
    }
  }

  Future<bool> crearProveedor(Proveedor proveedor) async {
    if (_empresaId == null) {
      _error = 'No se ha configurado la empresa';
      return false;
    }

    try {
      final existeRFC = await _proveedorService.existeProveedorConRFC(
        proveedor.rfc ?? '',
      );
      
      if (existeRFC) {
        _error = 'Ya existe un proveedor con este RFC';
        return false;
      }

      final proveedorId = await _proveedorService.agregarProveedor(proveedor);
      final proveedorConId = proveedor.copyWith(id: proveedorId);
      
      _proveedores.add(proveedorConId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Error creando proveedor: $e';
      return false;
    }
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    try {
      if (proveedor.rfc != null) {
        final existeRFC = await _proveedorService.existeProveedorConRFC(
          proveedor.rfc!,
          excluirId: proveedor.id,
        );
        
        if (existeRFC) {
          _error = 'Ya existe otro proveedor con este RFC';
          return false;
        }
      }

      await _proveedorService.actualizarProveedor(proveedor);
      
      final index = _proveedores.indexWhere((prov) => prov.id == proveedor.id);
      if (index != -1) {
        _proveedores[index] = proveedor;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error actualizando proveedor: $e';
      return false;
    }
  }

  List<Proveedor> buscarProveedores(String query) {
    if (query.isEmpty) return _proveedores;
    
    final queryLower = query.toLowerCase();
    return _proveedores.where((proveedor) =>
      proveedor.nombre.toLowerCase().contains(queryLower) ||
      (proveedor.rfc?.toLowerCase().contains(queryLower) ?? false) ||
      (proveedor.email?.toLowerCase().contains(queryLower) ?? false)
    ).toList();
  }

  List<Proveedor> get proveedoresActivos => _proveedores.where((prov) => prov.activo).toList();

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void forzarRecarga() {
    _proveedores = [];
    notifyListeners();
  }
}