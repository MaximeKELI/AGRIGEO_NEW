import 'package:json_annotation/json_annotation.dart';

part 'image_analysis_result_model.g.dart';

/// Modèle pour représenter les résultats d'analyse d'image IA
@JsonSerializable()
class ImageAnalysisResultModel {
  final String id;
  final String imagePath;
  final DateTime analyzedAt;
  final AnalysisType type;
  
  // Détections
  final List<DiseaseDetection>? diseases;
  final List<PlantDetection>? plants;
  final WeatherInfo? weather;
  final List<Recommendation>? recommendations;
  final SoilAnalysis? soilAnalysis;
  
  // Métadonnées
  final double? confidence; // Confiance globale de l'analyse (0-1)
  final Map<String, dynamic>? metadata;

  ImageAnalysisResultModel({
    required this.id,
    required this.imagePath,
    required this.analyzedAt,
    required this.type,
    this.diseases,
    this.plants,
    this.weather,
    this.recommendations,
    this.soilAnalysis,
    this.confidence,
    this.metadata,
  });

  factory ImageAnalysisResultModel.fromJson(Map<String, dynamic> json) =>
      _$ImageAnalysisResultModelFromJson(json);
  Map<String, dynamic> toJson() => _$ImageAnalysisResultModelToJson(this);
}

/// Type d'analyse effectuée
enum AnalysisType {
  plant, // Analyse de plantes
  field, // Analyse de champ/zone agricole
  disease, // Détection de maladies
  weather, // Analyse météo
  soil, // Analyse de sol
  general, // Analyse générale
}

/// Détection de maladie
@JsonSerializable()
class DiseaseDetection {
  final String name;
  final String description;
  final double confidence; // 0-1
  final String severity; // légère, modérée, sévère
  final List<String>? treatments; // Traitements recommandés
  final String? affectedArea; // Zone affectée dans l'image

  DiseaseDetection({
    required this.name,
    required this.description,
    required this.confidence,
    required this.severity,
    this.treatments,
    this.affectedArea,
  });

  factory DiseaseDetection.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$DiseaseDetectionToJson(this);
}

/// Détection de plante
@JsonSerializable()
class PlantDetection {
  final String name;
  final String scientificName;
  final double confidence; // 0-1
  final String? growthStage; // stade de croissance
  final String? healthStatus; // santé de la plante
  final Map<String, dynamic>? characteristics; // Caractéristiques supplémentaires

  PlantDetection({
    required this.name,
    required this.scientificName,
    required this.confidence,
    this.growthStage,
    this.healthStatus,
    this.characteristics,
  });

  factory PlantDetection.fromJson(Map<String, dynamic> json) =>
      _$PlantDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$PlantDetectionToJson(this);
}

/// Informations météo détectées
@JsonSerializable()
class WeatherInfo {
  final String? condition; // ensoleillé, nuageux, pluvieux, etc.
  final double? temperature; // Température estimée en °C
  final double? humidity; // Humidité estimée en %
  final String? cloudCover; // Couverture nuageuse
  final String? visibility; // Visibilité

  WeatherInfo({
    this.condition,
    this.temperature,
    this.humidity,
    this.cloudCover,
    this.visibility,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherInfoToJson(this);
}

/// Recommandation basée sur l'analyse
@JsonSerializable()
class Recommendation {
  final String title;
  final String description;
  final String category; // irrigation, fertilisation, traitement, etc.
  final String priority; // haute, moyenne, basse
  final List<String>? actions; // Actions à entreprendre

  Recommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.actions,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

/// Analyse de sol basée sur l'image
@JsonSerializable()
class SoilAnalysis {
  final String? texture; // Texture du sol
  final String? color; // Couleur du sol
  final double? moistureLevel; // Niveau d'humidité estimé
  final String? quality; // Qualité du sol
  final List<String>? issues; // Problèmes détectés

  SoilAnalysis({
    this.texture,
    this.color,
    this.moistureLevel,
    this.quality,
    this.issues,
  });

  factory SoilAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SoilAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SoilAnalysisToJson(this);
}

