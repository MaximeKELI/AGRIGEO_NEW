// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meteo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeteoModel _$MeteoModelFromJson(Map<String, dynamic> json) => MeteoModel(
  temperature: (json['temperature'] as num?)?.toDouble(),
  temperatureMin: (json['temperatureMin'] as num?)?.toDouble(),
  temperatureMax: (json['temperatureMax'] as num?)?.toDouble(),
  humidite: (json['humidite'] as num?)?.toDouble(),
  pression: (json['pression'] as num?)?.toDouble(),
  vitesseVent: (json['vitesseVent'] as num?)?.toDouble(),
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  pluviometrie: (json['pluviometrie'] as num?)?.toDouble(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MeteoModelToJson(MeteoModel instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'temperatureMin': instance.temperatureMin,
      'temperatureMax': instance.temperatureMax,
      'humidite': instance.humidite,
      'pression': instance.pression,
      'vitesseVent': instance.vitesseVent,
      'description': instance.description,
      'icon': instance.icon,
      'pluviometrie': instance.pluviometrie,
      'date': instance.date?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

PrevisionMeteoModel _$PrevisionMeteoModelFromJson(Map<String, dynamic> json) =>
    PrevisionMeteoModel(
      previsions:
          (json['previsions'] as List<dynamic>)
              .map((e) => MeteoModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      actuelle:
          json['actuelle'] == null
              ? null
              : MeteoModel.fromJson(json['actuelle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrevisionMeteoModelToJson(
  PrevisionMeteoModel instance,
) => <String, dynamic>{
  'previsions': instance.previsions,
  'actuelle': instance.actuelle,
};
