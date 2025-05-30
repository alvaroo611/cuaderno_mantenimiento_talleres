import 'package:cuaderno_mantenimiento_flutter/providers/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/person.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/dashboard_stats.dart';
import 'package:go_router/go_router.dart'; // Ajusta el path


class AdminDashboard extends StatefulWidget {
  final Person person;
  const AdminDashboard({super.key, required this.person});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final DashboardService _dashboardService;
  late Future<DashboardStats> _futureStats;

  final primaryColor = const Color(0xFF904A42);
  final secondaryColor = const Color.fromARGB(255, 182, 75, 63);

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _futureStats = _dashboardService.fetchStats();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: primaryColor,
  centerTitle: true,
  title: Padding(
    padding: const EdgeInsets.symmetric(vertical: 52),
    child: const Text(
      'DASHBOARD ADMINISTRADORES',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.account_circle, color: Colors.white),
        onSelected: (value) {
          if (value == 'logout') {
           
            context.go('/login'); // Redirige al login
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'logout',
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    ),
  ],
),


      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Resumen de Actividad'),
          const SizedBox(height: 16),
          FutureBuilder<DashboardStats>(
            future: _futureStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final stats = snapshot.data!;
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildCard('Clientes registrados', stats.totalClients.toString(), Icons.person, secondaryColor),
                    _buildCard('Vehículos registrados', stats.totalVehicles.toString(), Icons.directions_car, primaryColor),
                    _buildCard('Intervenciones esta semana', stats.interventionsThisWeek.toString(), Icons.build, secondaryColor),
                    _buildCard('Próximas revisiones', stats.upcomingRevisions.toString(), Icons.event, primaryColor),
                    _buildCard('Últimas intervenciones', '${stats.latestInterventions.length} recientes', Icons.history, secondaryColor),
                  ],
                );
              } else {
                return const Text('No hay datos disponibles');
              }
            },
          ),
          const SizedBox(height: 30),
          _buildSectionHeader('Herramientas'),
          const SizedBox(height: 16),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.people, color: primaryColor),
                title: const Text('Gestión de Clientes', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.push('/admin/clients', extra: widget.person);
                },
              ),
            ),

              _buildMenuTile(context, 'Gestión de Vehículos', Icons.car_repair, '/admin/vehicles', secondaryColor),
              _buildMenuTile(context, 'Gestión de Intervenciones', Icons.build_circle, '/admin/interventions', primaryColor),
              _buildMenuTile(context, 'Gestión de Usuarios', Icons.verified_user, '/admin/users', secondaryColor),
              _buildMenuTile(context, 'Revisiones próximas', Icons.notification_important, '/admin/reminders', primaryColor),
            ],
          )
        ],
      ),
    ),

    );
  }
  Widget _buildSectionHeader(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF904A42), // rojo principal
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );
}

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, String route, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
