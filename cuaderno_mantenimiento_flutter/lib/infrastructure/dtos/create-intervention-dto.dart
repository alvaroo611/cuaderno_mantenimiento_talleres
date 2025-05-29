class CreateInterventionDto {
  final String fecha;
  final int kilometraje;
  final String tipoIntervencion;
  final String? observaciones;
  final String vehicle_id;

  CreateInterventionDto({
    required this.fecha,
    required this.kilometraje,
    required this.tipoIntervencion,
    this.observaciones,
    required this.vehicle_id,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'kilometraje': kilometraje,
      'tipo_intervencion': tipoIntervencion,
      'observaciones': observaciones,
      'vehicle_id': vehicle_id,
    };
  }
}
