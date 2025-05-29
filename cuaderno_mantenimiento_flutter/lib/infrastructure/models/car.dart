class Car {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  String? imageUrl;

  // Nuevos campos opcionales
  final String? bastidor;
  final String? tipoMotor;
  final String? proximaRevisionFecha;
  final int? kilometrajeEstimadoRevision;

  Car({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    this.imageUrl,
    this.bastidor,
    this.tipoMotor,
    this.proximaRevisionFecha,
    this.kilometrajeEstimadoRevision,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id_vehicle'],
      plate: json['matricula'],
      brand: json['marca'] ?? '',
      model: json['modelo'] ?? '',
      year: Car.estimateYearFromSpanishPlate(json['matricula']),
      bastidor: json['bastidor'],
      tipoMotor: json['tipo_motor'],
      proximaRevisionFecha: json['proxima_revision_fecha'],
      kilometrajeEstimadoRevision: json['kilometraje_estimado_revision'],
    );
  }


  // ✅ Método estático
  static int estimateYearFromSpanishPlate(String plate) {
    if (plate.length < 7) return 2000;
    final suffix = plate.substring(4).toUpperCase();

    final plateYearMap = {
      'BBB': 2000, 'BGC': 2001, 'BKW': 2002, 'BNB': 2003, 'BTM': 2004,
      'BYZ': 2005, 'CFX': 2006, 'CJP': 2007, 'CLZ': 2008, 'CRR': 2009,
      'CYH': 2010, 'DFP': 2011, 'DJN': 2012, 'DLV': 2013, 'DRH': 2014,
      'DXR': 2015, 'FJK': 2016, 'FLW': 2017, 'FST': 2018, 'FXH': 2019,
      'GKD': 2020, 'GMR': 2021, 'GSK': 2022, 'GXN': 2023, 'HCB': 2024,
      'HGL': 2025,
    };

    for (final entry in plateYearMap.entries.toList().reversed) {
      if (suffix.compareTo(entry.key) >= 0) {
        return entry.value;
      }
    }

    return 2000;
  }

  
}
