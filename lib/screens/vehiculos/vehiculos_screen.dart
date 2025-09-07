import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/vehiculo.dart';
import 'vehiculo_detail_screen.dart';

class VehiculosScreen extends StatefulWidget {
  final String empresaId;

  const VehiculosScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Vehiculo> _vehiculos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVehiculos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehiculos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('vehiculos')
          .orderBy('matricula')
          .get();

      setState(() {
        _vehiculos = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Vehiculo.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar vehículos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Vehiculo> _getFilteredVehiculos(EstadoVehiculo? estado) {
    var filtered = _vehiculos;

    if (estado != null) {
      filtered = filtered.where((v) => v.estado == estado).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vehiculo) {
        return vehiculo.matricula.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehiculo.marca.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehiculo.modelo.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showVehiculoDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => _showMapView(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Todos (${_vehiculos.length})'),
            Tab(text: 'Activos (${_getFilteredVehiculos(EstadoVehiculo.activo).length})'),
            Tab(text: 'Mantenimiento (${_getFilteredVehiculos(EstadoVehiculo.mantenimiento).length})'),
            Tab(text: 'Inactivos (${_getFilteredVehiculos(EstadoVehiculo.inactivo).length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar vehículos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVehiculosList(_getFilteredVehiculos(null)),
                      _buildVehiculosList(_getFilteredVehiculos(EstadoVehiculo.activo)),
                      _buildVehiculosList(_getFilteredVehiculos(EstadoVehiculo.mantenimiento)),
                      _buildVehiculosList(_getFilteredVehiculos(EstadoVehiculo.inactivo)),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVehiculoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Vehículo'),
      ),
    );
  }

  Widget _buildVehiculosList(List<Vehiculo> vehiculos) {
    if (vehiculos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay vehículos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vehiculos.length,
      itemBuilder: (context, index) {
        final vehiculo = vehiculos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEstadoColor(vehiculo.estado),
              child: Icon(
                _getTipoIcon(vehiculo.tipo),
                color: Colors.white,
              ),
            ),
            title: Text(
              vehiculo.matricula,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vehiculo.marca} ${vehiculo.modelo}'),
                Text('${vehiculo.tipo.displayName} - ${vehiculo.estado.displayName}'),
                if (vehiculo.obraAsignada != null)
                  Text(
                    'Asignado a: ${vehiculo.obraAsignada}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: 16,
                  color: _getCombustibleColor(vehiculo.nivelCombustible),
                ),
                Text(
                  '${vehiculo.nivelCombustible}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCombustibleColor(vehiculo.nivelCombustible),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${vehiculo.kilometraje} km',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => _showVehiculoDetail(vehiculo),
            onLongPress: () => _showVehiculoOptions(vehiculo),
          ),
        );
      },
    );
  }

  Color _getEstadoColor(EstadoVehiculo estado) {
    switch (estado) {
      case EstadoVehiculo.activo:
        return Colors.green;
      case EstadoVehiculo.mantenimiento:
        return Colors.orange;
      case EstadoVehiculo.inactivo:
        return Colors.red;
      case EstadoVehiculo.reparacion:
        return Colors.red[800]!;
    }
  }

  IconData _getTipoIcon(TipoVehiculo tipo) {
    switch (tipo) {
      case TipoVehiculo.camion:
        return Icons.local_shipping;
      case TipoVehiculo.furgoneta:
        return Icons.airport_shuttle;
      case TipoVehiculo.coche:
        return Icons.directions_car;
      case TipoVehiculo.maquinaria:
        return Icons.construction;
    }
  }

  Color _getCombustibleColor(int nivel) {
    if (nivel >= 50) return Colors.green;
    if (nivel >= 25) return Colors.orange;
    return Colors.red;
  }

  void _showVehiculoDetail(Vehiculo vehiculo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehiculoDetailScreen(
          vehiculo: vehiculo,
          empresaId: widget.empresaId,
        ),
      ),
    ).then((_) => _loadVehiculos());
  }

  void _showVehiculoOptions(Vehiculo vehiculo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              _showVehiculoDialog(vehiculo: vehiculo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Ver en Mapa'),
            onTap: () {
              Navigator.pop(context);
              _showOnMap(vehiculo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Programar Mantenimiento'),
            onTap: () {
              Navigator.pop(context);
              _scheduleMaintenanceDialog(vehiculo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_gas_station),
            title: const Text('Registrar Combustible'),
            onTap: () {
              Navigator.pop(context);
              _registerFuelDialog(vehiculo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Asignar a Obra'),
            onTap: () {
              Navigator.pop(context);
              _assignToProjectDialog(vehiculo);
            },
          ),
          if (vehiculo.estado != EstadoVehiculo.inactivo)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Desactivar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deactivateVehicle(vehiculo);
              },
            ),
        ],
      ),
    );
  }

  void _showVehiculoDialog({Vehiculo? vehiculo}) {
    showDialog(
      context: context,
      builder: (context) => VehiculoDialog(
        empresaId: widget.empresaId,
        vehiculo: vehiculo,
        onSaved: () {
          _loadVehiculos();
        },
      ),
    );
  }

  void _showMapView() {
    // Implementar vista de mapa con ubicación de vehículos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vista de mapa en desarrollo'),
      ),
    );
  }

  void _showOnMap(Vehiculo vehiculo) {
    // Implementar mostrar vehículo específico en mapa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mostrando ${vehiculo.matricula} en el mapa'),
      ),
    );
  }

  void _scheduleMaintenanceDialog(Vehiculo vehiculo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programar Mantenimiento - ${vehiculo.matricula}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mantenimiento Preventivo'),
              subtitle: const Text('Revisión general'),
              onTap: () {
                Navigator.pop(context);
                _programarMantenimiento(vehiculo, TipoMantenimiento.preventivo);
              },
            ),
            ListTile(
              title: const Text('Cambio de Aceite'),
              subtitle: const Text('Cada 10,000 km'),
              onTap: () {
                Navigator.pop(context);
                _programarMantenimiento(vehiculo, TipoMantenimiento.aceite);
              },
            ),
            ListTile(
              title: const Text('ITV'),
              subtitle: const Text('Inspección técnica'),
              onTap: () {
                Navigator.pop(context);
                _programarMantenimiento(vehiculo, TipoMantenimiento.itv);
              },
            ),
            ListTile(
              title: const Text('Reparación'),
              subtitle: const Text('Avería específica'),
              onTap: () {
                Navigator.pop(context);
                _programarMantenimiento(vehiculo, TipoMantenimiento.reparacion);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _registerFuelDialog(Vehiculo vehiculo) {
    final litrosController = TextEditingController();
    final costoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar Combustible - ${vehiculo.matricula}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: litrosController,
              decoration: const InputDecoration(
                labelText: 'Litros',
                suffixText: 'L',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costoController,
              decoration: const InputDecoration(
                labelText: 'Costo',
                prefixText: '€',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _registrarCombustible(
                vehiculo,
                double.tryParse(litrosController.text) ?? 0,
                double.tryParse(costoController.text) ?? 0,
              );
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _assignToProjectDialog(Vehiculo vehiculo) {
    // Cargar lista de obras disponibles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asignar Vehículo - ${vehiculo.matricula}'),
        content: const Text('Seleccionar obra de la lista...'),
        // Implementar lista de obras
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  Future<void> _programarMantenimiento(Vehiculo vehiculo, TipoMantenimiento tipo) async {
    try {
      // Implementar lógica de programación de mantenimiento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mantenimiento programado para ${vehiculo.matricula}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registrarCombustible(Vehiculo vehiculo, double litros, double costo) async {
    try {
      // Implementar lógica de registro de combustible
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Combustible registrado para ${vehiculo.matricula}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadVehiculos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deactivateVehicle(Vehiculo vehiculo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desactivación'),
        content: Text('¿Desactivar el vehículo ${vehiculo.matricula}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('vehiculos')
            .doc(vehiculo.id)
            .update({'estado': 'inactivo'});

        _loadVehiculos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vehículo ${vehiculo.matricula} desactivado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// Enums y clases auxiliares
enum TipoMantenimiento {
  preventivo,
  aceite,
  itv,
  reparacion
}

// Diálogo para crear/editar vehículos
class VehiculoDialog extends StatefulWidget {
  final String empresaId;
  final Vehiculo? vehiculo;
  final VoidCallback onSaved;

  const VehiculoDialog({
    super.key,
    required this.empresaId,
    this.vehiculo,
    required this.onSaved,
  });

  @override
  State<VehiculoDialog> createState() => _VehiculoDialogState();
}

class _VehiculoDialogState extends State<VehiculoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  
  TipoVehiculo _tipo = TipoVehiculo.coche;
  EstadoVehiculo _estado = EstadoVehiculo.activo;
  int _nivelCombustible = 100;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehiculo != null) {
      final vehiculo = widget.vehiculo!;
      _matriculaController.text = vehiculo.matricula;
      _marcaController.text = vehiculo.marca;
      _modeloController.text = vehiculo.modelo;
      _kilometrajeController.text = vehiculo.kilometraje.toString();
      _tipo = vehiculo.tipo;
      _estado = vehiculo.estado;
      _nivelCombustible = vehiculo.nivelCombustible;
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  Future<void> _saveVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehiculo = Vehiculo(
        id: widget.vehiculo?.id ?? '',
        matricula: _matriculaController.text.trim(),
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        tipo: _tipo,
        estado: _estado,
        kilometraje: int.parse(_kilometrajeController.text),
        nivelCombustible: _nivelCombustible,
        fechaCreacion: widget.vehiculo?.fechaCreacion ?? DateTime.now(),
        fechaModificacion: DateTime.now(),
      );

      if (widget.vehiculo != null) {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('vehiculos')
            .doc(widget.vehiculo!.id)
            .update(vehiculo.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(widget.empresaId)
            .collection('vehiculos')
            .add(vehiculo.toMap());
      }

      widget.onSaved();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vehiculo != null 
                ? 'Vehículo actualizado exitosamente'
                : 'Vehículo creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vehiculo != null ? 'Editar Vehículo' : 'Nuevo Vehículo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'La matrícula es requerida' 
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'La marca es requerida' 
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo *'),
                validator: (value) => value?.trim().isEmpty == true 
                    ? 'El modelo es requerido' 
                    : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TipoVehiculo>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TipoVehiculo.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipo = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EstadoVehiculo>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: EstadoVehiculo.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kilometrajeController,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty == true) return null;
                  if (int.tryParse(value!) == null) {
                    return 'Kilometraje inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Nivel de Combustible: $_nivelCombustible%'),
              Slider(
                value: _nivelCombustible.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _nivelCombustible = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVehiculo,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.vehiculo != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }