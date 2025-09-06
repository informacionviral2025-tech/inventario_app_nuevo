import 'package:flutter/material.dart';
import '../../models/empresa.dart';
import '../../services/database_service.dart';

class ReportesTab extends StatefulWidget {
  final Empresa empresa;

  const ReportesTab({
    super.key,
    required this.empresa,
  });

  @override
  State<ReportesTab> createState() => _ReportesTabState();
}

class _ReportesTabState extends State<ReportesTab> {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  bool _isLoading = true;
  Map<String, dynamic> _estadisticas = {};

  @override
  void initState() {
    super.initState();
    _loadEstadisticas();
  }

  Future<void> _loadEstadisticas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articulos = await _databaseService.getArticulos();
      final categorias = await _databaseService.getCategorias();

      // Calcular estadísticas
      final totalArticulos = articulos.length;
      final totalValorInventario = articulos.fold<double>(
        0.0,
        (sum, articulo) => sum + (articulo.precio * articulo.stock),
      );
      final totalStock = articulos.fold<int>(
        0,
        (sum, articulo) => sum + articulo.stock,
      );
      
      // Artículos con stock bajo (menos de 10 unidades)
      final articulosStockBajo = articulos.where((a) => a.stock < 10).length;
      
      // Artículos sin stock
      final articulosSinStock = articulos.where((a) => a.stock == 0).length;
      
      // Artículos por categoría
      final articulosPorCategoria = <String, int>{};
      for (final categoria in categorias) {
        articulosPorCategoria[categoria] = 
            articulos.where((a) => a.categoria == categoria).length;
      }
      
      // Top 5 artículos más caros
      final articulosCaros = [...articulos]
        ..sort((a, b) => b.precio.compareTo(a.precio));
      final top5Caros = articulosCaros.take(5).toList();

      setState(() {
        _estadisticas = {
          'totalArticulos': totalArticulos,
          'totalValorInventario': totalValorInventario,
          'totalStock': totalStock,
          'articulosStockBajo': articulosStockBajo,
          'articulosSinStock': articulosSinStock,
          'articulosPorCategoria': articulosPorCategoria,
          'top5Caros': top