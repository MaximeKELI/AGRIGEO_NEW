/// Exemple d'utilisation du service OpenWeather Agro
/// 
/// Clé API fournie: 45d1412ba24561bcb4b9d4703638e077
/// 
/// Documentation: https://agromonitoring.com/api/get
/// Dashboard: https://agromonitoring.com/dashboard/dashboard-start

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../repositories/openweather_polygon_repository.dart';
import '../models/openweather_polygon_model.dart';

class OpenWeatherAgroExample {
  /// Exemple: Configuration de la clé API
  static Future<void> configureApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    
    // La clé API fournie
    const apiKey = '45d1412ba24561bcb4b9d4703638e077';
    
    // Sauvegarder la clé API
    await prefs.setString(AppConstants.openWeatherAgroApiKey, apiKey);
    
    // Utiliser le repository
    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);
  }

  /// Exemple: Créer un polygone depuis les coordonnées d'une exploitation
  static Future<OpenWeatherPolygonModel> createPolygonFromExploitation({
    required String name,
    required double latitude,
    required double longitude,
    double radiusKm = 0.5, // Rayon en kilomètres pour créer un polygone carré
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    // Créer un polygone carré autour du point central
    // Conversion approximative: 1 degré ≈ 111 km
    final deltaLat = radiusKm / 111.0;
    final deltaLon = radiusKm / (111.0 * (latitude / 90.0).abs());

    final coordinates = [
      [longitude - deltaLon, latitude - deltaLat], // Coin sud-ouest
      [longitude + deltaLon, latitude - deltaLat], // Coin sud-est
      [longitude + deltaLon, latitude + deltaLat], // Coin nord-est
      [longitude - deltaLon, latitude + deltaLat], // Coin nord-ouest
      [longitude - deltaLon, latitude - deltaLat], // Fermer le polygone
    ];

    return await repository.createPolygon(
      name: name,
      coordinates: coordinates,
    );
  }

  /// Exemple: Lister tous les polygones
  static Future<List<OpenWeatherPolygonModel>> listAllPolygons() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    return await repository.getPolygons();
  }

  /// Exemple: Récupérer les données météo d'un polygone
  static Future<PolygonWeatherData> getWeatherForPolygon(String polygonId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    return await repository.getPolygonWeather(polygonId);
  }

  /// Exemple: Récupérer les données satellite NDVI d'un polygone
  static Future<List<PolygonSatelliteData>> getNDVIDataForPolygon(
    String polygonId, {
    int? startTimestamp,
    int? endTimestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    return await repository.getPolygonSatelliteData(
      polygonId: polygonId,
      start: startTimestamp,
      end: endTimestamp,
      type: 'ndvi',
    );
  }

  /// Exemple: Mettre à jour le nom d'un polygone
  static Future<OpenWeatherPolygonModel> updatePolygonName({
    required String polygonId,
    required String newName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    return await repository.updatePolygonName(
      polygonId: polygonId,
      newName: newName,
    );
  }

  /// Exemple: Supprimer un polygone
  static Future<void> deletePolygon(String polygonId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConstants.openWeatherAgroApiKey);
    
    if (apiKey == null) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }

    final repository = OpenWeatherPolygonRepository();
    repository.setApiKey(apiKey);

    await repository.deletePolygon(polygonId);
  }
}

