// lib/screens/obra/obras_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ObrasScreen extends StatefulWidget {
  final String empresaId;
  
  const ObrasScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<ObrasScreen> createState() => _ObrasScreenState();
}

class _ObrasScreenState extends State<ObrasScreen> {
  List<Map<String, dynamic>> _obras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObras();
  }

  Future<void> _loadObras() async {
    // Simulando carga de obras desde Firebase
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _obras = [
        {
          'id': '1',
          'nombre': 'Construcción Edificio A',
          'direccion': 'Calle Principal 123',
          'estado': 'activa',
          'fechaInicio': DateTime(2024, 1, 15),
          'fechaFin': DateTime(2024, 6, 30),
          'responsable': 'Juan Pérez',
          'presupuesto': 500000.0,
        },
        {
          'id': '2',
          'nombre': 'Renovación Casa Familiar',
          'direccion': 'Avenida Central 456',
          'estado': 'activa',
          'fechaInicio': DateTime(2024, 2, 1),
          'fechaFin': DateTime(2024, 4, 15),
          'responsable': 'María García',
          'presupuesto': 150000.0,
        },
        {
          'id': '3',
          'nombre': 'Ampliación Oficinas',
          'direccion': 'Plaza de Armas 789',
          'estado': 'completada',
          'fechaInicio': DateTime(2023, 10, 1),
          'fechaFin': DateTime(2024, 1, 31),
          'responsable': 'Carlos López',
          'presupuesto': 300000.0,
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obras'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadObras();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _obras.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadObras,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _obras.length,
                    itemBuilder: (context, index) {
                      final obra = _obras[index];
                      return _buildObraCard(obra);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNuevaObra,
        backgroundColor: Colors.brown,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Obra'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay obras registradas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega tu primera obra para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildObraCard(Map<String, dynamic> obra) {
    final estado = obra['estado'] as String;
    final esActiva = estado == 'activa';
    final fechaInicio = obra['fechaInicio'] as DateTime;
    final fechaFin = obra['fechaFin'] as DateTime;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    obra['nombre'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: esActiva ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    obra['direccion'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Responsable: ${obra['responsable']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatearFecha(fechaInicio)} - ${_formatearFecha(fechaFin)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presupuesto: \$${_formatearMonto(obra['presupuesto'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _verDetallesObra(obra),
                      icon: const Icon(Icons.visibility),
                      tooltip: 'Ver detalles',
                    ),
                    if (esActiva) ...[
                      IconButton(
                        onPressed: () => _editarObra(obra),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        onPressed: () => _completarObra(obra),
                        icon: const Icon(Icons.check_circle),
                        tooltip: 'Completar',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _formatearMonto(double monto) {
    return monto.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _mostrarDialogoNuevaObra() {
    final nombreController = TextEditingController();
    final direccionController = TextEditingController();
    final responsableController = TextEditingController();
    final presupuestoController = TextEditingController();
    DateTime fechaInicio = DateTime.now();
    DateTime fechaFin = DateTime.now().add(const Duration(days: 90));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Obra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la obra',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: responsableController,
                decoration: const InputDecoration(
                  labelText: 'Responsable',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: presupuestoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validarFormularioObra(
                nombreController.text,
                direccionController.text,
                responsableController.text,
                presupuestoController.text,
              )) {
                _crearObra(
                  nombreController.text,
                  direccionController.text,
                  responsableController.text,
                  double.parse(presupuestoController.text),
                  fechaInicio,
                  fechaFin,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  bool _validarFormularioObra(String nombre, String direccion, String responsable, String presupuesto) {
    if (nombre.isEmpty) {
      _mostrarMensaje('El nombre de la obra es requerido');
      return false;
    }
    if (direccion.isEmpty) {
      _mostrarMensaje('La dirección es requerida');
      return false;
    }
    if (responsable.isEmpty) {
      _mostrarMensaje('El responsable es requerido');
      return false;
    }
    if (double.tryParse(presupuesto) == null) {
      _mostrarMensaje('El presupuesto debe ser un número válido');
      return false;
    }
    return true;
  }

  void _crearObra(String nombre, String direccion, String responsable, double presupuesto, DateTime fechaInicio, DateTime fechaFin) {
    final nuevaObra = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'nombre': nombre,
      'direccion': direccion,
      'estado': 'activa',
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'responsable': responsable,
      'presupuesto': presupuesto,
    };

    setState(() {
      _obras.insert(0, nuevaObra);
    });

    _mostrarMensaje('Obra creada exitosamente');
  }

  void _verDetallesObra(Map<String, dynamic> obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(obra['nombre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${obra['id']}'),
            const SizedBox(height: 8),
            Text('Dirección: ${obra['direccion']}'),
            const SizedBox(height: 8),
            Text('Estado: ${obra['estado']}'),
            const SizedBox(height: 8),
            Text('Responsable: ${obra['responsable']}'),
            const SizedBox(height: 8),
            Text('Presupuesto: \$${_formatearMonto(obra['presupuesto'])}'),
            const SizedBox(height: 8),
            Text('Fecha inicio: ${_formatearFecha(obra['fechaInicio'])}'),
            const SizedBox(height: 8),
            Text('Fecha fin: ${_formatearFecha(obra['fechaFin'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editarObra(Map<String, dynamic> obra) {
    _mostrarMensaje('Función de edición en desarrollo');
  }

  void _completarObra(Map<String, dynamic> obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Obra'),
        content: Text('¿Está seguro de que desea marcar "${obra['nombre']}" como completada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                obra['estado'] = 'completada';
              });
              Navigator.pop(context);
              _mostrarMensaje('Obra completada exitosamente');
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}