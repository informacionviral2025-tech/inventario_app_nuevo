import 'package:flutter/material.dart';
import 'permissions.dart';

class FeatureGate extends StatelessWidget {
  final String route;
  final UserRole role;
  final Widget child;
  final Widget? fallback;

  const FeatureGate({
    Key? key,
    required this.route,
    required this.role,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canAccess = Permissions.canAccess(route, role);

    if (canAccess) return child;
    if (fallback != null) return fallback!;
    return const SizedBox.shrink();
  }
}
