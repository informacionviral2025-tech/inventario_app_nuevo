enum UserRole {
  gerente,
  empleado,
  supervisor,
  almacenero;

  String get displayName {
    switch (this) {
      case UserRole.gerente:
        return 'Gerente';
      case UserRole.empleado:
        return 'Empleado';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.almacenero:
        return 'Almacenero';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'gerente':
        return UserRole.gerente;
      case 'empleado':
        return UserRole.empleado;
      case 'supervisor':
        return UserRole.supervisor;
      case 'almacenero':
        return UserRole.almacenero;
      default:
        return UserRole.empleado;
    }
  }
}