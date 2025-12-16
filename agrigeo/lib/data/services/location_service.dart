import 'package:geolocator/geolocator.dart';
import '../models/user_location_model.dart';

/// Service pour gérer la localisation de l'utilisateur en temps réel
class LocationService {
  Stream<Position>? _positionStream;
  bool _isListening = false;

  /// Vérifie et demande les permissions de localisation
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Les services de localisation sont désactivés. Veuillez les activer dans les paramètres.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Les permissions de localisation sont refusées. Veuillez les autoriser dans les paramètres.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres de l\'application.',
      );
    }

    return true;
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<UserLocationModel> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  }) async {
    await checkAndRequestPermission();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
      );
      return UserLocationModel.fromPosition(position);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la position: $e');
    }
  }

  /// Obtient la dernière position connue (peut être obsolète)
  Future<UserLocationModel?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return UserLocationModel.fromPosition(position);
    } catch (e) {
      return null;
    }
  }

  /// Démarre l'écoute de la position en temps réel
  /// Retourne un Stream de positions
  Stream<UserLocationModel> watchPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Distance minimale en mètres pour déclencher une mise à jour
    Duration? timeLimit,
  }) async* {
    await checkAndRequestPermission();

    if (_isListening) {
      throw Exception('L\'écoute de la position est déjà active');
    }

    _isListening = true;

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: desiredAccuracy,
          distanceFilter: distanceFilter,
          timeLimit: timeLimit,
        ),
      );

      await for (final position in _positionStream!) {
        yield UserLocationModel.fromPosition(position);
      }
    } finally {
      _isListening = false;
    }
  }

  /// Arrête l'écoute de la position
  void stopListening() {
    _positionStream = null;
    _isListening = false;
  }

  /// Vérifie si l'écoute est active
  bool get isListening => _isListening;

  /// Calcule la distance entre deux positions en mètres
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calcule le bearing (direction) entre deux positions en degrés
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Vérifie si les services de localisation sont activés
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Ouvre les paramètres de localisation de l'appareil
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Ouvre les paramètres de l'application pour les permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

