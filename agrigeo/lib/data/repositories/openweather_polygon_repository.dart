import '../../core/errors/failures.dart';
import '../services/openweather_agro_service.dart';
import '../models/openweather_polygon_model.dart';

/// Repository pour gérer les polygones OpenWeather Agro
class OpenWeatherPolygonRepository {
  final OpenWeatherAgroService _agroService;

  OpenWeatherPolygonRepository({OpenWeatherAgroService? agroService})
      : _agroService = agroService ?? OpenWeatherAgroService();

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _agroService.setApiKey(apiKey);
  }

  /// Liste tous les polygones
  Future<List<OpenWeatherPolygonModel>> getPolygons() async {
    try {
      return await _agroService.listPolygons();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère un polygone par son ID
  Future<OpenWeatherPolygonModel> getPolygon(String polygonId) async {
    try {
      return await _agroService.getPolygon(polygonId);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Crée un nouveau polygone
  /// [name] : Nom du polygone
  /// [coordinates] : Liste de coordonnées [[lon, lat], [lon, lat], ...]
  Future<OpenWeatherPolygonModel> createPolygon({
    required String name,
    required List<List<double>> coordinates,
  }) async {
    try {
      return await _agroService.createPolygon(
        name: name,
        coordinates: coordinates,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Met à jour le nom d'un polygone
  Future<OpenWeatherPolygonModel> updatePolygonName({
    required String polygonId,
    required String newName,
  }) async {
    try {
      return await _agroService.updatePolygonName(
        polygonId: polygonId,
        newName: newName,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Supprime un polygone
  Future<void> deletePolygon(String polygonId) async {
    try {
      await _agroService.deletePolygon(polygonId);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère les données météo d'un polygone
  Future<PolygonWeatherData> getPolygonWeather(String polygonId) async {
    try {
      return await _agroService.getPolygonWeather(polygonId);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère les données satellite d'un polygone
  Future<List<PolygonSatelliteData>> getPolygonSatelliteData({
    required String polygonId,
    int? start,
    int? end,
    String type = 'ndvi',
  }) async {
    try {
      return await _agroService.getPolygonSatelliteData(
        polygonId: polygonId,
        start: start,
        end: end,
        type: type,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère les données de sol d'un polygone
  Future<Map<String, dynamic>> getPolygonSoilData(String polygonId) async {
    try {
      return await _agroService.getPolygonSoilData(polygonId);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

