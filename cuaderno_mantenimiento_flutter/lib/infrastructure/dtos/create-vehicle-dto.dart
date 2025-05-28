class CreateVehicleDto {
  final String marca;
  final String modelo;
  final String bastidor;
  final String tipoMotor;
  final String matricula;
  final String? proximaRevisionFecha; // ISO 8601 string, opcional
  final int? kilometrajeEstimadoRevision; // opcional
  final String clientId;

  CreateVehicleDto({
    required this.marca,
    required this.modelo,
    required this.bastidor,
    required this.tipoMotor,
    required this.matricula,
    this.proximaRevisionFecha,
    this.kilometrajeEstimadoRevision,
    required this.clientId,
  });

  // Convierte la instancia a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'marca': marca,
      'modelo': modelo,
      'bastidor': bastidor,
      'tipo_motor': tipoMotor,
      'matricula': matricula,
      if (proximaRevisionFecha != null) 'proxima_revision_fecha': proximaRevisionFecha,
      if (kilometrajeEstimadoRevision != null) 'kilometraje_estimado_revision': kilometrajeEstimadoRevision,
      'client_id': clientId,
    };
  }
}
