import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-details-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/intervention.dart';
import 'package:dio/dio.dart';

class InterventionProvider {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/', // Cambia localhost si usas emulador
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

 Future<List<Intervention>> fetchInterventions(String vehicleId) async {
  try {
    final response = await _dio.get('intervention/vehicle/$vehicleId');
    final data = response.data as List;
    return data.map((e) => Intervention.fromJson(e)).toList();
  } on DioException catch (e) {
    throw Exception('Error al cargar intervenciones: ${e.message}');
  }
}

  Future<void> updateInterventionDetail(CreateInterventionDetailDto detail,String idDetail) async {
  try {
    await _dio.patch(
      '/intervention-details/${idDetail}',
      data: detail.toJson(),
    );
  } catch (e) {
    throw Exception('Error al actualizar detalle: $e');
  }
}

  Future<bool> deleteIntervention(String id) async {
    try {
      final response = await _dio.delete('intervention/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> createIntervention(CreateInterventionDto dto) async {
    print('🚀 Enviando solicitud para crear intervención...');
    print('📦 DTO enviado: ${dto.toJson()}');

    try {
      final response = await _dio.post('intervention', data: dto.toJson());

      print('📬 Respuesta recibida: ${response.statusCode}');
      print('📄 Datos de respuesta: ${response.data}');

      final success = response.statusCode == 201 || response.statusCode == 200;

      if (success) {
        return {
          'success': true,
          'interventionId':  response.data['intervention']['id_intervencion']
        };
      } else {
        return {
          'success': false,
          'message': 'Error inesperado con código: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      print('❌ Error al crear intervención: ${e.response?.statusCode}');
      print('🧵 Detalles del error: ${e.response?.data}');
      return {
        'success': false,
        'message': 'Error al crear intervención',
        'statusCode': e.response?.statusCode,
        'error': e.response?.data,
      };
    }
  }

    Future<Map<String, dynamic>> createInterventionDetail(CreateInterventionDetailDto dto) async {
  print('🚀 Enviando solicitud para crear detalles de intervención...');
  print('📦 DTO enviado: ${dto.toJson()}');

  try {
    final response = await _dio.post('/intervention-details', data: dto.toJson());

    print('📬 Respuesta recibida: ${response.statusCode}');
    print('📄 Datos de respuesta: ${response.data}');

    final success = response.statusCode == 201 || response.statusCode == 200;

    if (success) {
      // Ajusta aquí el acceso según la respuesta real del backend
      return {
        'success': true,
        'detailsId':  response.data['id_intervention_details'], 
      };
    } else {
      return {
        'success': false,
        'message': 'Error inesperado con código: ${response.statusCode}',
      };
    }
  } on DioException catch (e) {
    print('❌ Error al crear detalles de intervención: ${e.response?.statusCode}');
    print('🧵 Detalles del error: ${e.response?.data}');
    return {
      'success': false,
      'message': 'Error al crear detalles de intervención',
      'statusCode': e.response?.statusCode,
      'error': e.response?.data,
    };
  }
}
  Future<Map<String, dynamic>> fetchFullInterventionInfo(String interventionId) async {
    final response = await _dio.get('/intervention/$interventionId/full-info');
    return response.data;
  }


  Future<bool> updateIntervention(CreateInterventionDto dto, String id) async {
    try {
      final response = await _dio.patch('intervention/$id', data: dto.toJson());
      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    }
  }
}
