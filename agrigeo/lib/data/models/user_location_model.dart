import 'dart:math' as math;

/// Modèle pour représenter la position de l'utilisateur
class UserLocationModel {
  final double latitude;
  final double longitude;
  final double? accuracy; // Précision en mètres
  final double? altitude; // Altitude en mètres
  final double? speed; // Vitesse en m/s
  final double? heading; // Direction en degrés (0-360)
  final DateTime timestamp;

  UserLocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Crée un modèle depuis un objet Position de geolocator
  factory UserLocationModel.fromPosition(dynamic position) {
    return UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp ?? DateTime.now(),
    );
  }

  /// Convertit en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory UserLocationModel.fromMap(Map<String, dynamic> map) {
    return UserLocationModel(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracy: map['accuracy'] as double?,
      altitude: map['altitude'] as double?,
      speed: map['speed'] as double?,
      heading: map['heading'] as double?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Calcule la distance en mètres entre deux positions (formule de Haversine)
  double distanceTo(UserLocationModel other) {
    const double earthRadius = 6371000; // Rayon de la Terre en mètres

    final double lat1Rad = latitude * (3.141592653589793 / 180);
    final double lat2Rad = other.latitude * (3.141592653589793 / 180);
    final double deltaLatRad = (other.latitude - latitude) * (3.141592653589793 / 180);
    final double deltaLonRad = (other.longitude - longitude) * (3.141592653589793 / 180);

    final double a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() *
            lat2Rad.cos() *
            (deltaLonRad / 2).sin() *
            (deltaLonRad / 2).sin();
    final double c = 2 * a.sqrt().asin();

    return earthRadius * c;
  }

  /// Retourne une représentation textuelle de la position
  @override
  String toString() {
    return 'Lat: $latitude, Lon: $longitude, Accuracy: ${accuracy?.toStringAsFixed(1)}m';
  }
}

