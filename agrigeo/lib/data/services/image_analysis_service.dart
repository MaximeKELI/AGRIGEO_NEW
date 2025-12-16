import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/image_analysis_result_model.dart';
import 'gemini_vision_service.dart';
import 'sentinel_hub_service.dart';

/// Service principal pour l'analyse d'images agricoles avec IA
class ImageAnalysisService {
  final GeminiVisionService _geminiService;
  final SentinelHubService _sentinelHubService;

  ImageAnalysisService({
    GeminiVisionService? geminiService,
    SentinelHubService? sentinelHubService,
  })  : _geminiService = geminiService ?? GeminiVisionService(),
        _sentinelHubService = sentinelHubService ?? SentinelHubService();

  /// Configure les credentials Sentinel Hub
  Future<void> setSentinelHubCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    try {
      await _sentinelHubService.setCredentials(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );
    } catch (e) {
      throw ServerFailure('Erreur lors de la configuration Sentinel Hub: $e');
    }
  }

  /// Charge les credentials depuis le stockage
  Future<void> loadCredentials() async {
    try {
      // Charger Gemini API key
      final prefs = await SharedPreferences.getInstance();
      final geminiKey = prefs.getString(AppConstants.geminiApiKey);
      if (geminiKey != null) {
        _geminiService.setApiKey(geminiKey);
      }

      // Charger Sentinel Hub credentials
      await _sentinelHubService.loadCredentials();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Analyse une image avec le type spécifié
  Future<ImageAnalysisResultModel> analyzeImage({
    required File imageFile,
    required AnalysisType analysisType,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Analyser l'image avec Gemini Vision
      final geminiResult = await _geminiService.analyzeImage(
        imageFile: imageFile,
        analysisType: analysisType,
        latitude: latitude,
        longitude: longitude,
      );

      // Enrichir avec les données Sentinel Hub si disponible et si on a des coordonnées
      Map<String, dynamic>? sentinelData;
      if (latitude != null && longitude != null) {
        try {
          sentinelData = await _getSentinelHubData(
            latitude: latitude,
            longitude: longitude,
          );
        } catch (e) {
          // Ignorer les erreurs Sentinel Hub, continuer avec Gemini seulement
        }
      }

      // Construire le résultat final
      return _buildResultModel(
        imageFile: imageFile,
        analysisType: analysisType,
        geminiData: geminiResult,
        sentinelData: sentinelData,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Erreur lors de l\'analyse: ${e.toString()}');
    }
  }

  /// Analyse rapide (détection automatique du type)
  Future<ImageAnalysisResultModel> quickAnalyze(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.general,
    );
  }

  /// Analyse spécifique pour les maladies
  Future<ImageAnalysisResultModel> analyzeForDiseases(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.disease,
    );
  }

  /// Analyse spécifique pour les plantes
  Future<ImageAnalysisResultModel> analyzeForPlants(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.plant,
    );
  }

  /// Analyse spécifique pour le sol
  Future<ImageAnalysisResultModel> analyzeForSoil(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.soil,
    );
  }

  /// Analyse spécifique pour la météo
  Future<ImageAnalysisResultModel> analyzeForWeather(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.weather,
    );
  }

  /// Récupère les données Sentinel Hub pour une localisation
  Future<Map<String, dynamic>?> _getSentinelHubData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Créer un bounding box autour de la position (environ 1km)
      const double offset = 0.01; // ~1km
      final bbox = [
        longitude - offset, // minLon
        latitude - offset, // minLat
        longitude + offset, // maxLon
        latitude + offset, // maxLat
      ];

      final vegetationData = await _sentinelHubService.getVegetationIndices(
        bbox: bbox,
        time: 'latest',
      );

      return {
        'vegetationIndices': vegetationData,
        'location': {'latitude': latitude, 'longitude': longitude},
      };
    } catch (e) {
      return null;
    }
  }

  /// Construit le modèle de résultat à partir des données
  ImageAnalysisResultModel _buildResultModel({
    required File imageFile,
    required AnalysisType analysisType,
    required Map<String, dynamic> geminiData,
    Map<String, dynamic>? sentinelData,
  }) {
    // Parser les données Gemini
    final diseases = geminiData['diseases'] != null
        ? (geminiData['diseases'] as List)
            .map((d) => DiseaseDetection.fromJson(d as Map<String, dynamic>))
            .toList()
        : null;

    final plants = geminiData['plants'] != null
        ? (geminiData['plants'] as List)
            .map((p) => PlantDetection.fromJson(p as Map<String, dynamic>))
            .toList()
        : null;

    final weather = geminiData['weather'] != null
        ? WeatherInfo.fromJson(geminiData['weather'] as Map<String, dynamic>)
        : null;

    final soilAnalysis = geminiData['soilAnalysis'] != null
        ? SoilAnalysis.fromJson(
            geminiData['soilAnalysis'] as Map<String, dynamic>)
        : null;

    // Générer des recommandations basées sur les détections
    final recommendations = _generateRecommendations(
      diseases: diseases,
      plants: plants,
      soilAnalysis: soilAnalysis,
      weather: weather,
      sentinelData: sentinelData,
    );

    // Calculer la confiance globale
    final confidence = geminiData['confidence'] as double? ?? 0.7;

    return ImageAnalysisResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imageFile.path,
      analyzedAt: DateTime.now(),
      type: analysisType,
      diseases: diseases,
      plants: plants,
      weather: weather,
      soilAnalysis: soilAnalysis,
      recommendations: recommendations,
      confidence: confidence,
      metadata: {
        'gemini': geminiData,
        if (sentinelData != null) 'sentinelHub': sentinelData,
      },
    );
  }

  /// Génère des recommandations basées sur les détections
  List<Recommendation> _generateRecommendations({
    List<DiseaseDetection>? diseases,
    List<PlantDetection>? plants,
    SoilAnalysis? soilAnalysis,
    WeatherInfo? weather,
    Map<String, dynamic>? sentinelData,
  }) {
    final recommendations = <Recommendation>[];

    // Recommandations pour les maladies
    if (diseases != null && diseases.isNotEmpty) {
      for (final disease in diseases) {
        recommendations.add(Recommendation(
          title: 'Traitement pour ${disease.name}',
          description: disease.description,
          category: 'traitement',
          priority: disease.severity == 'sévère' || disease.severity == 'severe'
              ? 'haute'
              : disease.severity == 'modérée' || disease.severity == 'moderate'
                  ? 'moyenne'
                  : 'basse',
          actions: disease.treatments,
        ));
      }
    }

    // Recommandations pour le sol
    if (soilAnalysis != null) {
      if (soilAnalysis.moistureLevel != null) {
        if (soilAnalysis.moistureLevel! < 0.3) {
          recommendations.add(Recommendation(
            title: 'Irrigation nécessaire',
            description: 'Le sol semble sec. Une irrigation est recommandée.',
            category: 'irrigation',
            priority: 'haute',
            actions: [
              'Arroser régulièrement',
              'Vérifier le système d\'irrigation',
            ],
          ));
        } else if (soilAnalysis.moistureLevel! > 0.8) {
          recommendations.add(Recommendation(
            title: 'Drainage nécessaire',
            description: 'Le sol semble trop humide. Vérifier le drainage.',
            category: 'irrigation',
            priority: 'moyenne',
            actions: [
              'Vérifier le système de drainage',
              'Réduire l\'irrigation',
            ],
          ));
        }
      }

      if (soilAnalysis.issues != null && soilAnalysis.issues!.isNotEmpty) {
        recommendations.add(Recommendation(
          title: 'Problèmes de sol détectés',
          description: 'Plusieurs problèmes ont été identifiés dans le sol.',
          category: 'sol',
          priority: 'moyenne',
          actions: soilAnalysis.issues,
        ));
      }
    }

    // Recommandations basées sur les indices de végétation Sentinel Hub
    if (sentinelData != null && sentinelData['vegetationIndices'] != null) {
      final ndvi = sentinelData['vegetationIndices']['ndvi'];
      if (ndvi != null) {
        // NDVI < 0.3 = végétation faible
        // NDVI 0.3-0.6 = végétation modérée
        // NDVI > 0.6 = végétation forte
        recommendations.add(Recommendation(
          title: 'Analyse de végétation satellite',
          description: 'Les données satellite montrent l\'état de la végétation dans la zone.',
          category: 'surveillance',
          priority: 'basse',
          actions: [
            'Consulter les données NDVI pour le suivi',
            'Comparer avec les analyses précédentes',
          ],
        ));
      }
    }

    // Recommandations météo
    if (weather != null) {
      if (weather.condition?.toLowerCase().contains('pluvieux') == true ||
          weather.condition?.toLowerCase().contains('rainy') == true) {
        recommendations.add(Recommendation(
          title: 'Conditions pluvieuses',
          description: 'Conditions pluvieuses détectées. Adapter les pratiques agricoles.',
          category: 'météo',
          priority: 'moyenne',
          actions: [
            'Éviter les traitements pendant la pluie',
            'Vérifier le drainage',
          ],
        ));
      }
    }

    return recommendations;
  }
}
