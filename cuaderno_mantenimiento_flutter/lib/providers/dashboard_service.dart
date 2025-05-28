import 'package:dio/dio.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/dashboard_stats.dart'; // Ajusta el path

class DashboardService {
  
  final Dio _dio;

  DashboardService() : _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  Future<DashboardStats> fetchStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } on DioError catch (e) {
      throw Exception('Error en la petición: ${e.message}');
    }
  }
}
