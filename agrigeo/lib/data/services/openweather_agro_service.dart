import 'package:dio/dio.dart';
import '../models/openweather_polygon_model.dart';

/// Service pour interagir avec l'API OpenWeather Agro
/// Documentation: https://agromonitoring.com/api/get
class OpenWeatherAgroService {
  final Dio _dio;
  String? _apiKey;
  
  // Base URL de l'API OpenWeather Agro
  static const String baseUrl = 'https://api.agromonitoring.com/agro/1.0';

  OpenWeatherAgroService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)),
        _apiKey = apiKey;

  /// Configure la clé API OpenWeather Agro
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Vérifie que la clé API est configurée
  void _checkApiKey() {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Clé API OpenWeather Agro non configurée');
    }
  }

  /// Crée un nouveau polygone
  /// [name] : Nom du polygone
  /// [coordinates] : Liste de coordonnées [[lon, lat], [lon, lat], ...]
  Future<OpenWeatherPolygonModel> createPolygon({
    required String name,
    required List<List<double>> coordinates,
  }) async {
    _checkApiKey();

    // Fermer le polygone en ajoutant le premier point à la fin
    final closedCoordinates = List<List<double>>.from(coordinates);
    if (closedCoordinates.isNotEmpty &&
        (closedCoordinates.first[0] != closedCoordinates.last[0] ||
            closedCoordinates.first[1] != closedCoordinates.last[1])) {
      closedCoordinates.add([closedCoordinates.first[0], closedCoordinates.first[1]]);
    }

    final geoJson = GeoJson(
      type: 'Polygon',
      coordinates: [closedCoordinates],
    );

    final request = CreatePolygonRequest(
      name: name,
      geoJson: geoJson,
    );

    try {
      final response = await _dio.post(
        '/polygons',
        queryParameters: {'appid': _apiKey},
        data: request.toJson(),
      );

      return OpenWeatherPolygonModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la création du polygone: $errorMsg');
      }
      throw Exception('Erreur lors de la création du polygone: ${e.message}');
    }
  }

  /// Liste tous les polygones de l'utilisateur
  Future<List<OpenWeatherPolygonModel>> listPolygons() async {
    _checkApiKey();

    try {
      final response = await _dio.get(
        '/polygons',
        queryParameters: {'appid': _apiKey},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => OpenWeatherPolygonModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la récupération des polygones: $errorMsg');
      }
      throw Exception('Erreur lors de la récupération des polygones: ${e.message}');
    }
  }

  /// Récupère les détails d'un polygone spécifique
  Future<OpenWeatherPolygonModel> getPolygon(String polygonId) async {
    _checkApiKey();

    try {
      final response = await _dio.get(
        '/polygons/$polygonId',
        queryParameters: {'appid': _apiKey},
      );

      return OpenWeatherPolygonModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la récupération du polygone: $errorMsg');
      }
      throw Exception('Erreur lors de la récupération du polygone: ${e.message}');
    }
  }

  /// Met à jour le nom d'un polygone
  Future<OpenWeatherPolygonModel> updatePolygonName({
    required String polygonId,
    required String newName,
  }) async {
    _checkApiKey();

    final request = UpdatePolygonNameRequest(name: newName);

    try {
      final response = await _dio.put(
        '/polygons/$polygonId',
        queryParameters: {'appid': _apiKey},
        data: request.toJson(),
      );

      return OpenWeatherPolygonModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la mise à jour du polygone: $errorMsg');
      }
      throw Exception('Erreur lors de la mise à jour du polygone: ${e.message}');
    }
  }

  /// Supprime un polygone
  Future<void> deletePolygon(String polygonId) async {
    _checkApiKey();

    try {
      await _dio.delete(
        '/polygons/$polygonId',
        queryParameters: {'appid': _apiKey},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la suppression du polygone: $errorMsg');
      }
      throw Exception('Erreur lors de la suppression du polygone: ${e.message}');
    }
  }

  /// Récupère les données météo actuelles pour un polygone
  Future<PolygonWeatherData> getPolygonWeather(String polygonId) async {
    _checkApiKey();

    try {
      final response = await _dio.get(
        '/polygons/$polygonId/weather',
        queryParameters: {'appid': _apiKey},
      );

      return PolygonWeatherData.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la récupération des données météo: $errorMsg');
      }
      throw Exception('Erreur lors de la récupération des données météo: ${e.message}');
    }
  }

  /// Récupère les données satellite pour un polygone
  /// [start] et [end] : Dates de début et fin au format Unix timestamp
  /// [type] : Type d'image ('truecolor', 'falsecolor', 'ndvi', 'evi')
  Future<List<PolygonSatelliteData>> getPolygonSatelliteData({
    required String polygonId,
    int? start,
    int? end,
    String type = 'ndvi',
  }) async {
    _checkApiKey();

    final queryParams = <String, dynamic>{
      'appid': _apiKey,
      'type': type,
    };
    if (start != null) queryParams['start'] = start;
    if (end != null) queryParams['end'] = end;

    try {
      final response = await _dio.get(
        '/polygons/$polygonId/satellite',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => PolygonSatelliteData.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la récupération des données satellite: $errorMsg');
      }
      throw Exception('Erreur lors de la récupération des données satellite: ${e.message}');
    }
  }

  /// Récupère les données de sol pour un polygone
  Future<Map<String, dynamic>> getPolygonSoilData(String polygonId) async {
    _checkApiKey();

    try {
      final response = await _dio.get(
        '/polygons/$polygonId/soil',
        queryParameters: {'appid': _apiKey},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de la récupération des données de sol: $errorMsg');
      }
      throw Exception('Erreur lors de la récupération des données de sol: ${e.message}');
    }
  }
}

