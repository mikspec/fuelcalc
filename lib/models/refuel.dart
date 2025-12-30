import 'package:intl/intl.dart';
import 'refuel_type.dart';

class Refuel {
  final int? id;
  final double odometerState;
  final double volumes;
  final double prize;
  final String? information;
  final double rating;
  final DateTime date;
  final double distance;
  final double gpsLatitude;
  final double gpsLongitude;
  final RefuelType refuelType;

  Refuel({
    this.id,
    this.odometerState = 0.0,
    this.volumes = 4.5,
    this.prize = 4.0,
    this.information,
    this.rating = 5.0,
    required this.date,
    this.distance = 200.0,
    this.gpsLatitude = 0.0,
    this.gpsLongitude = 0.0,
    this.refuelType = RefuelType.partial,
  });

  Map<String, dynamic> toMap() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      '_id': id,
      'odometer_state': 0.0, // Always store as 0.0, not used for calculations
      'volumes': volumes,
      'prize': prize,
      'information': information,
      'rating': rating,
      'date': dateFormat.format(date),
      'distance': distance,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'refuel_type': refuelType.value,
    };
  }

  factory Refuel.fromMap(Map<String, dynamic> map) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime parseDate(String dateString) {
      try {
        // Try custom format first
        return dateFormat.parse(dateString);
      } catch (e) {
        // Fallback to ISO8601 for backward compatibility
        return DateTime.parse(dateString);
      }
    }

    return Refuel(
      id: map['_id'],
      odometerState: (map['odometer_state'] ?? 0.0).toDouble(),
      volumes: (map['volumes'] ?? 4.5).toDouble(),
      prize: (map['prize'] ?? 4.0).toDouble(),
      information: map['information'],
      rating: (map['rating'] ?? 5.0).toDouble(),
      date: parseDate(map['date']),
      distance: (map['distance'] ?? 200.0).toDouble(),
      gpsLatitude: (map['gps_latitude'] ?? 0.0).toDouble(),
      gpsLongitude: (map['gps_longitude'] ?? 0.0).toDouble(),
      refuelType: RefuelType.fromValue(map['refuel_type'] ?? 0),
    );
  }

  Refuel copyWith({
    int? id,
    double? odometerState,
    double? volumes,
    double? prize,
    String? information,
    double? rating,
    DateTime? date,
    double? distance,
    double? gpsLatitude,
    double? gpsLongitude,
    RefuelType? refuelType,
  }) {
    return Refuel(
      id: id ?? this.id,
      odometerState: odometerState ?? this.odometerState,
      volumes: volumes ?? this.volumes,
      prize: prize ?? this.prize,
      information: information ?? this.information,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      distance: distance ?? this.distance,
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      refuelType: refuelType ?? this.refuelType,
    );
  }

  // Calculate consumption (liters per 100km)
  double get consumption => distance > 0 ? (volumes / distance) * 100 : 0.0;

  // Calculate total cost (price per liter * liters)
  double get totalCost => prize * volumes;

  // Calculate cost per 100km
  double get costPer100km => distance > 0 ? (totalCost / distance) * 100 : 0.0;
}
