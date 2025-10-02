class Car {
  final int? id;
  final String carName;
  final String? carDescription;
  final String? carAliasName;
  final String? carAlgorithm;
  final int carInitialMileage;
  final int carTraveledDistance;
  final double carRelativeVolume;
  final int carEnableRelativeVolume;
  final String? carChartPreferences;
  final String carStatisticsTable;

  Car({
    this.id,
    required this.carName,
    this.carDescription,
    this.carAliasName,
    this.carAlgorithm,
    this.carInitialMileage = 0,
    this.carTraveledDistance = 0,
    this.carRelativeVolume = 40.0,
    this.carEnableRelativeVolume = 0,
    this.carChartPreferences,
    required this.carStatisticsTable,
  });

  Map<String, dynamic> toMap() {
    return {
      '_car_id': id,
      'car_name': carName,
      'car_desctription': carDescription,
      'car_alias_name': carAliasName,
      'car_algoritm': carAlgorithm,
      'car_initial_millage': carInitialMileage,
      'car_traveled_distance': carTraveledDistance,
      'car_relative_volume': carRelativeVolume,
      'car_enable_relative_volume': carEnableRelativeVolume,
      'car_chart_preferences': carChartPreferences,
      'car_statistics_table': carStatisticsTable,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['_car_id'],
      carName: map['car_name'] ?? '',
      carDescription: map['car_desctription'],
      carAliasName: map['car_alias_name'],
      carAlgorithm: map['car_algoritm'],
      carInitialMileage: map['car_initial_millage'] ?? 0,
      carTraveledDistance: map['car_traveled_distance'] ?? 0,
      carRelativeVolume: (map['car_relative_volume'] ?? 40.0).toDouble(),
      carEnableRelativeVolume: map['car_enable_relative_volume'] ?? 0,
      carChartPreferences: map['car_chart_preferences'],
      carStatisticsTable: map['car_statistics_table'] ?? '',
    );
  }

  Car copyWith({
    int? id,
    String? carName,
    String? carDescription,
    String? carAliasName,
    String? carAlgorithm,
    int? carInitialMileage,
    int? carTraveledDistance,
    double? carRelativeVolume,
    int? carEnableRelativeVolume,
    String? carChartPreferences,
    String? carStatisticsTable,
  }) {
    return Car(
      id: id ?? this.id,
      carName: carName ?? this.carName,
      carDescription: carDescription ?? this.carDescription,
      carAliasName: carAliasName ?? this.carAliasName,
      carAlgorithm: carAlgorithm ?? this.carAlgorithm,
      carInitialMileage: carInitialMileage ?? this.carInitialMileage,
      carTraveledDistance: carTraveledDistance ?? this.carTraveledDistance,
      carRelativeVolume: carRelativeVolume ?? this.carRelativeVolume,
      carEnableRelativeVolume: carEnableRelativeVolume ?? this.carEnableRelativeVolume,
      carChartPreferences: carChartPreferences ?? this.carChartPreferences,
      carStatisticsTable: carStatisticsTable ?? this.carStatisticsTable,
    );
  }
}