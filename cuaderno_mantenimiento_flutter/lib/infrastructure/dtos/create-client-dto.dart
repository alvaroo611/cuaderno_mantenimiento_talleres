class CreateClientDto {
  final String nombre;
  final String correo;
  final String password;
  final String domicilio;
  final String localidad;
  final String provincia;
  final String codigoPostal;
  final String telefono;

  CreateClientDto({
    required this.nombre,
    required this.correo,
    required this.password,
    required this.domicilio,
    required this.localidad,
    required this.provincia,
    required this.codigoPostal,
    required this.telefono,
  });

  // Puedes agregar un método para convertirlo a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'domicilio': domicilio,
      'localidad': localidad,
      'provincia': provincia,
      'codigo_postal': codigoPostal,
      'telefono': telefono,
    };
  }}