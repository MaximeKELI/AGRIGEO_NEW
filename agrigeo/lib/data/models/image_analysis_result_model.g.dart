// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_analysis_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageAnalysisResultModel _$ImageAnalysisResultModelFromJson(
  Map<String, dynamic> json,
) => ImageAnalysisResultModel(
  id: json['id'] as String,
  imagePath: json['imagePath'] as String,
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
  type: $enumDecode(_$AnalysisTypeEnumMap, json['type']),
  diseases:
      (json['diseases'] as List<dynamic>?)
          ?.map((e) => DiseaseDetection.fromJson(e as Map<String, dynamic>))
          .toList(),
  plants:
      (json['plants'] as List<dynamic>?)
          ?.map((e) => PlantDetection.fromJson(e as Map<String, dynamic>))
          .toList(),
  weather:
      json['weather'] == null
          ? null
          : WeatherInfo.fromJson(json['weather'] as Map<String, dynamic>),
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
  soilAnalysis:
      json['soilAnalysis'] == null
          ? null
          : SoilAnalysis.fromJson(json['soilAnalysis'] as Map<String, dynamic>),
  confidence: (json['confidence'] as num?)?.toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ImageAnalysisResultModelToJson(
  ImageAnalysisResultModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'imagePath': instance.imagePath,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
  'type': _$AnalysisTypeEnumMap[instance.type]!,
  'diseases': instance.diseases,
  'plants': instance.plants,
  'weather': instance.weather,
  'recommendations': instance.recommendations,
  'soilAnalysis': instance.soilAnalysis,
  'confidence': instance.confidence,
  'metadata': instance.metadata,
};

const _$AnalysisTypeEnumMap = {
  AnalysisType.plant: 'plant',
  AnalysisType.field: 'field',
  AnalysisType.disease: 'disease',
  AnalysisType.weather: 'weather',
  AnalysisType.soil: 'soil',
  AnalysisType.general: 'general',
};

DiseaseDetection _$DiseaseDetectionFromJson(Map<String, dynamic> json) =>
    DiseaseDetection(
      name: json['name'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String,
      treatments:
          (json['treatments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      affectedArea: json['affectedArea'] as String?,
    );

Map<String, dynamic> _$DiseaseDetectionToJson(DiseaseDetection instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'confidence': instance.confidence,
      'severity': instance.severity,
      'treatments': instance.treatments,
      'affectedArea': instance.affectedArea,
    };

PlantDetection _$PlantDetectionFromJson(Map<String, dynamic> json) =>
    PlantDetection(
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      growthStage: json['growthStage'] as String?,
      healthStatus: json['healthStatus'] as String?,
      characteristics: json['characteristics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PlantDetectionToJson(PlantDetection instance) =>
    <String, dynamic>{
      'name': instance.name,
      'scientificName': instance.scientificName,
      'confidence': instance.confidence,
      'growthStage': instance.growthStage,
      'healthStatus': instance.healthStatus,
      'characteristics': instance.characteristics,
    };

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) => WeatherInfo(
  condition: json['condition'] as String?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  humidity: (json['humidity'] as num?)?.toDouble(),
  cloudCover: json['cloudCover'] as String?,
  visibility: json['visibility'] as String?,
);

Map<String, dynamic> _$WeatherInfoToJson(WeatherInfo instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'cloudCover': instance.cloudCover,
      'visibility': instance.visibility,
    };

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      actions:
          (json['actions'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'priority': instance.priority,
      'actions': instance.actions,
    };

SoilAnalysis _$SoilAnalysisFromJson(Map<String, dynamic> json) => SoilAnalysis(
  texture: json['texture'] as String?,
  color: json['color'] as String?,
  moistureLevel: (json['moistureLevel'] as num?)?.toDouble(),
  quality: json['quality'] as String?,
  issues: (json['issues'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$SoilAnalysisToJson(SoilAnalysis instance) =>
    <String, dynamic>{
      'texture': instance.texture,
      'color': instance.color,
      'moistureLevel': instance.moistureLevel,
      'quality': instance.quality,
      'issues': instance.issues,
    };
