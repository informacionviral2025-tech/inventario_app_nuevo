import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/alerts_panel.dart';

class DashboardScreen extends StatefulWidget {
  final String empresaId;

  const DashboardScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false)
          .loadDashboardData(widget.empresaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DashboardProvider>(context, listen: false)
                  .loadDashboardData(widget.empresaId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboardData(widget.empresaId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPIs Principales
                  _buildKPISection(provider),
                  const SizedBox(height: 20),
                  
                  // Gráficos y Estadísticas
                  _buildChartsSection(provider),
                  const SizedBox(height: 20),
                  
                  // Alertas y Notificaciones
                  _buildAlertsSection(provider),
                  const SizedBox(height: 20),
                  
                  // Acciones Rápidas
                  _buildQuickActionsSection(),
                  const SizedBox(height: 20),
                  
                  // Estado de Recursos
                  _buildResourcesSection(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKPISection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicadores Clave',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            KPICard(
              title: 'Obras Activas',
              value: provider.obrasActivas.toString(),
              icon: Icons.construction,
              color: Colors.blue,
              trend: provider.obrasTrend,
            ),
            KPICard(
              title: 'Vehículos Activos',
              value: '${provider.vehiculosActivos}/${provider.totalVehiculos}',
              icon: Icons.local_shipping,
              color: Colors.green,
              trend: provider.vehiculosTrend,
            ),
            KPICard(
              title: 'Tareas Pendientes',
              value: provider.tareasPendientes.toString(),
              icon: Icons.assignment,
              color: Colors.orange,
              trend: provider.tareasTrend,
            ),
            KPICard(
              title: 'Stock Crítico',
              value: provider.stockCritico.toString(),
              icon: Icons.warning,
              color: Colors.red,
              trend: provider.stockTrend,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis y Tendencias',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Productividad por Obra',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final obras = ['Obra A', 'Obra B', 'Obra C', 'Obra D'];
                                    return Text(
                                      value.toInt() < obras.length 
                                          ? obras[value.toInt()] 
                                          : '',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text('${value.toInt()}%');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: provider.productividadData.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value,
                                    color: Colors.blue,
                                    width: 20,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribución de Recursos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: 35,
                                title: 'Personal\n35%',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.green,
                                value: 25,
                                title: 'Vehículos\n25%',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: 40,
                                title: 'Material\n40%',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertsSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas y Notificaciones',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AlertsPanel(alertas: provider.alertas),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        QuickActions(empresaId: widget.empresaId),
      ],
    );
  }

  Widget _buildResourcesSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de Recursos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildResourceItem(
                  'Personal Disponible',
                  provider.personalDisponible,
                  provider.totalPersonal,
                  Colors.blue,
                ),
                const Divider(),
                _buildResourceItem(
                  'Vehículos Operativos',
                  provider.vehiculosOperativos,
                  provider.totalVehiculos,
                  Colors.green,
                ),
                const Divider(),
                _buildResourceItem(
                  'Equipos Disponibles',
                  provider.equiposDisponibles,
                  provider.totalEquipos,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(String title, int disponible, int total, Color color) {
    final percentage = total > 0 ? (disponible / total) : 0.0;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$disponible/$total',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Stock crítico en Obra A'),
              subtitle: Text('Cemento: 2 sacos restantes'),
              trailing: Text('Hace 5 min'),
            ),
            const ListTile(
              leading: Icon(Icons.build, color: Colors.orange),
              title: Text('Mantenimiento vencido'),
              subtitle: Text('Vehículo MAT-1234 requiere revisión'),
              trailing: Text('Hace 1 hora'),
            ),
            const ListTile(
              leading: Icon(Icons.schedule, color: Colors.blue),
              title: Text('Tarea próxima a vencer'),
              subtitle: Text('Instalación eléctrica - Obra B'),
              trailing: Text('Mañana'),
            ),
          ],
        ),
      ),
    );
  }
}