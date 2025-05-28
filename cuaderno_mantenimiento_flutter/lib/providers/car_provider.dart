// providers/car_provider.dart

import 'package:xml/xml.dart' as xml;
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/car.dart';
import 'package:dio/dio.dart';

class CarProvider {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/'));

  Future<List<Car>> fetchCarsByClientId(String clientId) async {
    print('[fetchCarsByClientId] 🔍 Iniciando búsqueda de coches para el cliente con ID: $clientId');

    try {
      final response = await _dio.get('vehicle/client/$clientId');
      print('[fetchCarsByClientId] ✅ Respuesta recibida con status code: ${response.statusCode}');
      print('[fetchCarsByClientId] 📦 Datos recibidos: ${response.data}');

      final List data = response.data;
      final cars = data.map((json) {
        print('[fetchCarsByClientId] 🛠️ Mapeando coche: $json');
        return Car.fromJson(json);
      }).toList();

      print('[fetchCarsByClientId] 🚗 Lista de coches creada con éxito. Total: ${cars.length}');
      return cars;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No se encontraron coches para este cliente.');
      } else {
        throw Exception('Error al obtener vehículos: ${e.message}');
      }
    } catch (e) {
      print('[fetchCarsByClientId] ❌ Error al obtener vehículos: $e');
      throw Exception('Error al obtener vehículos: $e');
    }
  }


  Future<String?> fetchCarImageUrl(String brand, String model) async {
    final searchTerm = '$brand $model'.replaceAll(' ', '+');
    final url = 'http://www.carimagery.com/api.asmx/GetImageUrl?searchTerm=$searchTerm';

    try {
      final response = await Dio().get<String>(url,
        options: Options(responseType: ResponseType.plain)); // devuelve XML como texto plano
      final rawXml = response.data;
      if (rawXml != null) {
        final document = xml.XmlDocument.parse(rawXml);
        final stringElement = document.findAllElements('string').first;
        final imageUrl = stringElement.text;
        return imageUrl;
      }

    } catch (e) {
      print('❌ Error al obtener imagen de $brand $model: $e');
    }
    return null;
  }

  Future<void> deleteCar(String carId) async {
    try {
      await _dio.delete('vehicle/$carId');
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }
}
