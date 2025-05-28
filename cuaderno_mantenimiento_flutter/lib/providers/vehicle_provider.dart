import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-vehicle-dto.dart';
import 'package:dio/dio.dart';


class VehicleProvider {
  final Dio dio = Dio();

  Future<bool> createVehicle(CreateVehicleDto vehicle) async {
    final String url = 'http://localhost:3000/vehicle';

    try {
      final response = await dio.post(
        url,
        data: vehicle.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error creando vehículo: ${response.statusCode}');
        print('Respuesta: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Excepción al crear vehículo: $e');
      return false;
    }
  }
}
