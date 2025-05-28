class Intervention {
  final String idIntervencion;
  final String fecha;
  final int kilometraje;
  final String tipoIntervencion;
  final String observaciones;

  Intervention({
    required this.idIntervencion,
    required this.fecha,
    required this.kilometraje,
    required this.tipoIntervencion,
    required this.observaciones,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      idIntervencion: json['id_intervencion'],
      fecha: json['fecha'],
      kilometraje: json['kilometraje'],
      tipoIntervencion: json['tipo_intervencion'],
      observaciones: json['observaciones'],
    );
  }
}
