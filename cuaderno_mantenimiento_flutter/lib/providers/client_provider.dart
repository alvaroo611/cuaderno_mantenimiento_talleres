import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-client-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/client.dart';
import 'package:dio/dio.dart';

class ClientProvider {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  
  Future<List<Client>> fetchClients() async {
   

    try {

      final response = await _dio.get('/clients');


      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final clients = data.map((item) {
         
          final client = Client.fromJson(item);
      
          return client;
        }).toList();

        
        return clients;
      } else {
        
        throw Exception('Error al cargar clientes: ${response.statusCode}');
      }
    } catch (e) {
    
      throw Exception('Error en la petición: $e');
    }
  }
  Future<void> deleteClient(String clientId) async {
 

  try {
    final response = await _dio.delete('/clients/$clientId');
    

    if (response.statusCode == 200 || response.statusCode == 204) {
      
    } else {
      
      throw Exception('Error al eliminar cliente: ${response.statusCode}');
    }
  } catch (e) {
   
    throw Exception('Error eliminando cliente: $e');
  }
}
Future<void> updateClient(CreateClientDto client, String id) async {
  try {
    await _dio.patch('/clients/$id', data: client.toJson());
  } on DioException catch (e) {
    // Si es un error que viene con respuesta del backend
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;

      // NestJS devuelve errores con formato { statusCode, message, error }
      if (errorData is Map && errorData.containsKey('message')) {
        // message puede ser String o List
        final message = errorData['message'];
        if (message is List) {
          throw Exception(message.join('\n'));
        } else {
          throw Exception(message.toString());
        }
      }
    }

    // Si no se puede extraer mensaje del backend
    throw Exception('Error desconocido al actualizar cliente.');
  } catch (e) {
    throw Exception('Error al actualizar cliente: $e');
  }
}
 Future<bool> createClient(CreateClientDto client) async {
    try {
      final response = await _dio.post(
        '/clients',
        data: client.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Cliente creado correctamente
        return true;
      } else {
        print('Error al crear cliente: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      // Manejo de errores con respuesta del backend
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          final message = errorData['message'];
          if (message is List) {
            throw Exception(message.join('\n'));
          } else {
            throw Exception(message.toString());
          }
        }
      }
      // Error desconocido
      throw Exception('Error desconocido al crear cliente.');
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

}
