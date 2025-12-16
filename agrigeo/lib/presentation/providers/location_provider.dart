import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/user_location_model.dart';
import '../../data/services/location_service.dart';

/// Provider pour gérer la localisation de l'utilisateur en temps réel
class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  UserLocationModel? _currentLocation;
  UserLocationModel? _lastKnownLocation;
  bool _isLoading = false;
  bool _isTracking = false;
  String? _error;
  StreamSubscription<UserLocationModel>? _locationSubscription;
  LocationAccuracy _accuracy = LocationAccuracy.high;
  int _distanceFilter = 10; // Distance minimale en mètres pour une mise à jour

  LocationProvider({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  UserLocationModel? get currentLocation => _currentLocation;
  UserLocationModel? get lastKnownLocation => _lastKnownLocation;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;
  String? get error => _error;
  LocationAccuracy get accuracy => _accuracy;
  int get distanceFilter => _distanceFilter;

  /// Configure la précision de localisation
  void setAccuracy(LocationAccuracy accuracy) {
    _accuracy = accuracy;
    notifyListeners();
  }

  /// Configure la distance minimale pour déclencher une mise à jour
  void setDistanceFilter(int meters) {
    _distanceFilter = meters;
    notifyListeners();
  }

  /// Vérifie et demande les permissions
  Future<bool> checkAndRequestPermission() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await _locationService.checkAndRequestPermission();
      _isLoading = false;
      notifyListeners();
      return hasPermission;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtient la position actuelle
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLocation = await _locationService.getCurrentLocation(
        desiredAccuracy: _accuracy,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge la dernière position connue
  Future<void> loadLastKnownLocation() async {
    try {
      _lastKnownLocation = await _locationService.getLastKnownLocation();
      if (_lastKnownLocation != null) {
        _currentLocation = _lastKnownLocation;
        notifyListeners();
      }
    } catch (e) {
      // Ignorer les erreurs pour la dernière position connue
    }
  }

  /// Démarre le suivi de la position en temps réel
  Future<void> startTracking() async {
    if (_isTracking) {
      return; // Déjà en cours
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier les permissions
      await checkAndRequestPermission();

      // Démarrer le suivi
      _isTracking = true;
      _isLoading = false;
      notifyListeners();

      _locationSubscription = _locationService
          .watchPosition(
            desiredAccuracy: _accuracy,
            distanceFilter: _distanceFilter,
          )
          .listen(
        (location) {
          _currentLocation = location;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isTracking = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isTracking = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Arrête le suivi de la position
  void stopTracking() {
    if (!_isTracking) {
      return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Calcule la distance entre la position actuelle et une autre position
  double? distanceTo(double latitude, double longitude) {
    if (_currentLocation == null) {
      return null;
    }

    return _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      latitude,
      longitude,
    );
  }

  /// Calcule la direction vers une autre position
  double? bearingTo(double latitude, double longitude) {
    if (_currentLocation == null) {
      return null;
    }

    return _locationService.calculateBearing(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      latitude,
      longitude,
    );
  }

  /// Vérifie si les services de localisation sont activés
  Future<bool> isLocationServiceEnabled() async {
    return await _locationService.isLocationServiceEnabled();
  }

  /// Ouvre les paramètres de localisation
  Future<bool> openLocationSettings() async {
    return await _locationService.openLocationSettings();
  }

  /// Ouvre les paramètres de l'application
  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

