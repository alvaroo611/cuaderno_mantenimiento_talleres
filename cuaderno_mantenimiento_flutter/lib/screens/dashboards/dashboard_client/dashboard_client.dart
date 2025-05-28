// lib/screens/client_dashboard.dart
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/person.dart';
import 'package:flutter/material.dart';

class ClientDashboard extends StatelessWidget {
  final Person person;
  const ClientDashboard({required this.person, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Cliente')),
      body: const Center(child: Text('Contenido del Cliente')),
    );
  }
}
