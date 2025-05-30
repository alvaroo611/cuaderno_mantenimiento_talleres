// providers/car_provider.dart

import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-vehicle-dto.dart';
import 'package:xml/xml.dart' as xml;
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/car.dart';
import 'package:dio/dio.dart';

class CarProvider {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/'));
  final Map<String, String?> _imageCache = {};
  Future<List<Car>> fetchCarsByClientId(String clientId) async {
   

    try {
      final response = await _dio.get('vehicle/client/$clientId');
 

      final List data = response.data;
      final cars = data.map((json) {
       
        return Car.fromJson(json);
      }).toList();

      return cars;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No se encontraron coches para este cliente.');
      } else {
        throw Exception('Error al obtener vehículos: ${e.message}');
      }
    } catch (e) {
      
      throw Exception('Error al obtener vehículos: $e');
    }
  }

    String _normalize(String text) {
      // Quita tildes básicas y espacios
      final withOutAccents = text
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll(' ', '');
      return withOutAccents;
    }
    Future<String?> fetchCarImageUrl(String brand, String model) async {
      final key = '${brand.toLowerCase()} ${model.toLowerCase()}';
      // Si está en caché, devolverlo directamente
      if (_imageCache.containsKey(key)) {
        
        return _imageCache[key];
      }

      final searchTerm = '$brand $model'.replaceAll(' ', '+');
      final url = 'http://www.carimagery.com/api.asmx/GetImageUrl?searchTerm=$searchTerm';

      try {
        final response = await Dio().get<String>(url,
          options: Options(responseType: ResponseType.plain)); // XML plano
        final rawXml = response.data;
        if (rawXml != null) {
          final document = xml.XmlDocument.parse(rawXml);
          final stringElement = document.findAllElements('string').first;
          final imageUrl = stringElement.text;

          // Guardar en caché
          _imageCache[key] = imageUrl;

          return imageUrl;
        }
      } catch (e) {
        throw ArgumentError();
      }

      // En caso de error, guardar null para evitar repetir peticiones fallidas
      _imageCache[key] = null;
      return null;
    }

  Future<void> updateCar(String carId, CreateVehicleDto updatedCar) async {
    final url = 'vehicle/$carId';
    final data = updatedCar.toJson();



    try {
      final response = await _dio.patch(url, data: data);

    
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el coche');
      }
    } catch (e) {
  
    
    }
  }
   Future<void> updateMaintenance(String vehicleId, {
    required int kilometrajeEstimado,
    required String proximaRevisionFechaYYYYMMDD,
  }) async {
    try {
      final response = await _dio.patch(
        '/vehicle/$vehicleId/maintenance',
        data: {
          'kilometraje_estimado_revision': kilometrajeEstimado,
          'proxima_revision_fecha': proximaRevisionFechaYYYYMMDD,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el mantenimiento');
      }
    } catch (e) {
      throw Exception('Error al actualizar mantenimiento: $e');
    }
  }


  Future<void> deleteCar(String carId) async {
    try {
      await _dio.delete('vehicle/$carId');
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }
}
