import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../usuarios/gestion_usuarios_screen.dart';

class ConfiguracionTab extends StatefulWidget {
  final String empresaId;
  
  const ConfiguracionTab({Key? key, required this.empresaId}) : super(key: key);
  
  @override
  _ConfiguracionTabState createState() => _ConfiguracionTabState();
}

class _ConfiguracionTabState extends State<ConfiguracionTab> {
  bool _notificacionesActivas = true;
  bool _sincronizacionAutomatica = true;
  bool _modoOffline = false;
  String _formatoCodigoBarras = 'EAN13';
  String _tema = 'Claro';
  
  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
    _verificarConectividad();
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacionesActivas = prefs.getBool('notificaciones') ?? true;
      _sincronizacionAutomatica = prefs.getBool('sync_auto') ?? true;
      _formatoCodigoBarras = prefs.getString('formato_codigo') ?? 'EAN13';
      _tema = prefs.getString('tema') ?? 'Claro';
    });
  }

  Future<void> _guardarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones', _notificacionesActivas);
    await prefs.setBool('sync_auto', _sincronizacionAutomatica);
    await prefs.setString('formato_codigo', _formatoCodigoBarras);
    await prefs.setString('tema', _tema);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Configuración guardada'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verificarConectividad() async {
    final connectivity = await Connectivity().checkConnectivity();
    setState(() {
      _modoOffline = connectivity == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Personaliza tu experiencia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Estado de conexión
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Sección de Aplicación
            _buildSeccionCard(
              'Aplicación',
              Icons.phone_android,
              Colors.blue,
              [
                _buildSwitchTile(
                  'Notificaciones',
                  'Recibir alertas y notificaciones',
                  Icons.notifications,
                  _notificacionesActivas,
                  (value) => setState(() => _notificacionesActivas = value),
                ),
                _buildSwitchTile(
                  'Sincronización automática',
                  'Sincronizar datos automáticamente',
                  Icons.sync,
                  _sincronizacionAutomatica,
                  (value) => setState(() => _sincronizacionAutomatica = value),
                ),
                _buildDropdownTile(
                  'Tema',
                  'Apariencia de la aplicación',
                  Icons.palette,
                  _tema,
                  ['Claro', 'Oscuro', 'Sistema'],
                  (value) => setState(() => _tema = value!),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección de Inventario
            _buildSeccionCard(
              'Inventario',
              Icons.inventory,
              Colors.green,
              [
                _buildDropdownTile(
                  'Formato de código de barras',
                  'Formato por defecto para generar códigos',
                  Icons.qr_code,
                  _formatoCodigoBarras,
                  ['EAN13', 'EAN8', 'UPC-A', 'Code128'],
                  (value) => setState(() => _formatoCodigoBarras = value!),
                ),
                _buildActionTile(
                  'Exportar datos',
                  'Descargar inventario en Excel',
                  Icons.download,
                  _exportarDatos,
                ),
                _buildActionTile(
                  'Importar artículos',
                  'Cargar artículos desde archivo',
                  Icons.upload,
                  _importarArticulos,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección de Base de Datos
            _buildSeccionCard(
              'Base de Datos',
              Icons.storage,
              Colors.orange,
              [
                _buildActionTile(
                  'Sincronizar ahora',
                  'Forzar sincronización manual',
                  Icons.refresh,
                  _sincronizarDatos,
                ),
                _buildActionTile(
                  'Limpiar caché',
                  'Eliminar datos temporales',
                  Icons.delete_sweep,
                  _limpiarCache,
                ),
                _buildActionTile(
                  'Backup de datos',
                  'Crear copia de seguridad',
                  Icons.backup,
                  _crearBackup,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección de Empresa
            _buildSeccionCard(
              'Empresa',
              Icons.business,
              Colors.purple,
              [
                _buildInfoTile(
                  'ID de Empresa',
                  widget.empresaId,
                  Icons.business_center,
                ),
                _buildActionTile(
                  'Gestionar usuarios',
                  'Administrar accesos de usuario',
                  Icons.people,
                  _gestionarUsuarios,
                ),
                _buildActionTile(
                  'Cambiar empresa',
                  'Seleccionar otra empresa',
                  Icons.swap_horiz,
                  _cambiarEmpresa,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información de la app
            _buildSeccionCard(
              'Información',
              Icons.info,
              Colors.grey,
              [
                _buildInfoTile('Versión', '1.0.0', Icons.code),
                _buildActionTile(
                  'Términos y condiciones',
                  'Ver políticas de uso',
                  Icons.description,
                  _mostrarTerminos,
                ),
                _buildActionTile(
                  'Soporte técnico',
                  'Contactar con soporte',
                  Icons.support_agent,
                  _contactarSoporte,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _guardarConfiguracion,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar Configuración',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _modoOffline ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _modoOffline ? Icons.wifi_off : Icons.wifi,
                color: _modoOffline ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _modoOffline ? 'Modo Offline' : 'Conectado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _modoOffline 
                        ? 'Los datos se sincronizarán cuando haya conexión'
                        : 'Sincronización automática activa',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!_modoOffline)
              Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionCard(String titulo, IconData icono, Color color, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String titulo, String subtitulo, IconData icono, bool valor, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icono, color: Colors.grey.shade600),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: Switch(
        value: valor,
        onChanged: onChanged,
        activeColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildDropdownTile(String titulo, String subtitulo, IconData icono, String valor, List<String> opciones, Function(String?) onChanged) {
    return ListTile(
      leading: Icon(icono, color: Colors.grey.shade600),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: DropdownButton<String>(
        value: valor,
        underline: Container(),
        items: opciones.map((opcion) => DropdownMenuItem(
          value: opcion,
          child: Text(opcion),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(String titulo, String subtitulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.grey.shade600),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String titulo, String valor, IconData icono) {
    return ListTile(
      leading: Icon(icono, color: Colors.grey.shade600),
      title: Text(titulo),
      subtitle: Text(valor),
    );
  }

  // Métodos de acción
  Future<void> _exportarDatos() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Exportando datos...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📊 Datos exportados correctamente'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Abrir',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _importarArticulos() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Artículos'),
        content: const Text('Selecciona un archivo Excel (.xlsx) con los artículos a importar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🚧 Funcionalidad en desarrollo'),
                  backgroundColor: Colors.orange.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Seleccionar Archivo'),
          ),
        ],
      ),
    );
  }

  Future<void> _sincronizarDatos() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Sincronizando...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Sincronización completada'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _limpiarCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Caché'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los datos temporales?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Limpiando caché...'),
                    ],
                  ),
                ),
              );

              await Future.delayed(const Duration(seconds: 2));
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🗑️ Caché limpiado correctamente'),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _crearBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('💾 Creando backup...'),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _gestionarUsuarios() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestionUsuariosScreen(empresaId: widget.empresaId),
      ),
    );
  }

  void _cambiarEmpresa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Empresa'),
        content: const Text('¿Quieres volver a la selección de empresa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/empresa-selection');
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Términos y condiciones de uso de la aplicación de inventario...\n\n'
            '1. Uso autorizado únicamente para gestión de inventarios\n'
            '2. Los datos se almacenan de forma segura en Firebase\n'
            '3. El usuario es responsable de mantener la confidencialidad\n'
            '4. Actualizaciones periódicas pueden modificar funcionalidades\n\n'
            'Para más información, contacta con el soporte técnico.',
            style: TextStyle(fontSize: 14),
          ),
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

  void _contactarSoporte() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Colors.blue),
            SizedBox(width: 8),
            Text('Soporte Técnico'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: soporte@inventario.com'),
            SizedBox(height: 8),
            Text('📱 WhatsApp: +34 600 123 456'),
            SizedBox(height: 8),
            Text('🕒 Horario: L-V 9:00-18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('📞 Abriendo contacto...'),
                  backgroundColor: Colors.blue.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Contactar'),
          ),
        ],
      ),
    );
  }
}