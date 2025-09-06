import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaSelectionScreen extends StatefulWidget {
  const EmpresaSelectionScreen({Key? key}) : super(key: key);

  @override
  _EmpresaSelectionScreenState createState() => _EmpresaSelectionScreenState();
}

class _EmpresaSelectionScreenState extends State<EmpresaSelectionScreen> 
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showDeleteOptions = false; // Nuevo: para mostrar opciones de eliminación

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkLastEmpresa();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _checkLastEmpresa() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmpresaId = prefs.getString('last_empresa_id');
    final lastEmpresaNombre = prefs.getString('last_empresa_nombre');
    
    if (lastEmpresaId != null && lastEmpresaNombre != null) {
      _showLastEmpresaDialog(lastEmpresaId, lastEmpresaNombre);
    }
  }

  void _showLastEmpresaDialog(String empresaId, String empresaNombre) {
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.history, color: Colors.blue),
              SizedBox(width: 8),
              Text('Última empresa'),
            ],
          ),
          content: Text('¿Quieres continuar con $empresaNombre?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _navigateToHome(empresaId, empresaNombre);
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nuevo: AppBar con opciones de desarrollo
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'toggle_delete':
                  setState(() {
                    _showDeleteOptions = !_showDeleteOptions;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showDeleteOptions 
                        ? '⚠️ Modo eliminación activado' 
                        : 'Modo eliminación desactivado'),
                      backgroundColor: _showDeleteOptions 
                        ? Colors.orange.shade600 
                        : Colors.blue.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
                case 'delete_all':
                  _showDeleteAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_delete',
                child: Row(
                  children: [
                    Icon(_showDeleteOptions ? Icons.visibility_off : Icons.delete_outline, 
                         size: 20),
                    const SizedBox(width: 12),
                    Text(_showDeleteOptions ? 'Ocultar eliminar' : 'Mostrar eliminar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Eliminar todas', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Buscador
                  _buildSearchBar(),
                  
                  // Lista de empresas
                  _buildEmpresasList(),
                  
                  // Botón agregar empresa
                  _buildAddButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inventario Multiempresa',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona una empresa para continuar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          // Nuevo: Indicador de modo eliminación
          if (_showDeleteOptions) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'MODO ELIMINACIÓN ACTIVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar empresa...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildEmpresasList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('empresas').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Cargando empresas...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar empresas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verifica tu conexión a internet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final empresas = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = (data['nombre'] ?? '').toString().toLowerCase();
                return nombre.contains(_searchQuery);
              }).toList();

              if (empresas.isEmpty && _searchQuery.isNotEmpty) {
                return _buildNoResultsState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: empresas.length,
                itemBuilder: (context, index) {
                  final empresa = empresas[index];
                  final data = empresa.data() as Map<String, dynamic>;
                  
                  return _buildEmpresaCard(
                    empresa.id,
                    data['nombre'] ?? 'Sin nombre',
                    data['descripcion'] ?? 'Sin descripción',
                    data['fechaCreacion'] as Timestamp?,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpresaCard(String id, String nombre, String descripcion, Timestamp? fechaCreacion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToHome(id, nombre),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (fechaCreacion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Creada: ${_formatDate(fechaCreacion.toDate())}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Nuevo: Botón de eliminar (solo visible en modo eliminación)
              if (_showDeleteOptions) ...[
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade600,
                  ),
                  onPressed: () => _showDeleteEmpresaDialog(id, nombre),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay empresas registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera empresa para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _mostrarDialogoNuevaEmpresa,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear Empresa'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron empresas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _mostrarDialogoNuevaEmpresa,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Agregar Nueva Empresa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // NUEVOS MÉTODOS PARA ELIMINACIÓN

  void _showDeleteEmpresaDialog(String empresaId, String empresaNombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Empresa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar la empresa "$empresaNombre"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará TODOS los datos asociados (artículos, movimientos, etc.) y NO se puede deshacer.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteEmpresa(empresaId, empresaNombre);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Todas las Empresas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres eliminar TODAS las empresas?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'PELIGRO',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Se eliminarán TODAS las empresas\n• Se perderán TODOS los artículos\n• Se perderán TODOS los movimientos\n• Esta acción NO se puede deshacer',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAllEmpresas();
            },
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmpresa(String empresaId, String empresaNombre) async {
    setState(() => _isLoading = true);

    try {
      // Eliminar todas las subcolecciones de la empresa
      final batch = _firestore.batch();

      // Eliminar artículos
      final articulosRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('articulos');
      final articulosSnapshot = await articulosRef.get();
      
      for (var doc in articulosSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar movimientos
      final movimientosRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('movimientos');
      final movimientosSnapshot = await movimientosRef.get();
      
      for (var doc in movimientosSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar clientes
      final clientesRef = _firestore
          .collection('empresas')
          .doc(empresaId)
          .collection('clientes');
      final clientesSnapshot = await clientesRef.get();
      
      for (var doc in clientesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar la empresa
      final empresaRef = _firestore.collection('empresas').doc(empresaId);
      batch.delete(empresaRef);

      // Ejecutar el batch
      await batch.commit();

      // Limpiar preferencias si era la empresa seleccionada
      final prefs = await SharedPreferences.getInstance();
      final lastEmpresaId = prefs.getString('last_empresa_id');
      if (lastEmpresaId == empresaId) {
        await prefs.remove('last_empresa_id');
        await prefs.remove('last_empresa_nombre');
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Empresa "$empresaNombre" eliminada exitosamente'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar empresa: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllEmpresas() async {
    setState(() => _isLoading = true);

    try {
      // Obtener todas las empresas
      final empresasSnapshot = await _firestore.collection('empresas').get();
      
      final batch = _firestore.batch();

      for (var empresaDoc in empresasSnapshot.docs) {
        final empresaId = empresaDoc.id;

        // Eliminar artículos
        final articulosRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('articulos');
        final articulosSnapshot = await articulosRef.get();
        
        for (var doc in articulosSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Eliminar movimientos
        final movimientosRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('movimientos');
        final movimientosSnapshot = await movimientosRef.get();
        
        for (var doc in movimientosSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Eliminar clientes
        final clientesRef = _firestore
            .collection('empresas')
            .doc(empresaId)
            .collection('clientes');
        final clientesSnapshot = await clientesRef.get();
        
        for (var doc in clientesSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Eliminar la empresa
        batch.delete(empresaDoc.reference);
      }

      // Ejecutar el batch
      await batch.commit();

      // Limpiar preferencias
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_empresa_id');
      await prefs.remove('last_empresa_nombre');

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Todas las empresas han sido eliminadas'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar empresas: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // MÉTODOS AUXILIARES (sin cambios)

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _navigateToHome(String empresaId, String empresaNombre) async {
    setState(() => _isLoading = true);
    
    // Guardar empresa seleccionada
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_empresa_id', empresaId);
    await prefs.setString('last_empresa_nombre', empresaNombre);

    setState(() => _isLoading = false);

    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'empresaId': empresaId,
          'empresaNombre': empresaNombre,
        },
      );
    }
  }

  void _mostrarDialogoNuevaEmpresa() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.business, color: Colors.blue),
            SizedBox(width: 8),
            Text('Nueva Empresa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la empresa *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nombreController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _crearNuevaEmpresa(
                  nombreController.text.trim(),
                  descripcionController.text.trim(),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _crearNuevaEmpresa(String nombre, String descripcion) async {
    setState(() => _isLoading = true);

    try {
      final empresaData = {
        'nombre': nombre,
        'descripcion': descripcion,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'activa': true,
      };

      final docRef = await _firestore.collection('empresas').add(empresaData);
      
      setState(() => _isLoading = false);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Empresa "$nombre" creada exitosamente'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navegar automáticamente a la nueva empresa
        _navigateToHome(docRef.id, nombre);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear empresa: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}