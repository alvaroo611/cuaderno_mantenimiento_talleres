class CreateInterventionDetailDto {
  final String elemento;
  final String estado;
  final String interventionId;
  final String? marca;

  CreateInterventionDetailDto({
    required this.elemento,
    required this.estado,
    required this.interventionId,
    this.marca,
  });

  Map<String, dynamic> toJson() {
    return {
      'elemento': elemento,
      'estado': estado,
      'intervention_id': interventionId,
      if (marca != null && marca!.isNotEmpty) 'marca': marca,
    };
  }
}
