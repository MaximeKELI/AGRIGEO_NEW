// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openweather_polygon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenWeatherPolygonModel _$OpenWeatherPolygonModelFromJson(
  Map<String, dynamic> json,
) => OpenWeatherPolygonModel(
  id: json['id'] as String,
  name: json['name'] as String,
  area: (json['area'] as num).toDouble(),
  createdAt: json['createdAt'] as String,
  geoJson:
      json['geoJson'] == null
          ? null
          : GeoJson.fromJson(json['geoJson'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenWeatherPolygonModelToJson(
  OpenWeatherPolygonModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'area': instance.area,
  'createdAt': instance.createdAt,
  'geoJson': instance.geoJson,
};

GeoJson _$GeoJsonFromJson(Map<String, dynamic> json) => GeoJson(
  type: json['type'] as String,
  coordinates:
      (json['coordinates'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>)
                    .map(
                      (e) =>
                          (e as List<dynamic>)
                              .map((e) => (e as num).toDouble())
                              .toList(),
                    )
                    .toList(),
          )
          .toList(),
);

Map<String, dynamic> _$GeoJsonToJson(GeoJson instance) => <String, dynamic>{
  'type': instance.type,
  'coordinates': instance.coordinates,
};

CreatePolygonRequest _$CreatePolygonRequestFromJson(
  Map<String, dynamic> json,
) => CreatePolygonRequest(
  name: json['name'] as String,
  geoJson: GeoJson.fromJson(json['geoJson'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreatePolygonRequestToJson(
  CreatePolygonRequest instance,
) => <String, dynamic>{'name': instance.name, 'geoJson': instance.geoJson};

UpdatePolygonNameRequest _$UpdatePolygonNameRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePolygonNameRequest(name: json['name'] as String);

Map<String, dynamic> _$UpdatePolygonNameRequestToJson(
  UpdatePolygonNameRequest instance,
) => <String, dynamic>{'name': instance.name};

PolygonWeatherData _$PolygonWeatherDataFromJson(Map<String, dynamic> json) =>
    PolygonWeatherData(
      temp: (json['temp'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      windDirection: (json['windDirection'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      dt: json['dt'] == null ? null : DateTime.parse(json['dt'] as String),
    );

Map<String, dynamic> _$PolygonWeatherDataToJson(PolygonWeatherData instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
      'precipitation': instance.precipitation,
      'dt': instance.dt?.toIso8601String(),
    };

PolygonSatelliteData _$PolygonSatelliteDataFromJson(
  Map<String, dynamic> json,
) => PolygonSatelliteData(
  imageUrl: json['imageUrl'] as String?,
  ndvi: (json['ndvi'] as num?)?.toDouble(),
  evi: (json['evi'] as num?)?.toDouble(),
  dt: json['dt'] == null ? null : DateTime.parse(json['dt'] as String),
);

Map<String, dynamic> _$PolygonSatelliteDataToJson(
  PolygonSatelliteData instance,
) => <String, dynamic>{
  'imageUrl': instance.imageUrl,
  'ndvi': instance.ndvi,
  'evi': instance.evi,
  'dt': instance.dt?.toIso8601String(),
};
