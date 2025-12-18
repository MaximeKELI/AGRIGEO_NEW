import 'package:json_annotation/json_annotation.dart';

part 'meteo_model.g.dart';

@JsonSerializable()
class MeteoModel {
  final double? temperature;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidite;
  final double? pression;
  final double? vitesseVent;
  final String? description;
  final String? icon;
  final double? pluviometrie;
  final DateTime? date;
  final double? latitude;
  final double? longitude;

  MeteoModel({
    this.temperature,
    this.temperatureMin,
    this.temperatureMax,
    this.humidite,
    this.pression,
    this.vitesseVent,
    this.description,
    this.icon,
    this.pluviometrie,
    this.date,
    this.latitude,
    this.longitude,
  });

  factory MeteoModel.fromJson(Map<String, dynamic> json) => _$MeteoModelFromJson(json);
  Map<String, dynamic> toJson() => _$MeteoModelToJson(this);

  // Factory pour créer depuis OpenWeather API response
  factory MeteoModel.fromOpenWeather(Map<String, dynamic> json, {double? lat, double? lon}) {
    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?.first ?? {};
    final wind = json['wind'] ?? {};
    final rain = json['rain'] ?? {};

    return MeteoModel(
      temperature: (main['temp'] as num?)?.toDouble(),
      temperatureMin: (main['temp_min'] as num?)?.toDouble(),
      temperatureMax: (main['temp_max'] as num?)?.toDouble(),
      humidite: (main['humidity'] as num?)?.toDouble(),
      pression: (main['pressure'] as num?)?.toDouble(),
      vitesseVent: (wind['speed'] as num?)?.toDouble(),
      description: weather['description'] as String?,
      icon: weather['icon'] as String?,
      pluviometrie: (rain['1h'] as num?)?.toDouble() ?? (rain['3h'] as num?)?.toDouble(),
      date: json['dt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000) : null,
      latitude: lat,
      longitude: lon,
    );
  }
}

@JsonSerializable()
class PrevisionMeteoModel {
  final List<MeteoModel> previsions;
  final MeteoModel? actuelle;

  PrevisionMeteoModel({
    required this.previsions,
    this.actuelle,
  });

  factory PrevisionMeteoModel.fromJson(Map<String, dynamic> json) => _$PrevisionMeteoModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrevisionMeteoModelToJson(this);
}




