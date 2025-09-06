// lib/services/validacion_service.dart
class ValidacionService {
  // Validar datos de artículo antes de guardar
  static Map<String, String> validarArticulo({
    required String nombre,
    required double precio,
    required int stock,
    String? codigoBarras,
    String? categoria,
  }) {
    final errores = <String, String>{};
    
    if (nombre.trim().isEmpty) {
      errores['nombre'] = 'El nombre es requerido';
    }
    
    if (precio < 0) {
      errores['precio'] = 'El precio debe ser mayor o igual a 0';
    }
    
    if (stock < 0) {
      errores['stock'] = 'El stock no puede ser negativo';
    }
    
    if (codigoBarras != null && codigoBarras.isNotEmpty && codigoBarras.length < 5) {
      errores['codigoBarras'] = 'El código de barras debe tener al menos 5 caracteres';
    }
    
    return errores;
  }

  // Validar cantidad para traspaso
  static String? validarCantidadTraspaso(int cantidad, int stockDisponible) {
    if (cantidad <= 0) return 'La cantidad debe ser mayor a 0';
    if (cantidad > stockDisponible) return 'Stock insuficiente';
    return null;
  }
}