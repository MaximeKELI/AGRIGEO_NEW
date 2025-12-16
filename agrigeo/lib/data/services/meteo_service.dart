import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/meteo_model.dart';

/// Service pour récupérer les données météo depuis OpenWeather API
class MeteoService {
  final Dio _dio;
  String? _apiKey;

  MeteoService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey;

  /// Configure la clé API OpenWeather
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Récupère la météo actuelle pour une localisation
  Future<MeteoModel> getMeteoActuelle({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey == null) {
      throw Exception('Clé API OpenWeather non configurée');
    }

    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric', // Température en Celsius
          'lang': 'fr', // Langue française
        },
      );

      return MeteoModel.fromOpenWeather(
        response.data,
        lat: latitude,
        lon: longitude,
      );
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération de la météo: ${e.message}');
    }
  }

  /// Récupère les prévisions météo (5 jours, 3 heures)
  Future<List<MeteoModel>> getPrevisions({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey == null) {
      throw Exception('Clé API OpenWeather non configurée');
    }

    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'fr',
        },
      );

      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((item) {
        return MeteoModel.fromOpenWeather(
          item,
          lat: latitude,
          lon: longitude,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des prévisions: ${e.message}');
    }
  }

  /// Récupère la météo actuelle et les prévisions
  Future<PrevisionMeteoModel> getMeteoComplete({
    required double latitude,
    required double longitude,
  }) async {
    final actuelle = await getMeteoActuelle(
      latitude: latitude,
      longitude: longitude,
    );
    final previsions = await getPrevisions(
      latitude: latitude,
      longitude: longitude,
    );

    return PrevisionMeteoModel(
      actuelle: actuelle,
      previsions: previsions,
    );
  }
}

