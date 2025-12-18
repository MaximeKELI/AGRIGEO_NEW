import 'package:json_annotation/json_annotation.dart';

part 'openweather_polygon_model.g.dart';

/// Modèle pour représenter un polygone OpenWeather Agro
@JsonSerializable()
class OpenWeatherPolygonModel {
  final String id;
  final String name;
  final double area; // Surface en hectares
  final String createdAt;
  final GeoJson? geoJson;

  OpenWeatherPolygonModel({
    required this.id,
    required this.name,
    required this.area,
    required this.createdAt,
    this.geoJson,
  });

  factory OpenWeatherPolygonModel.fromJson(Map<String, dynamic> json) =>
      _$OpenWeatherPolygonModelFromJson(json);
  Map<String, dynamic> toJson() => _$OpenWeatherPolygonModelToJson(this);
}

/// Modèle pour représenter la géométrie GeoJSON d'un polygone
@JsonSerializable()
class GeoJson {
  final String type;
  final List<List<List<double>>> coordinates; // [[[lon, lat], [lon, lat], ...]]

  GeoJson({
    required this.type,
    required this.coordinates,
  });

  factory GeoJson.fromJson(Map<String, dynamic> json) => _$GeoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$GeoJsonToJson(this);
}

/// Modèle pour créer un nouveau polygone
@JsonSerializable()
class CreatePolygonRequest {
  final String name;
  final GeoJson geoJson;

  CreatePolygonRequest({
    required this.name,
    required this.geoJson,
  });

  Map<String, dynamic> toJson() => _$CreatePolygonRequestToJson(this);
}

/// Modèle pour mettre à jour le nom d'un polygone
@JsonSerializable()
class UpdatePolygonNameRequest {
  final String name;

  UpdatePolygonNameRequest({required this.name});

  Map<String, dynamic> toJson() => _$UpdatePolygonNameRequestToJson(this);
}

/// Modèle pour les données météo d'un polygone
@JsonSerializable()
class PolygonWeatherData {
  final double? temp; // Température en °C
  final double? humidity; // Humidité en %
  final double? pressure; // Pression en hPa
  final double? windSpeed; // Vitesse du vent en m/s
  final double? windDirection; // Direction du vent en degrés
  final double? precipitation; // Précipitations en mm
  final DateTime? dt; // Date et heure

  PolygonWeatherData({
    this.temp,
    this.humidity,
    this.pressure,
    this.windSpeed,
    this.windDirection,
    this.precipitation,
    this.dt,
  });

  factory PolygonWeatherData.fromJson(Map<String, dynamic> json) =>
      _$PolygonWeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$PolygonWeatherDataToJson(this);
}

/// Modèle pour les données satellite d'un polygone
@JsonSerializable()
class PolygonSatelliteData {
  final String? imageUrl;
  final double? ndvi; // Indice de végétation NDVI
  final double? evi; // Indice de végétation EVI
  final DateTime? dt; // Date de l'image

  PolygonSatelliteData({
    this.imageUrl,
    this.ndvi,
    this.evi,
    this.dt,
  });

  factory PolygonSatelliteData.fromJson(Map<String, dynamic> json) =>
      _$PolygonSatelliteDataFromJson(json);
  Map<String, dynamic> toJson() => _$PolygonSatelliteDataToJson(this);
}




