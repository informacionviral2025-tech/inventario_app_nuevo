// lib/widgets/search_filters_widget.dart
import 'package:flutter/material.dart';

class SearchFiltersWidget extends StatefulWidget {
  final Function(String query, String? categoria, bool? stockBajo, bool? sinStock) onSearch;
  final List<String> categorias;
  final bool showStockFilters;
  final bool showCategoryFilter;

  const SearchFiltersWidget({
    Key? key,
    required this.onSearch,
    required this.categorias,
    this.showStockFilters = true,
    this.showCategoryFilter = true,
  }) : super(key: key);

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  bool _stockBajo = false;
  bool _sinStock = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    widget.onSearch(
      _searchController.text.trim(),
      _selectedCategoria,
      _stockBajo ? true : null,
      _sinStock ? true : null,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoria = null;
      _stockBajo = false;
      _sinStock = false;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Búsqueda por texto
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar artículo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            
            // Filtros
            Row(
              children: [
                // Filtro por categoría
                if (widget.showCategoryFilter) ...[
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ...widget.categorias.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoria = value;
                          _performSearch();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Filtros de stock
                if (widget.showStockFilters) ...[
                  Expanded(
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('Stock bajo', style: TextStyle(fontSize: 12)),
                          value: _stockBajo,
                          onChanged: (value) {
                            setState(() {
                              _stockBajo = value ?? false;
                              if (_stockBajo) _sinStock = false;
                              _performSearch();
                            });
                          },
                          controlAffinity: ListControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Sin stock', style: TextStyle(fontSize: 12)),
                          value: _sinStock,
                          onChanged: (value) {
                            setState(() {
                              _sinStock = value ?? false;
                              if (_sinStock) _stockBajo = false;
                              _performSearch();
                            });
                          },
                          controlAffinity: ListControlAffinity.leading,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            // Botón para limpiar filtros
            if (_hasActiveFilters)
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar filtros'),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _searchController.text.isNotEmpty ||
        _selectedCategoria != null ||
        _stockBajo ||
        _sinStock;
  }
}