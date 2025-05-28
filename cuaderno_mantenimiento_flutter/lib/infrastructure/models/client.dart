class Client {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String phone;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    final persona = json['persona'] ?? {};

    return Client(
      id: json['id_client'] ?? '',
      name: persona['nombre'] ?? '',
      email: persona['correo'] ?? '',
      password:'',
      address: json['domicilio'] ?? '',
      city: json['localidad'] ?? '',
      province: json['provincia'] ?? '',
      postalCode: json['codigo_postal'] ?? '',
      phone: json['telefono'] ?? '',
    );
  }
}
