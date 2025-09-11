// lib/widgets/task_form_restructured.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormRestructured extends StatefulWidget {
  final Task? task;
  final String empresaId;

  const TaskFormRestructured({
    super.key,
    this.task,
    required this.empresaId,
  });

  @override
  State<TaskFormRestructured> createState() => _TaskFormRestructuredState();
}

class _TaskFormRestructuredState extends State<TaskFormRestructured> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 1));
  TaskPriority _prioridad = TaskPriority.media;
  TaskZone _zona = TaskZone.nave;
  TaskRepeatType _tipoRepeticion = TaskRepeatType.noRepetir;
  TaskStatus _estado = TaskStatus.pendiente;
  
  List<String> _responsablesSeleccionados = [];
  String? _vehiculoMaquinaSeleccionado;
  List<String> _titulosSugeridos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeWithTask(widget.task!);
    }
    _cargarTitulosSugeridos();
  }

  void _initializeWithTask(Task task) {
    _tituloController.text = task.titulo;
    _descripcionController.text = task.descripcion;
    _fechaVencimiento = task.fechaVencimiento;
    _prioridad = task.prioridad;
    _zona = task.zona;
    _tipoRepeticion = task.tipoRepeticion;
    _estado = task.estado;
    _responsablesSeleccionados = List.from(task.responsables);
    _vehiculoMaquinaSeleccionado = task.vehiculoMaquinaId;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarTitulosSugeridos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('tareas')
          .get();
      
      final titulos = snapshot.docs
          .map((doc) => doc.data()['titulo'] as String?)
          .where((titulo) => titulo != null && titulo.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      setState(() {
        _titulosSugeridos = titulos;
      });
    } catch (e) {
      print('Error cargando títulos sugeridos: $e');
    }
  }

  Future<void> _seleccionarResponsables() async {
    // Cargar usuarios registrados
    final usuarios = await _cargarUsuarios();
    
    final seleccionados = await showDialog<List<String>>(
      context: context,
      builder: (context) => _ResponsablesSelectorDialog(
        usuarios: usuarios,
        seleccionados: _responsablesSeleccionados,
      ),
    );
    
    if (seleccionados != null) {
      setState(() {
        _responsablesSeleccionados = seleccionados;
      });
    }
  }

  Future<List<Map<String, String>>> _cargarUsuarios() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('usuarios')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, String>{
          'id': doc.id,
          'nombre': data['nombre'] ?? 'Usuario sin nombre',
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error cargando usuarios: $e');
      return [];
    }
  }

  Future<void> _seleccionarVehiculoMaquina() async {
    final vehiculos = await _cargarVehiculosMaquinas();
    
    final seleccionado = await showDialog<String>(
      context: context,
      builder: (context) => _VehiculoMaquinaSelectorDialog(
        vehiculos: vehiculos,
        seleccionado: _vehiculoMaquinaSeleccionado,
      ),
    );
    
    if (seleccionado != null) {
      setState(() {
        _vehiculoMaquinaSeleccionado = seleccionado;
      });
    }
  }

  Future<List<Map<String, String>>> _cargarVehiculosMaquinas() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('empresas')
          .doc(widget.empresaId)
          .collection('vehiculos')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, String>{
          'id': doc.id,
          'nombre': data['nombre'] ?? 'Vehículo sin nombre',
          'tipo': data['tipo'] ?? 'Vehículo',
        };
      }).toList();
    } catch (e) {
      print('Error cargando vehículos: $e');
      return [];
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaVencimiento),
      );
      
      if (time != null) {
        setState(() {
          _fechaVencimiento = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_responsablesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos un responsable')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      
      final task = Task(
        id: widget.task?.id ?? '',
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaVencimiento: _fechaVencimiento,
        prioridad: _prioridad,
        responsables: _responsablesSeleccionados,
        zona: _zona,
        vehiculoMaquinaId: _zona == TaskZone.taller ? _vehiculoMaquinaSeleccionado : null,
        estado: _estado,
        fechaCreacion: widget.task?.fechaCreacion ?? DateTime.now(),
        fechaCompletada: widget.task?.fechaCompletada,
        tipoRepeticion: _tipoRepeticion,
        proximaRepeticion: _calcularProximaRepeticion(),
      );

      bool success;
      if (widget.task != null) {
        success = await provider.updateTask(task, widget.empresaId);
      } else {
        success = await provider.addTask(task, widget.empresaId);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task != null 
                ? 'Tarea actualizada exitosamente'
                : 'Tarea creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  DateTime? _calcularProximaRepeticion() {
    if (_tipoRepeticion == TaskRepeatType.noRepetir) return null;
    
    final now = DateTime.now();
    switch (_tipoRepeticion) {
      case TaskRepeatType.diario:
        return now.add(const Duration(days: 1));
      case TaskRepeatType.semanal:
        return now.add(const Duration(days: 7));
      case TaskRepeatType.quincenal:
        return now.add(const Duration(days: 15));
      case TaskRepeatType.mensual:
        return DateTime(now.year, now.month + 1, now.day);
      case TaskRepeatType.trimestral:
        return DateTime(now.year, now.month + 3, now.day);
      case TaskRepeatType.semestral:
        return DateTime(now.year, now.month + 6, now.day);
      case TaskRepeatType.anual:
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Editar Tarea' : 'Nueva Tarea'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _handleSubmit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Responsables
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Responsables *'),
                subtitle: Text(_responsablesSeleccionados.isEmpty 
                    ? 'Seleccionar responsables' 
                    : '${_responsablesSeleccionados.length} seleccionados'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _seleccionarResponsables,
              ),
            ),
            const SizedBox(height: 16),
            
            // Zona
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Zona *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskZone>(
                      value: _zona,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: TaskZone.values.map((zone) {
                        return DropdownMenuItem(
                          value: zone,
                          child: Text(_getZoneText(zone)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _zona = value;
                            if (value != TaskZone.taller) {
                              _vehiculoMaquinaSeleccionado = null;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Vehículo/Máquina (solo si zona es taller)
            if (_zona == TaskZone.taller) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Vehículo/Máquina'),
                  subtitle: Text(_vehiculoMaquinaSeleccionado ?? 'Seleccionar vehículo/máquina'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _seleccionarVehiculoMaquina,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Título con autocompletado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Título *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _titulosSugeridos.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        _tituloController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _tituloController.addListener(() {
                          controller.text = _tituloController.text;
                        });
                        return TextFormField(
                          controller: _tituloController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Escriba el título de la tarea',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El título es requerido';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Descripción
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describa la tarea a realizar',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Prioridad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prioridad *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskPriority>(
                      value: _prioridad,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(_getPriorityText(priority)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _prioridad = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Fecha límite
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha límite *'),
                subtitle: Text(
                  '${_fechaVencimiento.day}/${_fechaVencimiento.month}/${_fechaVencimiento.year} '
                  '${_fechaVencimiento.hour.toString().padLeft(2, '0')}:'
                  '${_fechaVencimiento.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectDate,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Repetición
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Repetición', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskRepeatType>(
                      value: _tipoRepeticion,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: TaskRepeatType.values.map((repeat) {
                        return DropdownMenuItem(
                          value: repeat,
                          child: Text(_getRepeatText(repeat)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _tipoRepeticion = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Estado (solo para edición)
            if (widget.task != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TaskStatus>(
                        value: _estado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: TaskStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Botón de guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.task != null ? 'Actualizar Tarea' : 'Crear Tarea'),
            ),
          ],
        ),
      ),
    );
  }

  String _getZoneText(TaskZone zone) {
    switch (zone) {
      case TaskZone.nave:
        return 'Nave';
      case TaskZone.almacen1:
        return 'Almacén 1';
      case TaskZone.almacen2:
        return 'Almacén 2';
      case TaskZone.almacen3:
        return 'Almacén 3';
      case TaskZone.almacen4:
        return 'Almacén 4';
      case TaskZone.almacen5:
        return 'Almacén 5';
      case TaskZone.lavado:
        return 'Lavado';
      case TaskZone.aridos:
        return 'Áridos';
      case TaskZone.exteriorNave:
        return 'Exterior Nave';
      case TaskZone.taller:
        return 'Taller';
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.baja:
        return 'Baja';
      case TaskPriority.media:
        return 'Media';
      case TaskPriority.alta:
        return 'Alta';
      case TaskPriority.critica:
        return 'Crítica';
    }
  }

  String _getRepeatText(TaskRepeatType repeat) {
    switch (repeat) {
      case TaskRepeatType.noRepetir:
        return 'No repetir';
      case TaskRepeatType.diario:
        return 'Diario';
      case TaskRepeatType.semanal:
        return 'Semanal';
      case TaskRepeatType.quincenal:
        return 'Quincenal';
      case TaskRepeatType.mensual:
        return 'Mensual';
      case TaskRepeatType.trimestral:
        return 'Trimestral';
      case TaskRepeatType.semestral:
        return 'Semestral';
      case TaskRepeatType.anual:
        return 'Anual';
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProgreso:
        return 'En Progreso';
      case TaskStatus.completada:
        return 'Completada';
      case TaskStatus.cancelada:
        return 'Cancelada';
    }
  }
}

// Diálogo para seleccionar responsables
class _ResponsablesSelectorDialog extends StatefulWidget {
  final List<Map<String, String>> usuarios;
  final List<String> seleccionados;

  const _ResponsablesSelectorDialog({
    required this.usuarios,
    required this.seleccionados,
  });

  @override
  State<_ResponsablesSelectorDialog> createState() => _ResponsablesSelectorDialogState();
}

class _ResponsablesSelectorDialogState extends State<_ResponsablesSelectorDialog> {
  late List<String> _seleccionados;

  @override
  void initState() {
    super.initState();
    _seleccionados = List.from(widget.seleccionados);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Responsables'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.usuarios.length,
          itemBuilder: (context, index) {
            final usuario = widget.usuarios[index];
            final isSelected = _seleccionados.contains(usuario['id']);
            
            return CheckboxListTile(
              title: Text(usuario['nombre']!),
              subtitle: Text(usuario['email']!),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _seleccionados.add(usuario['id']!);
                  } else {
                    _seleccionados.remove(usuario['id']!);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _seleccionados),
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

// Diálogo para seleccionar vehículo/máquina
class _VehiculoMaquinaSelectorDialog extends StatelessWidget {
  final List<Map<String, String>> vehiculos;
  final String? seleccionado;

  const _VehiculoMaquinaSelectorDialog({
    required this.vehiculos,
    required this.seleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Vehículo/Máquina'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: vehiculos.length,
          itemBuilder: (context, index) {
            final vehiculo = vehiculos[index];
            final isSelected = seleccionado == vehiculo['id'];
            
            return RadioListTile<String>(
              title: Text(vehiculo['nombre']!),
              subtitle: Text(vehiculo['tipo']!),
              value: vehiculo['id']!,
              groupValue: seleccionado,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (seleccionado != null)
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Sin selección'),
          ),
      ],
    );
  }
}
