enum UserRole {
  admin,
  encargadoAlmacen,
  jefeObra,
  mecanico,
  usuarioBasico,
}

class Permissions {
  static final Map<String, List<UserRole>> access = {
    '/': [UserRole.admin, UserRole.encargadoAlmacen, UserRole.jefeObra, UserRole.mecanico, UserRole.usuarioBasico],
    '/login': [UserRole.admin, UserRole.encargadoAlmacen, UserRole.jefeObra, UserRole.mecanico, UserRole.usuarioBasico],
    '/entradas_inventario': [UserRole.admin, UserRole.encargadoAlmacen],
    '/salidas_inventario': [UserRole.admin, UserRole.encargadoAlmacen, UserRole.jefeObra],
    '/traspasos': [UserRole.admin, UserRole.encargadoAlmacen],
    '/obras': [UserRole.admin, UserRole.jefeObra],
    '/clientes': [UserRole.admin, UserRole.encargadoAlmacen, UserRole.jefeObra],
    '/proveedores': [UserRole.admin, UserRole.encargadoAlmacen],
    '/articulos': [UserRole.admin, UserRole.encargadoAlmacen],
    '/tabs/vehiculos': [UserRole.admin, UserRole.mecanico],
  };

  static bool canAccess(String route, UserRole role) {
    final allowed = access[route];
    if (allowed == null) return false;
    return allowed.contains(role);
  }
}
