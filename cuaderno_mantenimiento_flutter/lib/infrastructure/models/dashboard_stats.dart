import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/intervention.dart';

class DashboardStats {
  final int totalClients;
  final int totalVehicles;
  final int interventionsThisWeek;
  final int upcomingRevisions;
  final List<Intervention> latestInterventions;

  DashboardStats({
    required this.totalClients,
    required this.totalVehicles,
    required this.interventionsThisWeek,
    required this.upcomingRevisions,
    required this.latestInterventions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var latest = json['latestInterventions'] as List<dynamic>;
    List<Intervention> interventions = latest.map((e) => Intervention.fromJson(e)).toList();

    return DashboardStats(
      totalClients: json['totalClients'],
      totalVehicles: json['totalVehicles'],
      interventionsThisWeek: json['interventionsThisWeek'],
      upcomingRevisions: json['upcomingRevisions'],
      latestInterventions: interventions,
    );
  }
}
