// Modelo Person
class Person {
  final String id;
  final String nombre;
  final String correo;
  final String rol;

  Person({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      rol: json['rol'],
    );
  }
}
