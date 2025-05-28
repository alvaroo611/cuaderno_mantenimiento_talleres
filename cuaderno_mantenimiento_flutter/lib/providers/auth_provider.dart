import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/person.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/', // ⚠️ AJUSTA esto
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  String? _token;
  String? _userName;
  bool _isLoading = false;

  String? get token => _token;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Interceptor que añade el token si existe
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));
  }
  Future<Person?> login(String correo, String password) async {
    print('🔄 Iniciando login con correo: $correo');
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Enviando solicitud POST a person/login...');
      final response = await _dio.post('person/login', data: {
        "correo": correo,
        "password": password,
      });

      print('✅ Respuesta recibida con código: ${response.statusCode}');
      if (response.statusCode == 201) {
        final data = response.data;
        print('📦 Datos recibidos: $data');

        // Asegúrate de que el campo 'person' existe en la respuesta
        if (data['user'] == null) {
          print('⚠️ El campo "user" no está presente en la respuesta');
          _isLoading = false;
          notifyListeners();
          return null;
        }

        final person = Person.fromJson(data['user']);
        print('👤 Usuario autenticado: ${person.nombre}');

        _token = data['access_token'];
        _userName = person.nombre;
        _isLoading = false;
        notifyListeners();

        print('✅ Login exitoso, token guardado.');
        return person;
      } else {
        print('❌ Error en login: código ${response.statusCode}');
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on DioException catch (e) {
      print('🛑 DioException capturada');
      print('📭 Detalles del error: ${e.response?.data}');
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      print('❗ Error inesperado: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }



  void logout() {
    _token = null;
    _userName = null;
    notifyListeners();
  }
}
