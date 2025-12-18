import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/openweather_polygon_model.dart';
import '../../data/repositories/openweather_polygon_repository.dart';

class OpenWeatherPolygonProvider with ChangeNotifier {
  final OpenWeatherPolygonRepository _repository;
  List<OpenWeatherPolygonModel> _polygons = [];
  OpenWeatherPolygonModel? _selectedPolygon;
  PolygonWeatherData? _weatherData;
  List<PolygonSatelliteData> _satelliteData = [];
  Map<String, dynamic>? _soilData;
  bool _isLoading = false;
  String? _error;

  OpenWeatherPolygonProvider({OpenWeatherPolygonRepository? repository})
      : _repository = repository ?? OpenWeatherPolygonRepository();

  List<OpenWeatherPolygonModel> get polygons => _polygons;
  OpenWeatherPolygonModel? get selectedPolygon => _selectedPolygon;
  PolygonWeatherData? get weatherData => _weatherData;
  List<PolygonSatelliteData> get satelliteData => _satelliteData;
  Map<String, dynamic>? get soilData => _soilData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Configure la clé API OpenWeather Agro
  void setApiKey(String apiKey) {
    _repository.setApiKey(apiKey);
  }

  /// Charge tous les polygones
  Future<void> loadPolygons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _polygons = await _repository.getPolygons();
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère un polygone par son ID
  Future<void> loadPolygon(String polygonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPolygon = await _repository.getPolygon(polygonId);
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau polygone
  Future<void> createPolygon({
    required String name,
    required List<List<double>> coordinates,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final polygon = await _repository.createPolygon(
        name: name,
        coordinates: coordinates,
      );
      _polygons.add(polygon);
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour le nom d'un polygone
  Future<void> updatePolygonName({
    required String polygonId,
    required String newName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPolygon = await _repository.updatePolygonName(
        polygonId: polygonId,
        newName: newName,
      );
      
      // Mettre à jour dans la liste
      final index = _polygons.indexWhere((p) => p.id == polygonId);
      if (index != -1) {
        _polygons[index] = updatedPolygon;
      }
      
      // Mettre à jour le polygone sélectionné si c'est celui-ci
      if (_selectedPolygon?.id == polygonId) {
        _selectedPolygon = updatedPolygon;
      }
      
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime un polygone
  Future<void> deletePolygon(String polygonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deletePolygon(polygonId);
      _polygons.removeWhere((p) => p.id == polygonId);
      
      // Réinitialiser le polygone sélectionné si c'est celui-ci
      if (_selectedPolygon?.id == polygonId) {
        _selectedPolygon = null;
        _weatherData = null;
        _satelliteData = [];
        _soilData = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Charge les données météo d'un polygone
  Future<void> loadPolygonWeather(String polygonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _repository.getPolygonWeather(polygonId);
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les données satellite d'un polygone
  Future<void> loadPolygonSatelliteData({
    required String polygonId,
    int? start,
    int? end,
    String type = 'ndvi',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _satelliteData = await _repository.getPolygonSatelliteData(
        polygonId: polygonId,
        start: start,
        end: end,
        type: type,
      );
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les données de sol d'un polygone
  Future<void> loadPolygonSoilData(String polygonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _soilData = await _repository.getPolygonSoilData(polygonId);
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sélectionne un polygone
  void selectPolygon(OpenWeatherPolygonModel? polygon) {
    _selectedPolygon = polygon;
    _weatherData = null;
    _satelliteData = [];
    _soilData = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}




